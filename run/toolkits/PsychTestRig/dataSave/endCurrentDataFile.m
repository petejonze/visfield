function endCurrentDataFile(varargin)
%ENDCURRENTDATAFILE description.
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
    global OUTPUT_FILE_ID NUM_OF_OUTPUTS; %to get
    %----------------------------------------------------------------------
    
    %check that we are good to go
    if (isempty(OUTPUT_FILE_ID))
        error('no data session active. startNewDataSession must be called before finishDataSession will work!')
    end
    
    %initialise local variables
    fileID=OUTPUT_FILE_ID;
    outputData = datestr(now,31); %determine the finish time
    numOfOutputs = NUM_OF_OUTPUTS;
    
    if numOfOutputs == 0
        destroyCurrentDataFile()
    else
        %print finish time
        fseek(fileID,0,'bof');
        loc = 9; %to skip the first 9 lines
        for i = 1:loc 
            temp_line = fgetl(fileID);        %Used FGETL to move file pointer a whole line at a time 
        end; 
        location = ftell(fileID) + 10; %+10 to move passed 'end date:,'
        fseek(fileID,location,'bof');
        c = fread(fileID,inf,'uchar'); % Read in the rest of the file after line of interest 
        fseek(fileID,location,'bof'); % Place the internal pointer back to the location of interest 
        fprintf(fileID,'%s',outputData); % Print the data to the current position 
        fwrite(fileID,c,'uchar'); % re-write the rest of the data in the file

        %close file
        fname=fopen(fileID);
        fclose(fileID);

        %make backup
        backupDir=getPrefVal('backupDir');
        if (exist(backupDir,'dir'))
            copyfile(fname,backupDir);
            if (strcmp(filesep,'\'))
                fname=char(regexp(fname,['[^\' filesep ']*$'],'match')); %escape if necessary
            else
                fname=char(regexp(fname,['[^' filesep ']*$'],'match'));
            end
            newName=char(regexprep(fname,'.csv','.backup'));
            oldFullName=strjoin('',backupDir, filesep, fname);
            newFullName=strjoin('',backupDir, filesep, newName);
            x=movefile(oldFullName,newFullName);
        else
            cloutput('Backup directory not found. No data backup was made.') 
        end

        %log session closing
        logData('DataFileEnded');
    end
    
    %clear global variables set by beginNewDataFile
    clear global OUTPUT_FILE_ID CONFIG;
    
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>