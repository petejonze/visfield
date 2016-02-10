function [DataSet]=extractData2Struct(expID,varargin)
%EXTRACTDATA2STRUCT short desc.
%
% Description.
% Unlike extract data cannot do processing or split up data
% Tree:  ExpID.Test.PartID.Session.Block.Raw
%
% The raw data is currently stored as a cell
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <none>
%
% @See also:        extractData
% 
% @Author:          Pete R Jones
%
% @Creation Date:	26/08/10
% @Last Update:     26/08/10
%
% @Todo:            make partID and sessID numeric


    % constants
    BEGINFILE_IDENTSTRING = '/*****HEADER INFORMATION*****/';
	BEGINDATA_IDENTSTRING = '/*****DATA*****/';      
    
    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addParamValue('partID', [], @(x)ischar(x) || iscellstr(x) || isnumeric(x)); %char, cellstr or numeric
    p.addParamValue('sessID', '*', @ischar);
    p.addParamValue('processingScript', [], @(x)isempty(x) || exist(x,'file') > 0);
    p.addParamValue('processingScriptParams', {});
    p.addParamValue('includePartInfo', false, @islogical);
    p.addParamValue('partInfoFile', [], @ischar);  %.csv file (for if not using a db) relative to the experiment home folder. First column assumed to be partID, all other columns included in data
    p.FunctionName = 'EXTRACTDATA2STRUCT';
    p.parse(expID,varargin{:}); % Parse & validate all input args
    %----------------------------------------------------------------------
    partIDs=p.Results.partID;
    if ischar(partIDs); partIDs={partIDs}; end
    if isnumeric(partIDs); partIDs=deNumberfyCell(num2cell(partIDs)); end
    if ~iscellstr(partIDs) %defensive
        error('extractData2Struct:invalidInput','Invalid partID input');
    end
    sessID                  = p.Results.sessID;
    
    includePartInfo  = p.Results.includePartInfo;
    partInfoFile     = p.Results.partInfoFile;
