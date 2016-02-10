function prefVal = getPrefVal(varargin)
%GETPREFVAL A simple wrapper for getpref.
%
% desc.
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addOptional('pref', 'unset', @ischar);
    p.addOptional('isOptional', false, @islogical);
    p.FunctionName = 'GETPREFVAL';
    p.parse(varargin{:}); % Parse & validate all input args
    pref = p.Results.pref;
    isOptional = p.Results.isOptional;
    %----------------------------------------------------------------------
    
    %initialise local variables
    group='PsychTestRig_prefs';
    
    %try to retrieve value
    try
     	if strcmp(pref,'unset')
            prefVal=getpref(group); %get all prefs
        else %get specific pref
        	prefStruct = getpref(group);
            prefVal = getStructVal(prefStruct,pref);
% ALT:
%         	if regexp(pref,'\.') %if the pref name contains a '.' we shall assume the user is trying to access an item inside a structure.
%                 r=regexp(pref,'\.','split','once');
%                 parentStruct = getpref(group,r{1}); %retrieve structure as new structure
%                 prefVal = eval(['parentStruct.' r{2} ';']); %get item
%             else
%                 prefVal=getpref(group,pref); %else simply treat 'pref' as a field name
%             end
        end
    catch
        if (isOptional)
            prefVal='';
        else
            myErr = lasterr;
            myErr = ['\n/*****\nOh dear, the program cannot find one of your setup variables.\nTry running "PsychTestRig -setup" again\n*****/\n\n' myErr]; 
            error(myErr,'x') 
        end
    end
end