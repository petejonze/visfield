function msg=mysql_connect(host,username,password,varargin)
%MYSQL_CONNECT shortdescr.
%
% Description
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('host', @ischar);
    p.addRequired('username', @ischar);
    p.addRequired('password', @ischar);
    p.addOptional('isSilent', false, @islogical); 
    p.FunctionName = 'MYSQL_CONNECT';
    p.parse(host,username,password,varargin{:}); % Parse & validate all input args
    isSilent=p.Results.isSilent;
    %----------------------------------------------------------------------
    
    try
        if (~isSilent)
            cloutput(['Connecting to   host=' host '  user=' username '  password=' redact(password)])
        end
        msg=mysql( 'open', host, username, password );
    catch ME
%         myErr = lasterr;
%         if (findstr('Unknown', myErr)) %try and provide some more info if possible
%             myErr = [myErr '\n/*****Either the database server is down or the "host" name you provided is incorrect.\nTo change your login run "PsychTestRig -setup".*****/  ']; 
%         elseif (findstr('denied', myErr))
%             myErr = [myErr '\n/*****We can find the database host,\nbut the username&password combination you provided was not accepted\nTo change your login run "PsychTestRig -setup".*****/  ']; 
%         end 
%         error(myErr,'x') 
        rethrow(ME) 
    end
    
end