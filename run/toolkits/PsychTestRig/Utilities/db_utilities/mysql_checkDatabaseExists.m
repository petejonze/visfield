function err=mysql_checkDatabaseExists(dbName,varargin)
%MYSQL_CHECKDATABASEEXISTS shortdescr.
%
% Description
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('dbName', @ischar);
    p.addOptional('creationText', '', @ischar);
    p.addOptional('autoCreate', 0, @(x)x==0 || x==1);
    p.FunctionName = 'MYSQL_CHECKDATABASEEXISTS';
    p.parse(dbName,varargin{:});
    creationText = p.Results.creationText;
    autoCreate = p.Results.autoCreate;
    %----------------------------------------------------------------------

    
    %check db exists
    dbs=mysql('show databases');
    if (~ismember(dbName,dbs))
        if (~strcmp(creationText,'')) %if..then try to create
            if (autoCreate || getLogicalInput(['   |  database not found: "' dbName '". Create? (y/n) ']))
                try
                    msg=mysql(creationText);
                catch
                    myErr = lasterr;
                    if (findstr('denied', myErr)) %try and provide some more info if possible
                        myErr = [myErr '\n/*****The account you are signed in with does not appear to have database creation privilages. Please sign in as "root" or contact your database administrator.*****/  ']; 
                    end   
                    error(myErr,'x') 
                end
            else
                error(['Database "' dbName '" does not exist (creation option given)'])
            end
        else
            error(['Database "' dbName '" does not exist (creation option NOT given)'])
        end
    end
                              
end
