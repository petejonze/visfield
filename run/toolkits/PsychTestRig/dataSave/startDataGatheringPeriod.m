function startDataGatheringPeriod(expID, partID, sessID)
%STARTDATAGATHERINGPERIOD description.
%
% desc
%
% Example: none
%
% See also

%warning('startDataGatheringPeriod:missingFunctionality','aborting the data files from non-current files in this session not yet available')

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addRequired('partID', @isPositiveInt);
    p.addRequired('sessID', @isPositiveInt);
    p.FunctionName = 'STARTDATAGATHERINGPERIOD';
    p.parse(expID,partID,sessID); % Parse & validate all input args
    %----------------------------------------------------------------------
    global DATAGATHERING_BEGUN EXP_ID PART_ID SESS_ID BLOCK_NUM OUTPUT_PART_DATADIR EXP_HOMEDIR; 
    %----------------------------------------------------------------------

    %check that we are good to go
%     if ~isValidConfig(cfg)
%         error('PsychTestRig:startNewDataSession:invalidConfig',['Invalid Config: ' cfg.id])
%     end
    
    %initialise local variables
	homeDir=getPrefVal('homeDir');
    expHomeDir=[homeDir filesep expID];
    dataDir=[expHomeDir filesep 'data'];
        
    %ensure participant data subdirectory exists (defensive, since already
    %should have checked this in loginParticipant
    partDataDir = login_ensurePartDataDir(expID, partID);
    
    %check whether dataLog is present, if not then create it
    if ~isDataLogPresent(dataDir,expID)
        createDataLog(dataDir,expID);
    end
    openDataLog(dataDir,expID);

    %initialise global variables for other functions
    DATAGATHERING_BEGUN = true;             %for: beginNewDataFile, PTR_getCurrentExpInfo (ought to be used by more? or none!)
    EXP_ID = expID;                         %for: beginNewDataFile, PTR_getCurrentExpInfo
    PART_ID = partID;                       %for: beginNewDataFile, PTR_getCurrentExpInfo
    SESS_ID = sessID;                       %for: beginNewDataFile, iterateSessionNum, PTR_getCurrentExpInfo
    BLOCK_NUM = 1;                          %for: beginNewDataFile, iterateSessionNum, iterateBlockNum
    OUTPUT_PART_DATADIR = partDataDir;    	%for: beginNewDataFile, abortCurrentDataFile, PTR_getCurrentExpInfo
    EXP_HOMEDIR = expHomeDir;               %for: PTR_getCurrentExpInfo.
    
    
    %NUM_OF_OUTPUTS = 0;                    %for: writeData, endCurrentDataFile. Set by beginNewDataFile 
    %DATALOG_FILE_ID = dataLogFileID;       %for: logData, closeDataLog. Set by openDataLog
	%OUTPUT_FILE_ID = fileID;               %for: writeData, writeWarningMsg, writeErrorMsg, writeNote, endCurrentDataFile, abortCurrentDataFile. Set by beginNewDataFile
    %CONFIG = cfg;                          %for: newSession, newBlock. Set by beginNewDataFile


    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>