function varargout=runExperiment(varargin)
%RUNEXPERIMENT shortdescr.
%
% Description
%
% Example: none
%
% See also
% 
% @Author:          Pete R Jones
%
% @Creation Date:	22/01/10
% @Last Update:     28/03/10
%
% runExperiment % pick experiment from list
% runExperiment(ID) %pick config from list
% runExperiment(ID, config)
% runExperiment(ID, config1, config2, config3, etc.) %participant defined / random 1 / random m / x in sequence / x in random sequence / random with replacement?/without replacement?
% 
%Display instructions?
%checklists?
%ancillary info?
%
% 28/03/10: changed rand('SEED'..), to setting the random stream [v2008+
% only, but this way ensures that all random number generators are seeded]
 %  - now expect randSeed in config, not randSeedState
   
 
    %----------------------------------------------------------------------
    % Parse & validate all input args
    %
    %remove all initial dashes, e.g. -partID => partID. USE WITH CARE!!!
    idx = ~cellfun(@iscell,varargin);
    tmp = regexprep(varargin(idx),'^-',''); 
    varargin(idx) = tmp;
    % parse
    p = inputParser;
    p.addOptional('experimentID', [], @ischar);
    p.addParamValue('select', [], @(x)isPositiveInt(str2num(x)));
    p.addParamValue('method', 'inOrder', @(x)any(strcmpi(x,{'randomWithReplacement','randomWithoutReplacement','inOrder'})));
    p.addParamValue('from', '', @(x)ischar(x) | iscellstr(x));
    p.addParamValue('pid', '', @(x)isPositiveInt(str2num(x)));
    p.addParamValue('sid', '', @(x)isPositiveInt(str2num(x)));
    p.addParamValue('autoStart', false, @(x)islogical(any2log(x)));
    p.addParamValue('skipLogin', false, @(x)islogical(any2log(x)));
    p.FunctionName = 'RUNEXPERIMENT';
    p.parse(varargin{:});
    %----------------------------------------------------------------------
    expID                	= p.Results.experimentID;
    configIDs               = p.Results.from;
    configSelectionMethod   = p.Results.method;
    configSelectionNumber   = any2num(p.Results.select); 
    partID                  = str2num(p.Results.pid);
    sessID                	= str2num(p.Results.sid);
    autoStart              	= any2log(p.Results.autoStart);
    skipLogin              	= any2log(p.Results.skipLogin);
    %----------------------------------------------------------------------
   	useDb=getPrefVal('useDb'); 
    %----------------------------------------------------------------------
    if ischar(configIDs)
        configIDs = strtrim(configIDs);
        if ~isempty(regexp(configIDs, '^{[\w\s,]+}$', 'match')) % e.g. ptr -run xxxx -from {cfg1, cfg2, cfg3}
            configIDs = regexp(configIDs(2:end-1), '[,\s]+', 'split');
        end
    end
    if ~iscell(configIDs)
        configIDs = {configIDs};
    end
    if isempty(configSelectionNumber)
        configSelectionNumber = length(configIDs);
    end
    %----------------------------------------------------------------------
    
    tic();
       
    % do basic initiation 
    sub_initialise();
    
    %Check that we are good to go
    ensurePsychTestRigSetup();
    backupDir=getPrefVal('backupDir'); % this should be largely redundant given the checks from ensurePsychTestRigSetup()
    if (~exist(backupDir,'dir'))
        cloutput('\n/*****Warning: backup directory not found. Data backups will not be made. Either quit and run "PsychTestRig -setup", or continue at your own risk.*****/')
        if ~getLogicalInput('Continue? (y/n) ')
           error('Script terminated by user') 
        end
    end

    % Initialise local variables (1)
    if isempty(expID)
        expID = getExpID();
    else
     	if ~isValidExpID(expID)
            msg=[   '/*****\n' ...
                    'Specified experiment invalid: ' escape([getPrefVal('homeDir') filesep expID]) '\n\n' ...
                    'Specify a different experiment,\n' ...
                    'or create a new experiment by using "createNewExperiment"\n' ...
                    '*****/' ...
             	];
            error('PsychTestRig:runExperiment:invalidExp',msg);
     	end
    end
    
    % change directory to the experiment's 'code' directory, save the
	% current working directory so that it can be restored later
 	dirAtRuntime=pwd;
    expDir = fullfile(getPrefVal('homeDir'), expID);
    codeDir = fullfile(expDir, 'run', 'code');
	cd(codeDir);      
    
