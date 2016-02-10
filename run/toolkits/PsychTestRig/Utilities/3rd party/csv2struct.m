function Out = csv2struct(filename, breakOnChar, attemptToConvertDatetimes)
%CSV2STRUCT reads Excel's files stored in .xls or .csv file formats and
% stores results as a struct.
%
% DESCRIPTION
% The Excel file is assumed to have a single header row. The output struct
% will have a field for each column and the field name will be based on the
% column name read from the header.
%
% Unlike csvread, csv2struct is able to read files with both text and
% number fields. Unlike xlsread, csv2struct is able to read .csv files
% with more than 65536 rows.
%
% See also:
%   MATLAB's csvread and xlsread functions
%   xml_read from my xml_io_tools which creates struct out of xml files
%
% Written by Jarek Tuszynski, SAIC, jaroslaw.w.tuszynski_at_saic.com
% Code covered by BSD License
%
% ------------------------------------------------------------------------
%
% Modified by pete jones (12/06/11) to allow for nested structures/fields
%
%   e.g. if breakOnChar == '_' then the header 'name_first' will evaluate
%   to Out.name.first
%
%   Note that blank spaces are still replaced by underscores, so here 'name
%   first' will also evaluate to Out.name.first!
%
%   If the breakOnChar parameter is not specified, or specified as empty
%   then this will operate exactly the same as before
%
% modified by PJ Jan/2013 to allow to work with Mac OS
% modified by PJ Mar/2014 to attempt date parsing (still potentially a bit flakey)

%% Init
if nargin < 2
    breakOnChar = []; % default break character (empty for no breaks)
end
if nargin < 3 || isempty(attemptToConvertDatetimes)
    attemptToConvertDatetimes = true;
end
Out = struct();

%% read xls file with a single header row
if 0 % IsWin
    [tmp tmp raw] = xlsread(filename);
    clear tmp
    % extract header (store separately)
    header = raw(1,:);
    raw(1,:) = [];
    
    raw = numberfyCell(raw); % shouldn't really be needed, but seems to sort out a few odd cases of nans not being detected as numeric
else
    % Necessary to work with Mac OS X
    fid = fopen(filename,'r');
    
    try
        % Extract data headers
        header = regexp(fgetl(fid),',','split');

        % Read data
        data = fscanf(fid,'%c');

        % close file
        fclose(fid);
    catch ME
        fclose all;
        rethrow(ME);
    end

    % extract data
    %data = regexp(data,'\r\n|,','split')
    %data = regexp(data,'[\s*\r\n]|[,]','split')
    %data = regexp(data,'(\r\n)|,','split');
    
    try
        datbackup = data;
        data = regexp(data,'\n|\r\n|,','split'); % unlike below, worked with partinfo.csv
        
        if isempty(data{end})
            data(end) = []; %remove last item (which is blank)
        end
        noOfFeatures = length(header);
        noOfSamples = length(data) / noOfFeatures;
        
        if length(data)==1 && isempty(data{1}) % no data
            data = [];
        else
            data=reshape(data,[noOfFeatures,noOfSamples])'; %reshape into (cell) matrix
            % convert all number cols to numbers
            data = numberfyCell(data);
        end
    catch %#ok
        data = datbackup;
        data = regexp(data,'[\s*\r\n]|[,]','split'); % unlike above worked with csv saved from excel on the mac
        
        if isempty(data{end})
            data(end) = []; %remove last item (which is blank)
        end
        noOfFeatures = length(header);
        noOfSamples = length(data) / noOfFeatures;
        
        if length(data)==1 && isempty(data{1}) % no data
            data = [];
        else
            try
                data=reshape(data,[noOfFeatures,noOfSamples])'; %reshape into (cell) matrix
            catch ME
                data
                noOfFeatures
                noOfSamples
                length(data)
                rethrow(ME);
            end
            % convert all number cols to numbers
            data = numberfyCell(data);
        end
    end
    
    % store
    raw = data;
end

%% Split data into txt & num parts
nRow = size(raw,1);
nCol = size(raw,2);
format = '';
num = [];
txt = [];
tmp = nan(nRow,1);
ColNumeric = nan(1,nCol);
for c = 1:nCol
    col = raw(:,c);
    ColNumeric(c) = true;
    for r = 1:nRow
%         if(~isnumeric(col{r}) || isnan(col{r})), ColNumeric(c) = false; break; end
        if ~isnumeric(col{r}), ColNumeric(c) = false; break; end
    end
    if ColNumeric(c),
        num    = [num cell2mat(col)];
        format = [format '%f'];
    else
        if attemptToConvertDatetimes
            
            mostLikelyEuropeanFormat = true;
            
            % could expand on this by checking if any apparent months
            % exceed 12?
            if strcmpi(java.util.Locale.getDefault(), 'en_US')
                mostLikelyEuropeanFormat = false;
            end
            
            isdate = true;
            tmp = nan(nRow,1);
            for r = 1:nRow
                try
                    if ~isempty(raw{r,c})
                        if mostLikelyEuropeanFormat
                            tmp(r) = datenum(regexprep(raw{r,c},'([0-9]+)[/\\-]+([0-9]+)[/\\-]+([0-9]+)','$2/$1/$3'));
                        else
                            tmp(r) = datenum(raw{r,c});
                        end
                    end
                catch %#ok
                    isdate = false;
                    break;
                end
            end
            
        else
            isdate = false; % too risky - impossible to know the format(!)  
        end
        
        if isdate
            ColNumeric(c) = true;
            num    = [num tmp];
            format = [format '%f'];
        else
            txt    = [txt col];
            format = [format '%s'];
        end
    end
end
clear raw

%% In case of csv file with more than 2^16 rows read the rest of the file
[tmp tmp ext] = fileparts(filename); %#ok
if (nRow==2^16 && strcmpi(ext, '.csv')),
    % read the rest of the file
    fid = fopen(filename);
    for i=1:2^16, fgetl(fid); end
    data = textscan(fid, format, 'Delimiter',',', 'CollectOutput', 1);
    fclose(fid);
    % concatenate to txt and num
    ridx = nRow + (1:size(data{1},1));
    num2=[]; txt2=[];
    for i = 1:length(data)
        if isnumeric(data{i}), num2 = [num2 data{i}]; end
        if iscell   (data{i}), txt2 = [txt2 data{i}]; end
    end
    txt(ridx,:) = txt2;
    num(ridx,:) = num2;
    clear data
end

%% check for empty, and if so return null [PJ]
if isempty(txt) && isempty(num)
    Out = cell2struct(cell(1,length(header)),header,2);
    return
end

%% Create struct with fields derived from column names from header
iNum = 1;
iTxt = 1;
for c=1:nCol
    if ~isempty(breakOnChar)
        % split name at dashes breakOnChar instances (e.g. '-')
        fieldnodes = regexp(header{c}, breakOnChar, 'split');
    else
        fieldnodes = header(c);
    end
    
    for i=1:length(fieldnodes)
        name = fieldnodes{i};
        if ischar(name)
            name = strtrim(name);
            name(name==' ') = '_';
            name = genvarname(name);
        else
            name = char('A'-1+i);
        end
        fieldnodes{i} = name;
    end
    
   	fieldpath = sprintf('.%s',fieldnodes{:});

    % add data
    if (ColNumeric(c))
        eval(['Out' fieldpath ' = num(:,iNum);']); % OLD: Out.(name) = num(:,iNum);
        iNum = iNum+1;
    else
        eval(['Out' fieldpath ' = txt(:,iTxt);']); % OLD: Out.(name) = txt(:,iTxt);
        iTxt = iTxt+1;
    end
end
