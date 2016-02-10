function writeNote(noteMsg)
%WRITENOTE description.
%
% desc
%
% Example: none
%
% See also startDataSession writeData finishDataSession

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('noteMsg', @ischar);
    p.FunctionName = 'WRITENOTE';
    p.parse(noteMsg);
    %----------------------------------------------------------------------
    global OUTPUT_FILE_ID;
    %----------------------------------------------------------------------

    %check that we are good to go
    if (isempty(OUTPUT_FILE_ID))
        error('no data session active. startNewDataSession must be called before outputWarning will work!')
    end
    
    %initialise local variables
    fileID=OUTPUT_FILE_ID;
    
    %print finish time
    fseek(fileID,0,'bof');
    loc = 12; %to skip the first 12 lines
    for i = 1:loc 
        temp_line = fgetl(fileID);        %Used FGETL to move file pointer a whole line at a time 
    end; 
    location = ftell(fileID) + 7; %+7 to move passed 'Notes:,'
    fseek(fileID,location,'bof');
    c = fread(fileID,inf,'uchar'); % Read in the rest of the file after line of interest 
    fseek(fileID,location,'bof'); % Place the internal pointer back to the location of interest 
    fprintf(fileID,'%s',[noteMsg '. ']); % !!!!!!Print the data to the current position!!!!!!
    fwrite(fileID,c,'uchar'); % re-write the rest of the data in the file
    
    %log data
 	logData('NoteMade',noteMsg);
             
    
end