%  	if isempty(configIDs)
    if strcmp(configIDs,'')
        configIDs = getConfigIDs(expID);
    else
        if ~isValidConfigIDs(expID,configIDs)
            msg=[   '/*****\n' ...
                'The specified name(s) of one or config file is invalid: {' escape(strjoin(',',configIDs{:})) '}\n\n' ...
                'Please ammend before trying again\n' ...
                '*****/' ...
                ];
            error('PsychTestRig:runExperiment:invalidExp',msg);
        end
    end
    
    cloutput('\nAttempting to retrieve info from config file(s)...')
    configSet = getConfigs(expID,configIDs);
    cloutput('...success!\n')
    
    %establish configs to use
    %randsample uses rand, so have to set random seed (though will do so
    %formally below)
    try
        myRandStream = RandStream('mt19937ar','Seed',sum(100*clock));
        RandStream.setGlobalStream(myRandStream);
    catch %#ok
        rand('twister',sum(100*clock)); %#ok
    end
    switch configSelectionMethod
        case ('inOrder')
            configs=configSet(1:configSelectionNumber);
        case ('randomWithReplacement')
            rs=randsample(length(configIDs),configSelectionNumber,true); %replace=true
            configs=configSet(rs);
      	case ('randomWithoutReplacement')
            rs=randsample(length(configIDs),configSelectionNumber,false); %replace=false
            configs=configSet(rs);
        otherwise
            error('PsychTestRig:runExperiment:unknownConfigSelectionMethod',['Unknown config selection method: "' configSelectionMethod '".'])
    end
   
    try %wrap in try..catch to ensure that we will always properly finish up
        % loginParticipant
        if ~skipLogin
            [partID,partInfo]=loginParticipant(expID, partID); % partID may be empty
        else
            partInfo = [];
            if isempty(partID)
                warning('run:noPid','No partID detected. Substituting 9999');
                partID = 9999;
            end
        end
        
        % etablish session number
        if isempty(sessID)
            %fprintf('\n----------------------------------------------------------------\n')
            fprintf('\n');
            sessID=getSessionID(expID,partID); % needs work (as above)
            %fprintf('----------------------------------------------------------------\n')
        end

        % open log etc.
        startDataGatheringPeriod(expID,partID,sessID)
        
        %Display meta-instructions
        %??????????????????????????????????????????????????????
        
        % prep screen [cancelled: (white screen, press return to begin)]
        if ~autoStart
            input('\npress RETURN to launch the experiment\n');
        end
        
        for i=1:configSelectionNumber
             
            % get config (config set randomly shuffled previously if necessary)
            cfg=configs{i};

            % record basic parameters
            metaParams = [];
            metaParams.partID = partID;
            metaParams.partInfo = partInfo;
            metaParams.sessID = sessID;
            metaParams.expID = expID;
            metaParams.cfgID = cfg.id;
            metaParams.dir = expDir;
            
            % start new experimental session
            if isfield(cfg,'randSeed') && ~isempty(cfg.randSeed)
              	initialSeed = cfg.randSeed;
                % rand('twister',cfg.randSeedState); %get,set [OLD]
            else
               	initialSeed=sum(100*clock);
                % rand('twister',initialSeed);
                cfg.randSeed = initialSeed; %set,get
            end
            % NEW: set new default random stream (can later modify the
            % state if required by setting the defaultStream.State)
            try
                myRandStream = RandStream('mt19937ar','Seed',initialSeed);
                RandStream.setGlobalStream(myRandStream);
            catch %#ok
                rand('twister',initialSeed);  %#ok implicitly seeds randi also
                randn('state',initialSeed); %#ok
            end
                
          	% show config
            fprintf('\n----------------------------------------------------------------\n\n')
            dispStruct(cfg);
            fprintf('----------------------------------------------------------------\n')
            fprintf('================================================================\n\n')
            
        	% Check whether the user has remember to issue a save
            % command in the script
           	functions = depfun(cfg.script,'-toponly', '-quiet');
            % n.b. this may produce Segmentation Violations if trying to
            % insantiate class objects using syntax not supported by your
            % version of Matlab (e.g., trying to use Abstract classes in
            % pre 2012)
            
            ok = 0;
            for j = 1:length(functions);
                [tmp,fname,tmp] = fileparts(functions{j}); %#ok
                if strcmpi(fname,'writeData');
                    ok = 1;
                    break;
                end
            end
            if ~ok
                cloutput('\n/*****Warning: writeData not called in experiment script. This warning can be manually disabled in runExperiment.m*****/')
                if ~getLogicalInput('Continue? (y/n) ')
                    error('Script terminated by user')
                end
            end
            
            % startNewDataSession
            beginNewDataFile(cfg);
                
            try
                script=regexprep(cfg.script,'.m$',''); %discard '.m' file extension (if one specified)
                if isempty(cfg.params)
                    params = {''};  %#ok
                else
                    params=struct2cell(cfg.params);  %#ok
                end
                % !!!! RUN !!!!
                % see http://blogs.mathworks.com/loren/2009/04/14/convenient-nargout-behavior/
                [varargout{1:nargout(sprintf('%s',script))}] = eval([script '(metaParams,params{:})']); %!!!!!RUN EXPERIMENT!!!!!
                %Function handles instead of eval?
            catch ME
                
                if isempty(ME.message)
                    ME.message='<No error message returned. Error in C file(??)>';
                end
                if isempty(ME.stack)
                    ME.stack=struct('dummyField','<No stack trace returned. Error in C file(??)>');
                end
                
                if isCurrentDataFile() % if a data file is open
                    abortCurrentDataFile(ME);
                end
                                
               	myErr=  [   '/*****\n' ...
                            '!!!Experiment failed!!!\n\n' ...
                            'Matlab encountered a fatal error during the experiment script.\n\n' ...
                            '   The following error message was produced:\n' ...
                            '      ' regexprep(strtrim(escape(ME.message)),'\\\\n','\\n  ') '\n\n' ...
                            '   It originated from:\n' ...
                            ['      ' regexprep(strtrim(escape(struct2String(ME.stack))),'\\\\n','\\n  ') '\n'] ... %regexprep to unescape any newline characters returned from struct2String
                            'The data file was aborted and moved to __TRASH\n' ...
                            '*****/' ...
                        ];   
                    tmp = struct();
                    tmp.errorStack = ME.stack;
                    dispStruct(tmp);
                    
                error('PsychTestRig:runExperiment:experimentFailed',myErr); %'rethrow-plus-some' 
                %!!!! NEED TO ADD MORE INFO ABOUT WHERE THE ERROR ORIGINATED FROM!!!!!
            end

            %WaitSecs(0.5); %need this during testing to make sure that files don't overwrite each other when sessions are spaced only a few milliseconds apart
            
            if isCurrentDataFile()
                endCurrentDataFile(); %(n.b. will not get this far if an error was caught above - though should really be in an 'else' clause if matlab supported such things)
                iterateBlockNum();
            else
                warning('No active data file from that session? Did you forget to write any data??')
                frpintf('\n\n\n\n!!!!!!!No active data file from that session? Did you forget to write any data?? !!!!!!!\n\n\n\n\n')
            end
        end
        
        fprintf('\n================================================================')
        fprintf('\n----------------------------------------------------------------\n\n')
        
        % return Matlab to prior state
        cd(dirAtRuntime);
        
        % close log etc.
        stopDataGatheringPeriod();
        
        %logoffParticipant?
        
%Summary statistics??????????????????

%DIALOG(???????????????)

    catch ME
        sub_finishUp();
        rethrow(ME); 
    end
    
    
    % finishUp
    sub_finishUp();
    toc();


    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%

    preexistingWarnState;
    
    function sub_initialise()
        % clear java memory (memory leaks may otherwise accumulate causing sluggish performance)
%         javaaddpath(which('MatlabGarbageCollector.jar'));
%         jheapcl();
%         clearJavaMem();
        
        clall();	
        preexistingWarnState=warning('query', 'backtrace'); %save for later
        warning on backtrace; %ensure that backtrace disabled (if not already)
        if useDb %if use a database
            connectToDB(true,true); %defensive: make sure there is a connection by opening a new one. But open silently, and open on top of any existing connection so that when we close the connection at the end we don't prevent the script that called this function from working
        end
    end

    function sub_finishUp()
        warning(preexistingWarnState); % return to how matlab was setup before PsychTestRig was run
        if useDb
            disconnectFromDB();
        end    

        clearJavaMem();
    end
     
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>