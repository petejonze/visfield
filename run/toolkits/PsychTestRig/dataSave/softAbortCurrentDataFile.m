function softAbortCurrentDataFile(errorStruct)
% like abort, but lets you keep going

   
    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('errorStruct');
    p.FunctionName = 'SOFTABORTCURRENTDATAFILE';
    p.parse(errorStruct);
    %----------------------------------------------------------------------
    global OUTPUT_FILE_ID OUTPUT_PART_DATADIR;
    %---------------------------------------------------------------------- 
    
    %check that we are good to go
    if (isempty(OUTPUT_FILE_ID))
        error('no data session active. startNewDataSession must be called before finishDataSession will work!')
    end

    %initialise local variables
    fileID=OUTPUT_FILE_ID;
    partDataDir=OUTPUT_PART_DATADIR;
    trashDir=[partDataDir filesep '__TRASH'];
    errMsg=[errorStruct.message '  [' regexprep(escape(struct2String(errorStruct.stack)),'\\\\n','; ') ']'];

    %check __Trash dir exists, if not then create
    if ~exist(trashDir,'dir')
       mkdir(trashDir);
    end

    %write timestamped error message
    writeErrorMsg(errMsg);
    
    %close file
    fname=fopen(fileID);
    fclose(fileID);

    %rename to make clear aborted & move to 'trash'
    expression=[escape(filesep) '(?!.*' escape(filesep) ')']; %e.g. '\\(?!.*\\)';
    replace=[escape(filesep) '__TRASH' escape(filesep) 'ABORTED-'];
    newName=regexprep(fname,expression,replace); %prepend the string following any (i.e. the) filesep that is not followed by any other fileseps
    movefile(fname,newName);
    
    %log file abortion
    logData('DataFileAborted')
    
    %removed the iterate from newBlock_B() :
%     %deiterate
%     deiterateBlockNum() 
    
    %clear global variables set by beginNewDataFile
    clear global OUTPUT_FILE_ID;
    
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>