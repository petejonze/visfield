function editMetaData(expID,files,editField,newValue,varargin)
%EDITMETADATA short desc.
%
% Modified version of editData.m
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         editMetaData('acuity', 'D:\Dropbox\Experiments\acuity\data\6\acuity-6-3-1-20130513T114244.csv','Session ID','3')
%                   editMetaData('tradeoffs', getBlockFns('tradeoffs',pid,sid), 'Session ID','1')
%
% @See also:        editData
% 
% @Author:          Pete R Jones
%
% @Creation Date:	01/04/10
% @Last Update:     01/04/10
%
% @Todo:            <blank>


    
    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addRequired('files', @(x)ischar(x) || iscellstr(x));
    p.addRequired('editField', @ischar);
    p.addRequired('newValue', @ischar);
    p.addOptional('whereCondition', [], @ischar);
    p.FunctionName = 'EDITMETADATA';
    p.parse(expID,files,editField,newValue,varargin{:});
    %----------------------------------------------------------------------
    whereCondition = p.Results.whereCondition;
    %----------------------------------------------------------------------
    if ischar(files); files={files}; end
    %---------------------------------------------------------------------- 
    
    %initialise local variables
   	homeDir=getPrefVal('homeDir');
    expHomeDir=[homeDir filesep expID];
    dataDir=[expHomeDir filesep 'data'];
    nFiles = length(files);
        
    % Check good to go (1): does the log file exist?
    if ~isDataLogPresent(dataDir,expID)
        error('editData:dataLogNotFound',[  'Could not find the data log file in ' escape(dataDir)...
                                            '\n\nA data log is automatically created when data is saved using writeData()']) 
    end
    
    % Check good to go (2): do all specified files exist in the specified experiment dir?
    filesMissing = false;
    for i=1:nFiles
        [pathStr,name,ext] = fileparts(files{i});
        partID = regexp(pathStr,'[^\\]+$','match','Once');   %e.g. K:\Peter\Experiments\exp1ver8\data\13   ->  13
        fn = [dataDir filesep partID filesep name ext];
        if ~exist(fn,'file')
            warning('editData:intialisation:cannotFindFile',['Could not find the file: "' [name ext] '" inside ' escape(dataDir)])   
            filesMissing = true;
        end
    end
    if filesMissing
        error('editData:intialisation:missingFiles','Not all specified files could be located. See above for details.') 
    end    
    
    

    try
         
        % Open data log 
        openDataLog(dataDir,expID);

        for i=1:nFiles
            fn = files{i};

            % make backup of the file before we start messing with it
            makeEditBackup(fn);

            % retrieve the file contents
            [fullContent,data]=getFileContent(fn);

            %START CHANGES FROM EDITDATA
            logData('preparingMetaEdit',fn); %log change being readied
            disp(fn)

%             pattern = ['(?<=' editField ':,)[^,]+(?=\n)'];
            pattern = ['(?<=' editField ':,)[a-zA-Z0-9]+'];
            oldVal = regexp(fullContent, pattern, 'Match','Once');
%             oldVal = regexprep(oldVal,',',''); % a precaution

            if strcmp(oldVal,'')
                warning('editData:fieldNotFound',['The specified field: "' editField '" was not found in: ' escape(fn)]) 
            else
                newVal = eval(regexprep(newValue,'oldVal',oldVal)); %if "oldVal" is specified then substitute in the actual value
                newVal = any2str(newVal);

                if isempty(whereCondition) || eval([oldVal whereCondition])  %if no where condition has been specified, or if the specified condition has been met
                    newFullContent = regexprep(fullContent,oldVal,newVal,'Once');
                    editStr = [editField ':  ' oldVal ' --> ' newVal];
                    disp(['   ' editStr]) %display change being readed
                    logData('editMetaContent',editStr); %log change being readied
                end
            end    
            
            % If any changes have actually been made
            if exist('newFullContent','var')
                % reinsert the data back int the file
                replaceFileContent(fn,fullContent,newFullContent);
            end
            
            % change file name
            if strcmpi(editField,'Session ID')
                fprintf('renaming file...\n');
                [pathstr,name,ext] = fileparts(fn);
                oldname = [name ext];
                newname = regexprep(oldname, '(?=[\w]+-[\d]+-)\d+(?<=-[\d]+-[\w\d]+)', newVal);
                movefile(fullfile(pathstr,oldname), fullfile(pathstr,newname));
            end
            
            %END CHANGES FROM EDITDATA

            %log change occuring
            logData('metaEditOccured');
        end
    catch
        logData('editAborted');
        closeDataLog();
        fclose('all')
        rethrow(lasterror);
    end

	%close data log
	closeDataLog();
    

	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>
    