%     inFullMode=strcmpi(getPrefVal('mode'),'full');
    inFullMode=getPrefVal('useDb');
    
    if includePartInfo
        if ~inFullMode
            if isempty(partInfoFile)
                error('extractData2Struct:invalidInput','Running in Lite mode.\nAttempting to add participant info but no partInfoFile specified.');
            else
                homeDir=getPrefVal('homeDir');
                expHomeDir=[homeDir filesep expID];
                partInfoFile = [expHomeDir filesep partInfoFile];
                if ~exist(partInfoFile,'file')
                    error('extractData2Struct:invalidInput',['Specified participant info file not found:\n' escape(partInfoFile) '.']);
                end
            end
            % init for later
           	allPartInfo = {};
            allPartInfoHeaders = {};
        else
            error('extractData2Struct:unsupportedFunctionality','Running in Full mode.\nSorry, adding participant info from db not currently supported.');
        end
    end
    
	PROCESSING_SCRIPT       = p.Results.processingScript;
    pscriptParams           = p.Results.processingScriptParams;
	if ~iscellstr(pscriptParams)
       pscriptParams = {pscriptParams}; %'ok (used in eval)
	end
    %----------------------------------------------------------------------
    
    %%%%%%%%%
    %%% 0 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % initialise local variables 
	homeDir=getPrefVal('homeDir');
    expHomeDir=[homeDir filesep expID];
    dataDir=[expHomeDir filesep 'data'];
    partDataDirs=getDirs(dataDir,true);
    
    if isempty(partIDs)
        %get all participant data dirs
        validIndex=regexp(partDataDirs,'^\d+$','once');
        validIndex=~cellfun(@isempty,validIndex);
        partIDs = partDataDirs(validIndex==1);
        if isempty(partIDs)
            error('extractData:intialisation:noPartDataDirs',['No participant data directories specified, and none found in "' escape(dataDir) '"'])  
        end
    else
        %check that specified participant data subdirectory exists
        partID = partIDs{1};
        if (~ismember(partID,partDataDirs)) 
            error('extractData:intialisation:cannotFindPartDataDir',['No data directory found for participant "' partID '" in "' escape(dataDir) '"'])        
        end
    end

    % feedback
    fprintf('Extracting...\n');
    
    % create a variable to hold all the data in
    DataSet = struct();
    
    try

        for i=1:length(partIDs)
            
            partID = partIDs{i};
            partDataDir = [dataDir filesep partID];
            
            % Get list of file to extract data from
            filePattern = [expID '-' partID '-' sessID '-' '*.csv'];
            fileList = dir([partDataDir filesep filePattern]);
            fileList = fileList(not([fileList.isdir])); %weed out any oddly named directories that might have crept in

            % order by name
            [fileIndex,fileIndex] = sort_nat({fileList.name},'ascend');
            
            if isempty(fileList)
                error('extractData:specifiedDirIsEmpty',['No data files matching "' filePattern '" found in specified directory: "' escape(dataDir) '"']);
            end

            numOfFiles = length(fileList);

            % Give user progress feedback
            disp(['   Accessing (' num2str(numOfFiles) ') files(s) for participant ' partID ' ...'])
          
            % Extract the data!
            for y=1:numOfFiles
                fn = fileList(fileIndex(y)).name;
                
                
                
                % extract the data & metainfo
                [data,dataStruct,metaDataStruct] = sub_getData(fullfile(partDataDir, fn));

                % skip if empty
                if isempty(data)
                    fprintf('ignoring empty data file: %s', fn);
                    continue;
                end
                
                %
                fullfn = fullfile(partDataDir, fn);
                pid = getPartID(fullfn,partID);
                sid = getSessID(fullfn);
                bid = getBlockID(fullfn);
                
             	% add data to dataset
                DataSet.part(pid).sess(sid).block(bid).fn = fn;
                DataSet.part(pid).sess(sid).block(bid).raw.cell = data;
                DataSet.part(pid).sess(sid).block(bid).raw.struct = dataStruct;
                DataSet.part(pid).sess(sid).block(bid).meta = metaDataStruct;
                
            	% if a further processing script has been specified then
                % send the data off to be processed. The returned data is
                % then added to .fit
                if ~isempty(PROCESSING_SCRIPT)
                    % feedback
                    disp(['      adding fitted data from: ' PROCESSING_SCRIPT ' ...'])
                    % init
                    inf.fullfn = fullfn;
                    inf.pid = pid;
                    inf.sid = sid;
                    inf.bid = bid;
                    % process
                    fitDataStruct = eval([PROCESSING_SCRIPT '(inf,dataStruct,pscriptParams{:})']);
                    % store
                    DataSet.part(pid).sess(sid).block(bid).fitted = fitDataStruct;
                end
            end
            
            % add external participant data if so specified
            if includePartInfo && ~inFullMode
                disp(['      adding participant data from: ' partInfoFile ' ...'])
                pid = str2double(partID);
                DataSet.part(pid).info = sub_getPartDataFromFile(pid, partInfoFile);
            end
            
        end
        
        % aggregate together all external participant data if so specified
        if includePartInfo && ~inFullMode
            disp('      aggregating participant data...')
            
            % group together data, using first participants as a base
            partIDs
            partIDs{1}
            DataSet.part(partIDs{1}).info
            tmp = DataSet.part(str2double(partIDs{1})).info
            for i=2:length(partIDs)
                tmp = [tmp DataSet.part(str2double(partIDs{i})).info]; %#ok
            end
            % convert into vectors and store
            tmp
            DataSet.stats = struct();
            fnames = fieldnames(tmp);
            for i = 1:length(fnames)
                DataSet.stats.(fnames{i}) = [tmp.(fnames{i})];
            end
        end
            
        % feedback
        fprintf('...Done!\n\n');
        
    catch ME
        fclose('all'); %ensure that any file that happens to be open is closed properly      
        rethrow(ME)
    end

    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    function partDataStruct=sub_getPartDataFromFile(pid, partInfoFile)
        partDataStruct =struct();
        
        % load external part data if not already done so
        if isempty(allPartInfo)
            %[numeric,text,raw]=xlsread(partInfoFile) %csvread numeric only
            allPartInfo = csv2struct(partInfoFile);
            allPartInfoHeaders = fieldnames(allPartInfo);
        end
        
        %1st column name assumed to be partID or equivalent
        index = allPartInfo.(allPartInfoHeaders{1}) == pid;
        for x=1:length(allPartInfoHeaders)
            fieldName = allPartInfoHeaders{x};
            partDataStruct.(fieldName) = allPartInfo.(allPartInfoHeaders{x})(index);
        end
    end

    function [data,dataStruct,metaDataStruct]=sub_getData(fileName)
        
        % Open the file.  If this returns a -1, we did not open the file 
        % successfully.
        fid = fopen(fileName);
        if fid==-1
          error('extractData:errorOpeningFile',['File not found or permission denied: "' fileName '"']);
        end

        % Extract the essential meta info
        tline = fgetl(fid);
        if ~ischar(tline)
            error('extractData:failedToExtractMetaInfo:emptyFile','File is empty')
        elseif ~strncmp(tline,BEGINFILE_IDENTSTRING,length(BEGINFILE_IDENTSTRING))
            error('extractData:failedToExtractMetaInfo:firstLineNotProperlyFormed',['No entry of "' BEGINFILE_IDENTSTRING '" detected on first line.'])
        end
        metaDataHeaders = cell(1,9); %crude!
        metaData = cell(1,9);
        noOfMetaFeatures = length(metaDataHeaders);
        for x=1:noOfMetaFeatures
            dat = fgetl(fid);
            if isempty(dat)
                metaDataHeaders{x} = 'empty';
                metaData{x} = 'empty';
            else
                md = regexp(dat,',','split');
                metaDataHeaders{x} = ['PTR_'  regexp(md{1},'\w+','match','once')];
                metaData{x} = md{2};
            end
        end
        % remove blank entries
        idx = strcmpi('empty',metaDataHeaders);
        metaDataHeaders(idx) = [];
        metaData(idx) = [];

        % append source file
        metaDataHeaders{end+1} = 'PTR_sourceFile';
        metaData{end+1} = regexprep(regexprep(fileName,'\.csv',''),'-','_');
        typedMetaData = numberfyCell(metaData); % convert all number cols to numbers
        
        % Skip past all the remaining meta info
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
                error('extractData:failedToDetermineHeaderRowNum:noEntry',['No entry of "' BEGINDATA_IDENTSTRING '" detected.']);
            elseif regexpi(tline,'^Config:,[\s]*','once')
                metaDataHeaders{end+1} = 'PTR_config';
                metaData{end+1} = regexp(tline,'(?<=Config:,[\s]*)[^\s].+','match');
                typedMetaData = numberfyCell(metaData); % convert all number cols to numbers
            elseif strncmp(tline,BEGINDATA_IDENTSTRING,length(BEGINDATA_IDENTSTRING))
                break;
            end
        end
        headerLine = fgetl(fid);
        
        % if no data, abort
        if headerLine == -1
            data = []; dataStruct = []; metaDataStruct = []; 
            return
        end
        
        % Extract data headers
        dataHeaders = regexp(headerLine,',','split');
        
        % Extract data
        data = fscanf(fid,'%c');
