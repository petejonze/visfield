function [outputFiles]=extractData(expID,varargin)
%EXTRACTDATA short desc.
%
% Description.
%
% n.b. if no partID(s) are specified then it will assume that all (and
% only) directories begining with a number should be used. Thus if you
% created a subdirectory called, say, "__EXCLUDED" then all files places in
% there would automatically be ignored.
%
%   Be default this script can be used to create one or more master files
%   containing a row of data for every trial. If you don't care about each
%   individual trial then you can pass the name of a processing script that
%   could perform further operations on each block of data. For example,
%   condensing all the values in a column down to a mean, or fitting a
%   curve to the data and passing back the curve parameters. For more
%   advanced tasks that require comparisons between blocks then you should
%   use extractData2Struct() instead, and then perform your bespoke
%   operations on the structure. (For example, if you wanted to obtain
%   thresholds relative to some starting performance, where the starting
%   performance was observed in the first block).
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         participants = {'7','8','9'};
%                   files=extractData('SummerScientist2010','partID',participants,'outputDir','analysis','splitBy','respInt','splitWithinFiles',true)
%
% @See also:        extractData2Struct
% 
% @Author:          Pete R Jones
%
% @Creation Date:	14/03/10
% @Last Update:     26/08/10
%
% @Todo:            Lots! Esp. testing
% does not yet have extractData2Struct's ability to include participant
% data

    % constants
    BEGINFILE_IDENTSTRING = '/*****HEADER INFORMATION*****/';
	BEGINDATA_IDENTSTRING = '/*****DATA*****/';      
    
    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addParamValue('partID', [], @(x)ischar(x) || iscellstr(x) || isnumeric(x)); %char, cellstr or numeric
    p.addParamValue('sessID', '*', @ischar);
    p.addParamValue('splitBy', [], @ischar); %e.g. PTR_Manual, PTR_Experiment
    p.addParamValue('splitWithinFiles', false, @islogical); % (slower)
    p.addParamValue('processingScript', [], @(x)exist(x,'file') > 0);
    p.addParamValue('outputDir', 'data', @ischar); %e.g. relative to the experiment home folder
    p.FunctionName = 'EXTRACTDATA';
    p.parse(expID,varargin{:}); % Parse & validate all input args
    %----------------------------------------------------------------------
    partIDs=p.Results.partID;
    if ischar(partIDs); partIDs={partIDs}; end
    if isnumeric(partIDs); partIDs=deNumberfyCell(num2cell(partIDs)); end
    if ~iscellstr(partIDs) %defensive
        error('extractData2Struct:invalidInput','Invalid partID input');
    end
    
    sessID                  = p.Results.sessID;
    
    SPLIT_CRITERION_FIELD   = p.Results.splitBy;
    SPLIT_WITHIN_FILES      = p.Results.splitWithinFiles;
    
    PROCESSING_SCRIPT       = p.Results.processingScript;
    
	outputDir               = p.Results.outputDir;
    %----------------------------------------------------------------------
    
    %%%%%%%%%
    %%% 0 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % initialise local variables 
	homeDir=getPrefVal('homeDir');
    expHomeDir=[homeDir filesep expID];
    outputDir = [expHomeDir filesep outputDir];
  	compDir=[outputDir filesep '__COMPILATIONS'];
    
    dataDir=[expHomeDir filesep 'data'];
    partDataDirs=getDirs(dataDir,true);
    
    outputFiles = cell(0);
    
    
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

            %[fileIndex,fileIndex] = sort([fileList.datenum],'ascend');
            [fileIndex,fileIndex] = sort_nat({fileList.name},'ascend');
            
            if isempty(fileList)
                error('extractData:specifiedDirIsEmpty',['No data files matching "' filePattern '" found in specified directory: "' escape(dataDir) '"']);
            end

            numOfFiles = length(fileList);

            % Give user progress feedback
            disp(['Accessing (' num2str(numOfFiles) ') files(s) for participant ' partID ' ...'])
        
            % Extract the data!
            for y=1:numOfFiles
                fn = fileList(fileIndex(y)).name;
                data = sub_getData(fullfile(partDataDir, fn));
                fn = regexprep(regexprep(fn,'\.csv',''),'-','_');

                % if a further processing script has been specified then
                % send the data off to be processed. The data is
                % overwritten by whatever this script returns. Thus it
                % could be used to boil down a raw data set into a set of
                % summary statistics
                if ~isempty(PROCESSING_SCRIPT)
                    usrData = numberfyCell(data,true); %spare the user having to convert strings to numbers
                    data = eval([PROCESSING_SCRIPT '(usrData)']);
                    data = deNumberfyCell(data); %convert back to string for easy storage
                end
                
             	% add data to dataset
                DataSet.(['part' partID]).(fn) = data; 
            end

        end
     
        %check compilations dir exists, if not then create
        if ~exist(compDir,'dir')
           mkdir(compDir);
        end
        
        
        if ~isempty(SPLIT_CRITERION_FIELD)
            % Give user progress feedback
            disp(sprintf('Splitting the data based on "%s"...',SPLIT_CRITERION_FIELD))
            % restructure dataset - split based on matches to some value
            DataSets = splitDataStruct(DataSet,SPLIT_CRITERION_FIELD,SPLIT_WITHIN_FILES);
        else
            DataSets = splitDataStruct(DataSet,'PTR_Experiment',false); %bit of a sneaky hack this. Since PTR_Experiment should be invariant, can just 'split' based on this - thereby creating just 1 file (whilst taking advatage of the error checking. Downside is that it now goes row-by-row, so this 
            % rename the only field as 'complete' rather than whatever
            % splitDataStruct chose to call it.
            fieldName = fieldnames(DataSets);
            fieldName = fieldName{1}; % grab the first (and only!) entry in the cell of field names
            DataSets = rnStructField(DataSets,fieldName,'complete');
        end
        
        
        % output data to csv file
        accessList = fieldnames(DataSets);
        fprintf('\n');
        for i=1:length(accessList)
            critID = accessList{i};

            % Give user progress feedback
            fprintf('Outputting the dataset for "%s"...\n',critID)

            outputFiles{i} = local_saveNewDataSet(DataSets.(critID),critID,expID,partIDs,sessID,compDir);
        end
            
    catch
        fclose('all'); %ensure that any file that happens to be open is closed properly    
        rethrow(lasterror)
    end
    
    %%%%%%%%%
    %%% 0 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Finish up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    
    function data=sub_getData(fileName)
        
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
        metaDataHeaders = cell(1,6);
        metaData = cell(1,6);
        noOfMetaFeatures = length(metaDataHeaders);
        for x=1:noOfMetaFeatures
            md = regexp(fgetl(fid),',','split');
            metaDataHeaders{x} = ['PTR_'  regexp(md{1},'\w+','match','once')];
            metaData{x} = md{2};
        end
        metaDataHeaders{x+1} = 'PTR_sourceFile';
        metaData{x+1} = regexprep(regexprep(fileName,'\.csv',''),'-','_');
        
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
        data = regexp(data,'\r\n|,','split');
        data(length(data)) = []; %remove last item (which is blank)
        
        noOfFeatures = length(dataHeaders);
        noOfSamples = length(data) / noOfFeatures;
        data=reshape(data,[noOfFeatures,noOfSamples])'; %reshape into (cell) matrix

        % prepend metainfo
        dataHeaders = cat(2,metaDataHeaders,dataHeaders);
        data = cat(2,repmat(metaData,noOfSamples,1),data);

        % return
        data = cat(1,dataHeaders,data);
        
        
%         % Transfer info to a structure
%         dataStruct = struct();
%         for x=1:noOfFeatures
%             dataStruct.(headerInfo{x}) = data(:,x);
%         end
% %         dispStruct(dataStruct) %for testing
%         
        fclose(fid);
    
    end
 
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%

function fileName=local_saveNewDataSet(DataSet,critID,expID,partIDs,sessID,outputDir)

    % initialise local variables
    partIDs = strjoin(',',partIDs{:});
    sessID = regexprep(sessID,'\*','all');
    timeNow = datestr(now,30);
    newline=getNewline();

    % construct file name
    fn=['compiledData.' critID '---' 'exp=' expID '---' 'part=' partIDs '---' 'session=' sessID '---' timeNow '.csv'];
    fullFn = [outputDir filesep fn];
    
    % create file
    fileName=mkfile(fullFn);
    
    % output the data to the file
    try
        fid = fopen(fileName,'w+');
        for i=1:size(DataSet,1)
            outputLine = strjoin(',',DataSet{i,:});
            fprintf(fid, '%s', outputLine);
            fwrite(fid, newline, 'char'); % terminate this line
        end
        fclose(fid);
    catch
        ME=lasterror;
        fclose(fid);
        delete(fullFn); %clean up
        myErr=  [   '/*****Failed to create new data file.*****/\n\n' ...
                    '   The following error message was produced:\n' ...
                    '      ' ME.message '\n\n' ...
                    '   It originated from:\n' ...
                    ['      ' regexprep(strtrim(escape(struct2String(ME.stack))),'\\\\n','\\n  ') '\n'] ... %regexprep to unescape any newline characters returned from struct2String
                    'Any traces of the data file were deleted\n' ...
                    '*****/' ...
                ];   
        error('extractData:outputDataToFile:FatalFail',myErr); %'rethrow-plus-some'      
    end
    
end
