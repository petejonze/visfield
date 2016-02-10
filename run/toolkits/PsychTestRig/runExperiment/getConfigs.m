function cfgs=getConfigs(expID,cfgIDs)
%GETCONFIGS description.
%
% desc
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addRequired('cfgIDs', @(x)iscellstr(x));
    p.FunctionName = 'GETCONFIGS';
    p.parse(expID,cfgIDs); % Parse & validate all input args
    %----------------------------------------------------------------------
        
    % Check that good to go
    if ~isValidExpID(expID)
        error('PsychTestRig:getConfigs:invalidExpID',['Invalid Experiment ID: ' expID])
    end
    if ~isValidConfigIDs(expID,cfgIDs)
        error('PsychTestRig:getConfigs:invalidConfigID',['Invalid config ID(s): ' strjoin(',',cfgIDs{:}) ' (for Exp: ' expID ')'])
    end
       
    % Initialise local variables
    expDir=[getPrefVal('homeDir') filesep expID];
    configDir=[expDir filesep 'run' filesep 'configs'];
    numConfigs=length(cfgIDs);
    

    %check that the configs subdirectory exists
    if ~exist(configDir,'dir')
        error('PsychTestRig:getConfigs:configDirNotFound',['/*****Configs directory not found:\n\n   ' escape(configDir) '\n\n*****/'])
    end


    % Run!
    cloutput('   Checking syntax/structure...')
    checks = zeros(size(numConfigs));
    possible_cfgs=cell(size(numConfigs));
    for i=1:numConfigs
        %warning('PsychTestRig:getConfigs','In progress - finish me!!!')
        
        cfgID = [cfgIDs{i} '.expConfig.xml']; %append file extention (in case user forgot to specifiy)
        cfgID=regexprep(cfgID,'.expConfig.xml.expConfig.xml\>','.expConfig.xml'); %remove file extention strings if already had it
        cfgID=regexprep(cfgID,'.expConfig.expConfig.xml\>','.expConfig.xml'); % now '.expConfig' is also optional
        [cfgInfo,ok] = loadConfig(cfgID,configDir);
        checks(i) = ok;
        
        if isfield(cfgInfo,'randSeed')
            randSeed = cfgInfo.randSeed;
        else
            randSeed = [];
        end
        
        if ok %if not then will fatally fail below anyway
            
            if isfield(cfgInfo,'params')
                params = cfgInfo.params;
            else
                params = [];
            end
            
            cfg = struct(       'id',           cfgID,...
                                'script',       cfgInfo.script,...
                                'ptrVersion',   cfgInfo.ptrVersion,...
                                'randSeed',     randSeed,...
                                'params',       params);
            possible_cfgs{i} = cfg;
        end
  
    end
    
    % syntactic validate
    if any(checks==0)
        disp(' '); %add blank line for clarity
        invalidCfgs = cfgIDs(checks==0);
        msg=[   '/*****\n' ...
            'Syntactic Error: The structures of the following config file(s) are invalid:\n' ...
            '   ' escape(strjoin(',',invalidCfgs{:})) '\n\n'...
            'See breakdown above for details' '\n'...
            '*****/' ...
        ];
        error('PsychTestRig:runExperiment:getConfigs:invalidConfig',msg);  
    end
    cloutput('   ...done')
    
    % semantic validate
    cloutput('   Checking semantics/content...')
    checks = cellfun(@(cfg)isValidConfig(cfg),possible_cfgs);
    if any(checks==0)
            disp(' '); %add blank line for clarity
            invalidCfgs = cfgIDs(checks==0);
         	msg=[   '/*****\n' ...
                    'Semantic Error: The contents of the following config file(s) are invalid:\n' ...
                    '   ' escape(strjoin(',',invalidCfgs{:})) '\n\n'...
                    'See breakdown above for details' '\n'...
                    '*****/' ...
             	];
            error('PsychTestRig:runExperiment:getConfigs:invalidConfig',msg);
    end
    cloutput('   ...done')
    
    cfgs = possible_cfgs; %else if all good
    
    
   	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    % <blank>

end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
% <blank>

