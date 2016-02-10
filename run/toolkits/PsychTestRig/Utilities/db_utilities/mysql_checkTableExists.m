function err=mysql_checkTableExists(tableName,varargin)
%MYSQL_CHECKTABLEEXISTS shortdescr.
%
% Description
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('table', @ischar);
    p.addOptional('creationText', '', @ischar);
    p.addOptional('triggerText', '', @ischar);
    p.FunctionName = 'MYSQL_CHECKTABLE';
    p.parse(tableName,varargin{:});
    creationText = p.Results.creationText;
    triggerText = p.Results.triggerText;  
    err=0;
    %----------------------------------------------------------------------

    %check table exists
    tbls=mysql('show tables');
    if (~ismember(tableName,tbls)) 
        if (~strcmp(creationText,'')) %if..then try to create
            if (getLogicalInput(['   |     table not found: "' tableName '". Create? (y/n) ']))
                try
                    msg=mysql(creationText);
                catch 
                    myErr = lasterr;
                    if (findstr('denied', myErr)) %try and provide some more info if possible
                        myErr = [myErr '\n/*****The account you are signed in with does not appear to have table creation privilages.\n You could try signing in as "root" or contact your database administrator.*****/  ']; 
                    end   
                    error(myErr,'x') 
                end
                if (~strcmp(triggerText,''))
                    try
                        msg=mysql(triggerText);
                    catch
                        msg=mysql(['drop table ' tableName]); % remove table (clean the slate)
                        myErr = lasterr;
                        myErr = [myErr '\n/*****Invalid Trigger Text: Table creation aborted.*****/']; 
                        error(myErr,'x') 
                    end
                end
            else %choose not to create
                error(['Table "' tableName '" does not exist (creation option given)'])
            end
        else %not given option to create
            error(['Table "' tableName '" does not exist (creation option NOT given)'])
        end
    end
                              
end