%         data = regexp(data,'(\r\n)|,','split'); % works on data saved on windows
%         data = regexp(data,'(\n)|,','split'); % works on data saved on mac
        data = regexp(data,'(\r\n)|(\n)|,','split'); % works on data saved on both?
        data(length(data)) = []; %remove last item (which is blank)
        
        noOfFeatures = length(dataHeaders);
        noOfSamples = length(data) / noOfFeatures;

        data=reshape(data,[noOfFeatures,noOfSamples])'; %reshape into (cell) matrix
        typedData = numberfyCell(data); % convert all number cols to numbers
        data = cat(1,dataHeaders,typedData); % rejoin headers and data

        % Transfer info to a structure
        dataStruct = struct();
        for x=1:length(dataHeaders)
            col = typedData(:,x);
            % convert numeric columns to arrays, leave the rest as cells
            if isnumeric(col{1})
               col = [col{:}];
            end
            % store column in struct field
            dataStruct.(dataHeaders{x}) = col;
        end

         % Transfer meta info to a structure
        metaDataStruct = struct();
        for x=1:length(metaDataHeaders)
            val = typedMetaData{:,x};
            metaDataStruct.(metaDataHeaders{x}) = val;  % store val in struct field
        end
        
        % prepend metainfo to cell matrix
        typedMetaData = repmat(typedMetaData,noOfSamples,1); %fill down meta data to the approp. num of rows
        metaData = cat(1,metaDataHeaders,typedMetaData); % rejoin headers and data
        cat(2,metaData,data); %prepend
        
        fclose(fid);
    
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
