function varargout = PsychTestRig(varargin)
%PSYCHTESTRIG toolkit for running experiments (running scripts, loading
%preferences, maintaining participant records, saving data, etc.)
%
%   <WRITE ME>
%
% @Requires the following toolkits: <none>
%                                   
% @Parameters:  
%
%    	flag     	Char.       A flag specifying an action to perform.
%                               Many of these call further functions which 
%                               can also be called directly. The valid 
%                               flags are:
%                                       -setup
%                                       -viewSetup                               
%                                       -checkSetup 
%                                       -createExp
%                                       -run
%                               e.g. PsychTestRig -setup
%
% @Returns:  
%
%    	<none>
%
%
% @Examples:     	PsychTestRig;
%                   PsychTestRig -run SummerScientist2010 from config.expConfig.xml -partID 3 -sessID 1;
%
% @See also:        <none>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	01/01/10
% @Last Update:     04/06/11
%
% @Todo:            Lots!
%
% @Version:         0.7 

    % no input, show help text
    if nargin==0
        help PsychTestRig
        return
    end
    
    % else do something
    count = 1;
    while (count <= nargin)
        arg = varargin{count};
        n = length(arg);
        if strncmpi(arg, '-setup', n)
            if count < nargin
                inputArgs = {varargin{count+1:end}};
                setupPsychTestRig(inputArgs{:});
            else
                setupPsychTestRig();
            end
            return
        elseif strncmpi(arg, '-viewSetup', n)
            viewSetup();
            return
        elseif strncmpi(arg, '-checkSetup', n)
            [varargout{1:nargout('checkSetup')}] = checkSetup(getPrefVal());
            return
     	elseif strncmpi(arg, '-clearSetup', n)
            clearSetup;
            return
        elseif strncmpi(arg, '-createExp', n)
            if count < nargin
                createNewExperiment(varargin{count+1})
            else
                createNewExperiment()
            end
            return
       	elseif strncmpi(arg, '-run', n)
            if count < nargin
                inputArgs = {varargin{count+1:end}};
                inputArgs = any2str(inputArgs); % convert any numeric inputs into strings
                [varargout{1:nargout('runExperiment')}] = runExperiment(inputArgs{:});
            else
                [varargout{1:nargout('runExperiment')}] = runExperiment();
            end
            return
        else
            error('PsychTestRig:UnrecognisedInput','The input "%s" is not recognised.\nPlease type "PsychTestRig" for a list of valid commands',arg);
        end
        count = count + 1;
    end

end
