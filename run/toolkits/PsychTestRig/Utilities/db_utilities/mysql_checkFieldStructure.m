function err=mysql_checkFieldStructure(tableName,field,type,varargin)
%MYSQL_CHECKFIELDSTRUCTURE shortdescr.
%
% Description
%
% Example: none
%
% See also
    %given that table exists, ensure that it contains all the right fields
    %assumes that already connected to a db
  

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('table', @ischar);
    p.addRequired('field', @ischar);
    p.addRequired('type', @ischar);
    p.addParamValue('null', 'YES', @ischar);
    p.addParamValue('key', '', @ischar);
    p.addParamValue('default', '', @ischar);
    p.addParamValue('extra', '', @ischar);
    p.addParamValue('creationText', '', @ischar);
    p.FunctionName = 'MYSQL_CHECKTABLE';
    p.parse(tableName,field,type,varargin{:});
    %----------------------------------------------------------------------
    myField=p.Results.field;
    myType=p.Results.type;
    myNull=p.Results.null;
    myKey=p.Results.key;
    myDefault=p.Results.default;
    myExtra=p.Results.extra;
    creationText = p.Results.creationText;
    err=0;
    %----------------------------------------------------------------------
   
    if (mysql_checkTableExists(tableName))
        error(['Table does exist : ' tableName '. Field structure check failed.'])
    end
    
    
    [Field,Type,Null,Key,Default,Extra]=mysql(['DESC ' tableName]); %retrieve table structure [useful when debugging!]
    props={'Type','Null','Key','Default','Extra'};
    
    if (ismember(myField,Field)) %check that the field exists
        i=find(ismember(Field, myField)==1); %check field info
        checks = [strcmp(Type(i),myType), ...
                    strcmp(Null(i),myNull), ...
                    strcmp(Key(i),myKey), ...
                    strcmp(Default(i),myDefault), ...
                    strcmp(Extra(i),myExtra)];
        if (~all(checks))
            failures={props{~checks}}
            error(['/*****Setup failed. "' tableName '.' myField '" contains the following incorrectly specified properties(s): ' strjoin(', ',failures{:}) '. You could try to manually remove this field, but this may cause the loss of existing data.*****/'])
        end   
    else %try to create
        if (~strcmp(creationText,'')) %if..then try to create
            if (getBooleanInput(['   |        field not found: "' tableName '.' myField '" Create? (y/n) ']))
                try
                    msg=mysql(creationText);
                catch
                    if (findstr('denied', lasterr)) %try and provide some more info if possible
                        myErr = lasterr;
                        myErr = [myErr '\n/*****The account you are signed in with does not appear to have table alteration privilages.\n You could try signing in as "root" or contact your database administrator.*****/  ']; 
                    end   
                    error(myErr,'x') 
                end
            else %choose not to create
                error(['Field "' myField '" does not exist in table "' tableName '" (creation option WAS given)'])
            end
        else %not given option to create
            error(['Field "' myField '" does not exist in table "' tableName '" (creation option NOT given)'])
        end
    end

end