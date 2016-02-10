function cfgIDs=getConfigIDs(expID, i)
%GETCONFIGIDS description.
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
    p.FunctionName = 'GETCONFIGIDS';
    p.parse(expID); % Parse & validate all input args
    %----------------------------------------------------------------------
        
    % parse inputs
    if nargin < 2
        i = [];
    else
       i = num2str(i); 
    end
    
    % Check that good to go
    if ~isValidExpID(expID)
        error('PsychTestRig:getConfigIDs:invalidExpID',['Invalid Experiment ID: ' expID])
    end
    
    % Initialise local variables (1)
    expDir = fullfile(getPrefVal('homeDir'), expID);
    configDir = fullfile(expDir, 'run', 'configs');
    
   	%check that the configs subdirectory exists
  	if ~exist(configDir,'dir')
        error('PsychTestRig:getConfigIDs:configDirNotFound',['/*****Configs directory not found:\n\n   ' escape(configDir) '\n\n*****/'])
	end
        
    
    % Initialise local variables (2)
    possible_cfgFiles = dir([configDir filesep '*.expConfig.xml']); %retrieve the available config files
    possible_cfgs = {possible_cfgFiles.name};
    checks = cellfun(@(cfgID)isValidConfigID(expID, cfgID),possible_cfgs);
    cfgs = possible_cfgs(checks==1); % create cell containing only valid config files
    

  	% Ensure that some input options exist
    if (size(cfgs,2) == 0)
         	msg=[   '/*****\n' ...
                    'No config files manually specified, and none found in the expected directory:\n\n' ...
                    escape(configDir) '\n\n'...
                    'Remember, this program only accepts config files with names ending ".exConfig.xml" (e.g. config.exConfig.xml)\n' ...
                    '*****/' ...
             	];
            error('PsychTestRig:runExperiment:getConfigIDs:emptyCfgSubdir',msg);
    end
    
    
    
    if isempty(i)
        
        % Display input options
        cloutput('\nConfigs:')
        x = {size(cfgs,2)};
        for i = 1:size(cfgs,2)
            disp(['   [' num2str(i) ']   ' cfgs{i}]) %disp not cloutput, since don't want wrapping. n.b. disp([i exps(i)]); would be neater, but forces long cell strings to be shown as, e.g. '[1 x 26 char]'
            x{i} = num2str(i);
        end
        cloutput(' ')
        
        
        % Prompt user for input
        i=get1ofMInput('The number of the config: ',x);
        cloutput('(n.b. see "help runExperiment" for how to avoid that prompt/specify mulitple config files)\n')
        
    end
    
    % Return input value
  	cfgIDs={cfgs{str2num(i)}};
    
    
   	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    % <blank>
          
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
% <blank>