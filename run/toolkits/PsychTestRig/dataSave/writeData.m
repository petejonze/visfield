function writeData(varargin)
%WRITEDATA description.
%
% desc
%
% Example: none
%
% See also
% Note, currently any numeric vectors must be passed in as rows, or else
% strjoin will throw an inconsistent-dimensions error

    %----------------------------------------------------------------------
    % Parse & validate all input args
    % <none>
    %----------------------------------------------------------------------
    global OUTPUT_FILE_ID NUM_OF_OUTPUTS EXP_ID PART_ID;
    %----------------------------------------------------------------------
    
    %check that we are good to go
    if isempty(OUTPUT_FILE_ID)
        error('no data session active. startNewDataSession must be called before writeData will work!')
    end
    
    if isempty(varargin)
        return %silently terminate if no data passed
    end
    
    %initialise local variables
    fileID=OUTPUT_FILE_ID;
    NUM_OF_OUTPUTS = NUM_OF_OUTPUTS + 1;
    outputNum = num2str(NUM_OF_OUTPUTS);
    timestamp = datestr(now,31); %determine the time
    preambleData = {outputNum, timestamp, EXP_ID, num2str(PART_ID)};
    userData = any2str(varargin{:});
    totalData = [preambleData userData];
    % make any column vectors into row vectors to prevent concatenation
    % errors
    idx = cellfun(@iscolumn,totalData);
    totalData(idx) = cellfun(@transpose, totalData(idx), 'UniformOutput',0);
    try
        outputDataStr = strjoin(',', totalData{:});
    catch ME
        fprintf('\nATTEMPTING TO JOIN----------------------------------------\n')
        totalData %#ok
        totalData{:} %#ok
        rethrow(ME);
    end
    
    %if first run.. output headers
    if (NUM_OF_OUTPUTS == 1)
        preambleDataHeaders = {'id' 'timestamp' 'expID' 'partID'};
        userDataHeaders = cell(1,nargin);
        for i=1:nargin
            str = regexprep(inputname(i),'\.','_'); % replace any dots (e.g. from structure references), since these can cause problems later (e.g. are not valid fields in a data structure)
            userDataHeaders{i} = str;
        end
        if (ismember('', userDataHeaders)) %give warning if any of the variables are blank
            warning('writeData:missingName','one or more variables has no name. To give names call writeData using named variables rather than the results of a calculcation. For example: "myVal=2*2; writeData(myVal);" rather than writeData(2*2). Alternatively, use writeDataHeaders to manually write the headers. See "help writeData" for more.');
        end
        totalDataHeaders = [preambleDataHeaders userDataHeaders];
        outputDataHeadersStr = strjoin(',', totalDataHeaders{:});
        fprintf(fileID, '%s', outputDataHeadersStr); %output headers
        fwrite(fileID, getNewline(), 'char'); % terminate this line
    end
    
    %output data
    fprintf(fileID, '%s', outputDataStr);
    fwrite(fileID, getNewline(), 'char'); % terminate this line

    %log data
 	logData('DataSaved',outputDataStr);
             
end