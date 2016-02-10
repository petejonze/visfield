function ok=checkSetupItem(itemName, itemValue)
%CHECKSETUPITEM shortdescr.
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
    p.addRequired('itemName', @ischar);
    p.addRequired('itemValue');
    p.FunctionName = 'CHECKSETUPITEM';
    p.parse(itemName, itemValue);
    %----------------------------------------------------------------------
    
    % Initialise local variables
    ok=1;
    
    % Go!
    try
        switch itemName
            case 'homeDir'
                ok=local_checkHomeDir(itemValue);
            case 'lastUpdate'
                ok=local_checkLastUpdate(itemValue);
            case 'backupDir'
                ok=local_checkBackupDir(itemValue);
            case 'useDb'
              	ok=islogical(itemValue);
            case 'dbInfo'
                ok=local_checkDBInfo(itemValue);
            case 'alertAddress'
                ok=local_checkAlertAddress(itemValue);
            otherwise
                error('PsychTestRig:checkSetupItem:UnrecognisedItem', ['Unknown config property: "' itemName '".'])
        end
    catch
        ok=0;
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%

function ok=local_checkHomeDir(val)
    if exist(val,'dir')
        ok=1;
        return
    end
	ok = 0;
end

function ok=local_checkLastUpdate(val)
    
%     warning('PsychTestRig:checkSetupItem:local_checkLastUpdate','PsychTestRig:checkSetupItem:local_checkLastUpdate: No checks performed.')
%     fprintf('PsychTestRig:checkSetupItem:local_checkLastUpdate: %s\n','PsychTestRig:checkSetupItem:local_checkLastUpdate: No checks performed.')
    ok=1;
end

function ok=local_checkBackupDir(val)
    if exist(val,'dir')
        ok=1;
        return
    end
	ok = 0;
end

function ok=local_checkDBInfo(val)
    if getPrefVal('useDb')
        
        %mysql_connect(val.host,val.username,val.password);
        
        try
            connectToDB();
            
            checkDbTable('experiments');
            checkDbTable('participants');
            checkDbTable('sessions');
        catch ME
            fprintf(ME.message);
            ok=0;
            return
        end
        ok = 1;
    else
        ok = -1;
    end
end

function ok=local_checkAlertAddress(val)
    ok = 0;
    if isempty(val) || regexp(val,'\w+@\w+\.\w+')
        ok = 1;
    end
end
            
            