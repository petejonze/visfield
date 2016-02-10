function setPrefVals(prefs,prefVals)
%SETPREFVALS shortdescr.
%
% desc.
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('prefs', @iscell);
    p.addRequired('prefVals',@iscell);
    p.FunctionName = 'SETPREFVALS';
    p.parse(prefs,prefVals); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    %check good to go
    if length(prefs) ~= length(prefVals) %crude?
        error('Fatal Error: Number of field names and values do not match!')
    end
    
    %run
    for i = 1:length(prefs)
        setPrefVal(prefs{i},prefVals{i});
    end

end