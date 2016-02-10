function rmPrefVal(varargin)
%RMPREFVAL A simple wrapper for getpref.
%
% desc.
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addOptional('pref', 'unset', @ischar);
    p.FunctionName = 'RMPREFVAL';
    p.parse(varargin{:}); % Parse & validate all input args
    pref = p.Results.pref;
    %----------------------------------------------------------------------
    
    %initialise local variables
    group='PsychTestRig_prefs';
    
    if isempty(getpref(group))
       return; %already empty
    else
        try
            if strcmp(pref,'unset')
                rmpref(group);%remove all prefs
            else
                rmpref(group,pref);%remove specific pref
            end
        catch
            myErr = lasterr; %Probably because a variable was specified and doesn't exist - could say as such????
            myErr = ['\n/*****\nOh dear, the program failed to remove a variable.\nTry running "PsychTestRig -setup" again\n*****/\n\n' myErr];
            error(myErr,'x') 
        end
    end
end

