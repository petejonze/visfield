function closeDataLog()
%CLOSEDATALOG description.
%
% desc
%
% Example: none
%
% See also startDataSession writeData finishDataSession

    %----------------------------------------------------------------------
    % Parse & validate all input args
    % <none>
    %----------------------------------------------------------------------    
    global DATALOG_FILE_ID;
    %----------------------------------------------------------------------

    %check that we are good to go
    %<none>
        
    %initialise local variables
    fileID=DATALOG_FILE_ID;

    %log data log being closed!
    logData('dataLogClosed');
    
    %close file
    fclose(fileID);

	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>