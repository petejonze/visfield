function destroyCurrentDataFile()
%DESTROYCURRENTDATAFILE description.
%
% desc
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    % Parse & validate all input args
    %<none>
    %----------------------------------------------------------------------
    global OUTPUT_FILE_ID; %to get
    %----------------------------------------------------------------------
    
    %check that we are good to go
    if (isempty(OUTPUT_FILE_ID))
        error('no data session active. startNewDataSession must be called before finishDataSession will work!')
    end

    %initialise local variables
    fileID=OUTPUT_FILE_ID;
    fname=fopen(fileID);
    
    %close file
    fclose(fileID);

    %delete file
   	delete(fname);
    
    %log file desctruction
    logData('DataFileDestroyed')
    
    %deiterate
%     deiterateBlockNum()
    
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>