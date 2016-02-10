function checkDbTable(tableName)
%checkDbTable shortdescr.
%
% Description
%
% Example: none
%
% See also getBlankSetup
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('tableName', @ischar);
    p.FunctionName = 'CHECKSETUPITEM';
    p.parse(tableName);
    %----------------------------------------------------------------------

    % Go!
    switch tableName
        case 'experiments'
            mysql_checkFieldStructure('experiments','id_num','int(11)','null','NO','key','PRI','extra','auto_increment'); %,'creationText','ALTER TABLE experiments ADD id_num VARCHAR(32) NOT NULL AUTO_INCREMENT PRIMARY KEY'
            mysql_checkFieldStructure('experiments','name','varchar(32)','null','NO','key','UNI'); %,'creationText','ALTER TABLE experiments ADD name VARCHAR(32) NOT NULL UNIQUE AFTER id_num'
            mysql_checkFieldStructure('experiments','last_update','timestamp','null','NO','default','CURRENT_TIMESTAMP','extra','on update CURRENT_TIMESTAMP'); %,'creationText','ALTER TABLE experiments ADD name VARCHAR(32) NOT NULL UNIQUE AFTER name'
            mysql_checkFieldStructure('experiments','creation_date','datetime','null','NO','default','1900-01-01 00:00:00');
            mysql_checkFieldStructure('experiments','status','varchar(32)','null','NO','default','PENDING');
            mysql_checkFieldStructure('experiments','notes','mediumtext','creationText','ALTER TABLE experiments ADD notes MEDIUMTEXT');
        case 'participants'
            mysql_checkFieldStructure('participants','id_num','int(11)','null','NO','key','PRI','extra','auto_increment');
            mysql_checkFieldStructure('participants','forename','varchar(32)','null','NO');
            mysql_checkFieldStructure('participants','surname','varchar(32)','null','NO');
            mysql_checkFieldStructure('participants','dob','date','null','NO');
            mysql_checkFieldStructure('participants','last_update','timestamp','null','NO','default','CURRENT_TIMESTAMP','extra','on update CURRENT_TIMESTAMP');
            mysql_checkFieldStructure('participants','creation_date','datetime','null','NO','default','1900-01-01 00:00:00');
            mysql_checkFieldStructure('participants','notes','mediumtext','creationText','ALTER TABLE participants ADD notes MEDIUMTEXT');
            mysql_checkFieldStructure('participants','private_comments','mediumtext','creationText','ALTER TABLE participants ADD private_comments MEDIUMTEXT');
        case 'sessions'
            mysql_checkFieldStructure('sessions','id_num','int(11)','null','NO','key','PRI','extra','auto_increment');
            mysql_checkFieldStructure('sessions','expID','int(11)','null','NO','key','MUL');
            mysql_checkFieldStructure('sessions','partID','int(11)','null','NO','key','MUL');
            mysql_checkFieldStructure('sessions','timestamp','timestamp','null','NO','default','CURRENT_TIMESTAMP','extra','on update CURRENT_TIMESTAMP');
            mysql_checkFieldStructure('sessions','notes','mediumtext','creationText','ALTER TABLE sessions ADD notes MEDIUMTEXT');
        otherwise
            error('PsychTestRig:checkSetupItem:UnrecognisedItem', 'Unknown tableName: "%s".', tableName)
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%