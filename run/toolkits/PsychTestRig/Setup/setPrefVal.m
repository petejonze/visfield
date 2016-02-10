function setPrefVal(pref,prefVal)
%SETPREFVAL A simple wrapper for getpref.
%
% desc.
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('pref', @ischar);
    p.addRequired('prefVal');
    p.FunctionName = 'SETPREFVAL';
    p.parse(pref,prefVal); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    %initialise local variables
    group='PsychTestRig_prefs';
    
    %try to set value
    %try
        prefStruct = getpref(group);
        if isempty(prefStruct)
            prefStruct = struct;
        end
        newPrefStruct = setStructVal(prefStruct,pref,prefVal);
        setpref(group, fieldnames(newPrefStruct),struct2cell(newPrefStruct));
% ALT:
%         if regexp(pref,'\.') %if the pref name contains a '.' we shall assume the user is trying to access an item inside a structure.
%             r=regexp(pref,'\.','split','once');
%             parentStruct = getPrefVal(r{1},true); %retrieve structure as new structure if available
%             eval(['parentStruct.' r{2} ' = prefVal;']); %modify new structure
%             setpref(group,r{1},parentStruct); % reinsert new structure into preferences   
%         else
%             setpref(group,pref,prefVal); %else simply treat 'pref' as a field name
%         end     
        setpref(group,'lastUpdate',datestr(now)); %update timestamp
    %catch
%        	myErr = lasterr;
%      	myErr = ['\n/*****\nOh dear, the program failed to set a variable.\nTry running "PsychTestRig -setup" again\n*****/\n\n' myErr]; 
%        	error(myErr,'x') 
%     end
end