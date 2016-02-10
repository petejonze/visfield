function newStruct = setStructVal(theStruct, fieldName, val)
%SETSTRUCTVAL A simple wrapper for getpref.
%
% desc.
%
% Example: none
%
% See also getStructVal

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('theStruct', @isstruct);
    p.addRequired('fieldName', @ischar);
    p.addRequired('val');
    p.FunctionName = 'SETSTRUCTVAL';
    p.parse(theStruct, fieldName, val); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    %Go!
    r=regexp(fieldName,'\.','split');
    
    if isempty(r)
        newStruct = setfield(theStruct, fieldName, val);
    else
        newStruct = setfield(theStruct, r{:}, val);
    end

end
            