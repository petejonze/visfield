function connectToDatabaseServer(varargin)   
%CONNECTTODATABASESERVER shortdescr.
%
% Description
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    p = inputParser;
    p.addOptional('isSilent', false, @islogical); 
    p.addParamValue('indent', 0, @(x)x>=0 && mod(x,1)==0);
    p.addParamValue('tries', 3, @(x)x>0 && mod(x,1)==0);
    p.FunctionName = 'CONNECTTODATABASESERVER';
    p.parse(varargin{:}); % Parse & validate all input args
    isSilent=p.Results.isSilent;
    indentNum = p.Results.indent;
    maxTries = p.Results.tries;
    %----------------------------------------------------------------------
    
    %initialise local variables
    indentStr = blanks(indentNum);
    dbInfo=getPrefVal('dbInfo');
    host=dbInfo.host;
    username=dbInfo.username;
    password=dbInfo.password;

    tries=0;
    while (1)
        myPass=password;
        if (strcmp(password,'unset'))
            myPass=getStringInput('password: ',true,true);
        end

        try
            fprintf(indentStr);
            msg=mysql_connect(host,username,myPass,isSilent);
            break
        catch
            cloutput([indentStr '...Connection failed!: ' lasterr '\n']) % don't allow a fatal error to be thrown
        end

        tries = tries + 1;
        if (tries==maxTries)
            error('Script Terminated. Database authentication failed.') 
        end
    end
end