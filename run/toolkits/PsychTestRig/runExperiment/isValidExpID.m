function isValid=isValidExpID(expID,varargin)
%ISVALIDEXPID description.
%
% .... checks experiment is valid
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 01/02/2011

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addOptional('showWarning', true, @islogical);
    p.FunctionName = 'ISVALIDEXPID';
    p.parse(expID,varargin{:}); % Parse & validate all input args
    %----------------------------------------------------------------------
    showWarning = p.Results.showWarning;
    %----------------------------------------------------------------------
    
    % Initialise local variables
   	exps=getDirs(getPrefVal('homeDir'),true);
    
    % Check that exp subdir is present in experiment parent directory
  	if (~ismember(expID,exps)) 
        if showWarning
            msg=escape(['Experiment directory not found: ' getPrefVal('homeDir') filesep expID]);
            warning('PsychTestRig:invalidExpID',msg);
        end
        isValid = false;
    else
        isValid=true;
    end
    
end