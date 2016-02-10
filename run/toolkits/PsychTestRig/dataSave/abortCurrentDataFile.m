function abortCurrentDataFile(errorStruct)
%ABORTCURRENTDATAFILE description.
%
% desc
%save/close file. Rename to make clear aborted
%write error message
%
% Example: none
%
% See also
%Summary statistics??????????????????

   
    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    %p.addRequired('errorStruct', @isstruct);
    p.addRequired('errorStruct');
    p.FunctionName = 'ABORTCURRENTDATAFILE';
    p.parse(errorStruct);
    %----------------------------------------------------------------------
    global OUTPUT_FILE_ID OUTPUT_PART_DATADIR;
    %---------------------------------------------------------------------- 
    
    %check that we are good to go
    if (isempty(OUTPUT_FILE_ID))
        error('no data session active. startNewDataSession must be called before finishDataSession will work! (this may also happen if you used clear all)')
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
    
    %'throw' error & close data log
    logData('FatalError',errMsg);
    logData('DataFileAborted');
    closeDataLog();
    
    %clear global variables
    clear global OUTPUT_FILE_ID NUM_OF_OUTPUTS;
 
    
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>