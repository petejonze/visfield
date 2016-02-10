function writeErrorMsg(errMsg)
%WRITEERRORMSG description.
%
% desc
%
% Example: none
%
% See also startDataSession writeData finishDataSession

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('errMsg', @ischar);
    p.FunctionName = 'WRITEERRORMSG';
    p.parse(errMsg);
    %----------------------------------------------------------------------
    global OUTPUT_FILE_ID;
    %----------------------------------------------------------------------

    %check that we are good to go
    if (isempty(OUTPUT_FILE_ID))
        error('no data session active. startNewDataSession must be called before outputWarning will work!')
    end
    
    %initialise local variables
    fileID=OUTPUT_FILE_ID;
    myTimestamp=datestr(now,31); %determine the time
    
    %print finish time
    ftell(fileID)
    fseek(fileID,0,'bof');
    loc = 14; %to skip the first 14 lines
    for i = 1:loc 
        temp_line = fgetl(fileID);        %Used FGETL to move file pointer a whole line at a time 
    end; 
    location = ftell(fileID) + 8; %+8 to move passed 'Errors:,'
    fseek(fileID,location,'bof');
    c = fread(fileID,inf,'uchar'); % Read in the rest of the file after line of interest 
    fseek(fileID,location,'bof'); % Place the internal pointer back to the location of interest 
    fprintf(fileID,'%s',[myTimestamp '::' errMsg]); % !!!!!!Print the data to the current position!!!!!!
    fwrite(fileID,c,'uchar'); % re-write the rest of the data in the file
    
end