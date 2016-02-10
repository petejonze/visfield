function editData(expID,files,editField,newValue,varargin)
%EDITDATA short desc.
%
% Description.
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         editData('exp1ver8',myFileName,'partID','7')
%                   editData('exp1ver8',myFileName,'partID','oldVal-2','>2')
%
% @See also:        getFilesMatching, extractData:sub_getData, editMetaData
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
    p.FunctionName = 'EDITDATA';
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

            % check that specified field is present in the data (and if so, get index)
            index = ismember(data(1,:),editField);
            if ~any(index)
                error('editData:fieldNotFound',['The specified field: "' editField '" was not found in: ' escape(fn)]) 
            elseif sum(index) > 1
                error('editData:fieldNotFound',['Multiple versions of the specified field: "' editField '" were found in: ' escape(fn)]) 
            end

            logData('preparingEdit',fn); %log change being readied
            disp(fn)
            nrows = size(data,1);
            for x=2:nrows
                oldVal = data{x,index};
                newVal = eval(regexprep(newValue,'oldVal',oldVal)); %if "oldVal" is specified then substitute in the actual value
                newVal = any2str(newVal);

                if isempty(whereCondition) || eval([oldVal whereCondition])  %if no where condition has been specified, or if the specified condition has been met
                    data{x,index} = newVal{1};
                	editStr = ['   ' editField ':  ' oldVal ' --> ' newVal{1}];
                    disp(editStr) %display change being readed
                    logData('editContent',editStr); %log change being readied
                end
            end

            % reinsert the data back int the file
            setFileContent(fn,fullContent,data);
            
            %log change occuring
            logData('editOccured');
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
    