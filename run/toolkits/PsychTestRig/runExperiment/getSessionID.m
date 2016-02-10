function sessID=getSessionID(expID,partID)%,varargin)
%GETSESSIONID description.
%
% desc
%
% Example: none
%
% See also


    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID'); % , @ischar); is validated below
    p.addRequired('partID'); %, @isPositiveInt); is validated below
    p.FunctionName = 'STARTNEWDATASESSION';
    p.parse(expID, partID); % Parse & validate all input args
    %----------------------------------------------------------------------
    %inFullMode=strcmpi(getPrefVal('mode'),'full');
    %----------------------------------------------------------------------
        
% % %     if (inFullMode) %if running in full mode
% % %         connectToDB(true,true); %defensive: make sure there is a connection by opening a new one. But open silently, and open on top of any existing connection so that when we close the connection at the end we don't prevent the script that called this function from working
% % %     end
    
    
    % Check good to go
    if ~isValidExpID(expID)
        error('PsychTestRig:getSessionID:invalidExpID',['Invalid Experiment ID: ' expID])
    end
    if ~isValidPartID(expID, partID)
        error('PsychTestRig:getSessionID:invalidPartID',['Invalid Participant ID: ' partID ' (for Exp: ' expID ')'])
    end
    
    % Initialise local variables (1)
    expDir=[getPrefVal('homeDir') filesep expID];
    partDataDir=[expDir filesep 'data' filesep partID];
    
    
    % Run - estimate session ID based on most recent file in folder, then
    % present the user with the estimate and a choice to override/edit
    existingDataFiles=dir([partDataDir filesep '*.csv']); %retrieve the names of all the .csv results files
    %sessID=length(existingDataFiles)+1;
    %sessID=num2str(getIntegerInput(['Session ID (suggested = ' int2str(sessID) '): ']))
    
    if isempty(existingDataFiles)
        sessIDEstimate = 1;
    else
        [dx,dx] = sort([existingDataFiles.datenum],'descend');
        newestFile = existingDataFiles(dx(1)).name;
        newestFileSessID = regexp(newestFile,['(?<=' expID '-' partID '-).+(?=-\d+-)'],'match');
        if isempty(newestFileSessID) %e.g. if most recent csv file isn't actually a well-formated data file such as 'dsfdsfdf.csv'
            sessIDEstimate = '';
        else
            sessIDEstimate = 1 + str2double(newestFileSessID{1});
        end
    end
    
    if isempty(sessIDEstimate)
        sessID=getIntegerInput('Session ID: ');    
    else
        sessID=getIntegerInput(['Session ID (suggested = ' int2str(sessIDEstimate) '): ']);  
    end
    
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>