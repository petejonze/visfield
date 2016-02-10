function expID=getExpID()
%GETEXPID description.
%
% desc
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    % Check that good to go
    % <blank>
    
    % Initialise local variables
    possible_exps=getDirs(getPrefVal('homeDir'),true); % cell of all subdirs
    checks = cellfun(@isValidExpID, possible_exps);
    exps = possible_exps(checks==1); % cell of only valid exp subdirs
    
    
    % Ensure that some input options exist
    if (size(exps,2) == 0)
         	msg=[   '/*****\n' ...
                    'No experiments manually specified, and none found in the home directory\n' ...
                    'Home: ' escape(getPrefVal('homeDir')) '\n\n'...
                    'modify your home directory by running "PsychTestRig -setup",\n' ...
                    'or create a new experiment by using "createNewExperiment"\n' ...
                    '*****/' ...
             	];
            error('PsychTestRig:runExperiment:getExpID:emptyExpSubdir',msg);
    end
    
    % Display input options
    cloutput('\nExperiments:')
    x = {size(exps,2)};
    for i = 1:size(exps,2)
        disp(['   [' num2str(i) ']   ' exps{i}]) %disp not cloutput, since don't want wrapping. n.b. disp([i exps(i)]); would be neater, but forces long cell strings to be shown as, e.g. '[1 x 26 char]'
        x{i} = num2str(i);
    end
	cloutput(' ')
         
    % Prompt user for input
    i=get1ofMInput('The number of the experiment: ',x);
    cloutput('(n.b. see "help runExperiment" for how to avoid that prompt)\n')
    
    % Return input value
    expID=exps{str2num(i)};
    
   	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    % <blank>

end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
% <blank>