function msg=redact(msg)
%REDACT star out string
%
% desc.
%
% Example: none
%
% See also 

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('msg', @ischar);
    p.FunctionName = 'REDACT';
    p.parse(msg); % Parse & validate all input args
    msg = p.Results.msg;
    %----------------------------------------------------------------------

    msg=regexprep(msg, '.', '*');
    
end