function fileName = beginNewDataFile(cfg)
%BEGINNEWDATAFILE description.
%
% desc
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('cfg', @isstruct);
    p.FunctionName = 'BEGINNEWDATAFILE';
    p.parse(cfg); % Parse & validate all input args
    %----------------------------------------------------------------------
    ext='csv';
    %----------------------------------------------------------------------
    global DATAGATHERING_BEGUN EXP_ID PART_ID SESS_ID BLOCK_NUM OUTPUT_PART_DATADIR; %to get
    global OUTPUT_FILE_ID CONFIG NUM_OF_OUTPUTS;                                     %to set
    global OUTPUT_FILE_NAME %new
    %----------------------------------------------------------------------

    %check that we are good to go
    if isempty(DATAGATHERING_BEGUN) || ~DATAGATHERING_BEGUN
        error('PsychTestRig:beginNewDataFile:inactiveDataGatheringPeriod','Data gathering period is not active. You must call startDataGatheringPeriod before this script will work!')  
    end
    if ~isempty(OUTPUT_FILE_ID)
         error('PsychTestRig:beginNewDataFile:fileAlreadyOpen','Data file is already open. You must call endCurrentDataFile before this script will work!')  
    end

    %initialise local variables
    expID = EXP_ID;
    partID = PART_ID;
    sessID = SESS_ID;
    blockNum = BLOCK_NUM;
    timeNow = datestr(now,30);
    partDataDir = OUTPUT_PART_DATADIR;
    strCfg = local_stringify(cfg);
    
    %construct file name
    fn=sprintf('%s-%i-%i-%i-%s',expID,partID,sessID,blockNum,timeNow);

    %create file
    fileName=mkfile([partDataDir filesep fn '.' ext]);
    
    try
        %construct header info
        headerInfo =    {  
                            '/*****HEADER INFORMATION*****/',...
                            strjoin(',', 'Experiment ID:',expID),...
                            strjoin(',', 'Participant ID:',num2str(partID)),...
                            strjoin(',', 'Session ID:',num2str(sessID)),...
                            strjoin(',', 'Block Num:',num2str(blockNum)),...
                            strjoin(',', 'Config ID:',cfg.id),...
                            strjoin(',', 'Manual ID:',''),...
                            '',...
                            strjoin(',', 'Creation Date:',datestr(now,31)),...
                            strjoin(',', 'End Date:',''),...
                            '',...
                            strjoin(',', 'Config:',strCfg),...
                            strjoin(',', 'Notes:',''),...
                            strjoin(',', 'Warnings:',''),...
                            strjoin(',', 'Errors:',''),...
                            '',...
                            '/*****DATA*****/',...
                        };

        %write header info
        newline=getNewline();
        if (strcmpi(ext,'csv'))
            fileID = fopen(fileName,'w+');
            for i=1:size(headerInfo,2)
                fprintf(fileID, '%s', headerInfo{i}); % Matlab strings are really arrays, and csvwrite puts array elements into seperate cells. The usual trick to writing out strings in a CSV file is to set the cell delimiter to be empty, and to explicitly write out commas where-ever you need them to seperate cells. 
                fwrite(fileID, newline, 'char'); % terminate this line
            end
            %fclose(fid); %leave file open for further outputing
        else
            error('PsychTestRig:beginNewDataFile:invalidFileExtension','File extension must be ''csv''.');
        end
    catch
        ME=lasterror;
        delete([partDataDir filesep fn '.' ext]); %clean up
        myErr=  [   '/*****Failed to create new data file.*****/\n\n' ...
                    '   The following error message was produced:\n' ...
                    '      ' ME.message '\n\n' ...
                    '   It originated from:\n' ...
                    ['      ' regexprep(strtrim(escape(struct2String(ME.stack))),'\\\\n','\\n  ') '\n'] ... %regexprep to unescape any newline characters returned from struct2String
                    'Any traces of the data file were deleted\n' ...
                    '*****/' ...
                ];   
        error('PsychTestRig:beginNewDataFile:fileCreationFailure',myErr); %'rethrow-plus-some'      
    end

    %initialise global variables for other functions
    OUTPUT_FILE_ID = fileID;    %for: <see startDataGatheringPeriod>       
    CONFIG = cfg;               %for: <see startDataGatheringPeriod>  
    NUM_OF_OUTPUTS = 0;         %for: <see startDataGatheringPeriod>
    OUTPUT_FILE_NAME = fileName;%for: getOutputFn
    
    %log session closing
    infoToBeLogged = sprintf('Experiment: %s - Participant: %i - Session: %i - Config: %s', expID, partID, sessID, cfg.id);
   	logData('DataFileStarted',infoToBeLogged);
    
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
   
           
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%

function neatCfg=local_stringify(cfg)
    rawCfg=struct2String(cfg);
    neatCfg=regexprep(rawCfg,',',';'); % replace all commas with semi-colons (since we are using CSV)
    %neatCfg=regexprep(rawCfg,escape(getNewline()),[escape(getNewline()) ',']); % make every new row start with a comma
end