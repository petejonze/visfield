function [fullContent, data, appendedData]=getFileContent(fn)        
%GETFILECONTENTS short desc.
%
% Description.
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        editData, editMetaData, extractData
% 
% @Author:          Pete R Jones
%
% @Creation Date:	02/04/10
% @Last Update:     02/04/10
%
% @Todo:            <blank>


    % constants
    BEGINFILE_IDENTSTRING = '/*****HEADER INFORMATION*****/';
	BEGINDATA_IDENTSTRING = '/*****DATA*****/';   
    
    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('fn', @(x)exist(x,'file') > 0);
    p.FunctionName = 'GETFILECONTENTS';
    p.parse(fn);
    %----------------------------------------------------------------------


    % Open the file.  If this returns a -1, we did not open the file successfully.
    fid = fopen(fn,'r');
    if fid==-1
      error('getFileContent:errorOpeningFile',['File not found or permission denied: "' fn '"']);
    end


    fseek(fid,0,'bof');              %starting at the beginning of the file..
    %fullContent = fread(fid,inf,'uchar'); % Read in the rest of the file
    fullContent = fscanf(fid,'%c'); % Read in the rest of the file in readable text format

    % Extract the essential meta info
    fseek(fid,0,'bof');              %starting at the beginning of the file..
    tline = fgetl(fid);
    if ~ischar(tline)
        error('extractData:failedToExtractMetaInfo:emptyFile','File is empty')
    elseif ~strncmp(tline,BEGINFILE_IDENTSTRING,length(BEGINFILE_IDENTSTRING))
        error('extractData:failedToExtractMetaInfo:firstLineNotProperlyFormed',['No entry of "' BEGINFILE_IDENTSTRING '" detected on first line.'])
    end
    metaDataHeaders = cell(1,6);
    metaData = cell(1,6);
    noOfMetaFeatures = length(metaDataHeaders);
    for x=1:noOfMetaFeatures
        md = regexp(fgetl(fid),',','split');
        metaDataHeaders{x} = ['PTR_'  regexp(md{1},'\w+','match','once')];
        metaData{x} = md{2};
    end
    metaDataHeaders{x+1} = 'PTR_sourceFile';
    [pathStr,fileName] = fileparts(fn);
    metaData{x+1} = regexprep(fileName,'-','_');

    % Skip past all the remaining meta info
    while 1
        tline = fgetl(fid);
        if ~ischar(tline)
            error('extractData:failedToDetermineHeaderRowNum:noEntry',['No entry of "' BEGINDATA_IDENTSTRING '" detected.']);      
        elseif strncmp(tline,BEGINDATA_IDENTSTRING,length(BEGINDATA_IDENTSTRING))
            break;
        end
    end


    % Extract data headers
    dataHeaders = regexp(fgetl(fid),',','split');

    % Extract data
    data = fscanf(fid,'%c');
  	%data = regexp(data,'\r\n|,','split');
    %data(length(data)) = []; %remove last item (which is blank)
    
    % from csv2struct
    data = regexp(data,'\n|\r\n|,','split');
    if isempty(data{end})
        data(end) = []; %remove last item (which is blank)
    end
    
    noOfFeatures = length(dataHeaders);
    noOfSamples = length(data) / noOfFeatures;
    data=reshape(data,[noOfFeatures,noOfSamples])'; %reshape into (cell) matrix

    % prepend metainfo
    appendedDataHeaders = cat(2,metaDataHeaders,dataHeaders);
    appendedData = cat(2,repmat(metaData,noOfSamples,1),data);

    % concatenate data with headers
    data = cat(1,dataHeaders,data);
    appendedData = cat(1,appendedDataHeaders,appendedData);

%         % Transfer info to a structure
%         dataStruct = struct();
%         for x=1:noOfFeatures
%             dataStruct.(headerInfo{x}) = data(:,x);
%         end
% %         dispStruct(dataStruct) %for testing
%         
    fclose(fid);
        
end
        
