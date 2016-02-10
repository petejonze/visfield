function writeDataHeaders(varargin)
%WRITEDATA description.
%
% desc
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    % Parse & validate all input args
    % <none>
    %----------------------------------------------------------------------
    global OUTPUT_FILE_ID NUM_OF_OUTPUTS;
    %----------------------------------------------------------------------  

    %check that we are good to go
    if isempty(OUTPUT_FILE_ID)
        error('no data session active. startNewDataSession must be called before writeData will work!')
    end
    if NUM_OF_OUTPUTS ~= 0
        error('writeDataHeaders cannot be called if data has already been written (%i lines detected)',NUM_OF_OUTPUTS)
    end
 
    %initialise local variables
    fileID=OUTPUT_FILE_ID;
        
    %output headers
    preambleDataHeaders = {'id' 'timestamp' 'expID' 'partID'};
    userDataHeaders = varargin;
    totalDataHeaders = [preambleDataHeaders userDataHeaders];
    outputDataHeadersStr = strjoin(',', totalDataHeaders{:});
    fprintf(fileID, '%s', outputDataHeadersStr); %output headers
    fwrite(fileID, getNewline(), 'char'); % terminate this line
    
    % increment N data lines
    NUM_OF_OUTPUTS = NUM_OF_OUTPUTS + 1;
             
end