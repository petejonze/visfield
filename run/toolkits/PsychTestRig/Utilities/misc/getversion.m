function [verStr,verParts] = getversion(toolboxstr)
%GETVERSION return MATLAB version number as a double.
% GETVERSION determines the MATLAB or specified toolbox version, and
% returns it as both as a string, and a 3 element numeric vector
%
%
% If a toolbox name is passed in then will find that version
% number instead
%
% See also version, ver, verLessThan.
%
% PJ: modified heavily from a script by Timothy A. Davis, Univ. of Florida,
% who writes:
%
% This function does not use ver, in the interest of speed and portability.
% "version" is a built-in that is about 100 times faster than the ver m-file.
% ver returns a struct, and structs do not exist in old versions of MATLAB.
% All 3 functions used here (version, sscanf, and length) are built-in.


    if nargin < 1 || isempty(toolboxstr) % then do for Matlab itself
        verStr = version();
        verParts = sscanf (version, '%d.%d.%d') ;
        %v = 10.^(0:-1:-(length(v)-1)) * v ;
    else % from verLessThan
        toolboxver = ver(toolboxstr);
        if isempty(toolboxver)
            error('getversion:missingToolbox', 'Toolbox ''%s'' not found.', toolboxstr)
        end
        verStr = toolboxver(1).Version;
        verParts = getParts(toolboxver(1).Version);
    end

end

function parts = getParts(V)
    parts = sscanf(V, '%d.%d.%d')';
    if length(parts) < 3
        parts(3) = 0; % zero-fills to 3 elements
    end
end