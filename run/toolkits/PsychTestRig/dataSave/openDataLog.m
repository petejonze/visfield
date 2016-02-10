function fileID=openDataLog(dataDir,expID)
%OPENDATALOG description.
%
% desc
%
% Example: none
%
% See also startDataSession writeData finishDataSession

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('dataDir', @ischar);
    p.addRequired('expID', @ischar);
    p.FunctionName = 'OPENDATALOG';
    p.parse(dataDir,expID);
    %----------------------------------------------------------------------
   	global DATALOG_FILE_ID; 
    %----------------------------------------------------------------------

    %check that we are good to go
    if ~exist(dataDir,'dir')
        error(['master data dir "' dataDir '" cannot be found. Cannot open data log!'])
    end

    %initialise local variables
    dataDir=[getPrefVal('homeDir') filesep expID filesep 'data'];
    dataLogFileName = [dataDir filesep expID '-dataLog.txt'];

    %open file
  	fileID = fopen(dataLogFileName,'a'); %append mode: puts the file pointer at the end of the file and doesn't let you fseek earlier positions

 	%initialise global variables for other functions
    DATALOG_FILE_ID = fileID;    %for: <see startDataGatheringPeriod>       
    
    %log data log being opened!
    logData('dataLogOpened');
    
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>

    