function val = getStructVal(theStruct, fieldName)
%GETSTRUCTVAL A simple wrapper for getpref.
%
% desc.
%
% Example: none
%
% See also setStructVal

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('theStruct', @isstruct);
    p.addRequired('fieldName', @ischar);
    p.FunctionName = 'GETSTRUCTVAL';
    p.parse(theStruct, fieldName); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    %Go!
    r=regexp(fieldName,'\.','split');
    
    if isempty(r)
        val = getfield(theStruct, fieldName);
    else
        val = getfield(theStruct, r{:});
    end
    
    
%ALT:
%     %Initialise local variable(s)
%     parentStruct = theStruct;
% 	while regexp(fieldName,'\.') %if the field name contains a '.' we shall assume the user is trying to access an item inside a structure.
%         r=regexp(fieldName,'\.','split','once');
%         parentStruct = parentStruct.(r{1}); %stem
%         fieldName = r{2}; %branch
%     end
%     
%     val = parentStruct.(fieldName); %get the value

end
            