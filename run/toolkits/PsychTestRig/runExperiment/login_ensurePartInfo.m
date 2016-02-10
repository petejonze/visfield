function thisPartInfo = login_ensurePartInfo(expID,partID)
% TODO: gui
%       database
    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addRequired('partID', @isPositiveInt);
    p.FunctionName = 'STARTNEWDATASESSION';
    p.parse(expID,partID); % Parse & validate all input args
    %----------------------------------------------------------------------

    % check that part info file exists
    [partInfoFile, spec] = ensurePartInfoFile(expID);
    
    % extract info
    allPartInfo = csv2struct(partInfoFile);
    

    % for ease will make everything a string for now
    accesslist = fieldnames(allPartInfo);
  	accesslist(strcmpi('id',accesslist)) = [];
    for i = 1:length(accesslist)
        fieldname = accesslist{i};
        allPartInfo.(fieldname) = any2cellstr(allPartInfo.(fieldname));
    end
    
 	% cross reference current participant with existing info (do they have
    % an entry already?)
    if isempty(allPartInfo.id) || ~any(ismember(allPartInfo.id, partID));
        % add blank entry
        allPartInfo.id(end+1) = partID;
        for i = 1:length(accesslist)
            fieldname = accesslist{i};

            if isempty(allPartInfo.(fieldname))
                allPartInfo.(fieldname) = {};
            end
            allPartInfo.(fieldname){end+1} = NaN;

        end
    end

    % if required, query for info and enter
    idx = ismember(allPartInfo.id, partID);
    ok = false;
    editIndividual = false;
    while ~ok
        % edit items
        for i = 1:length(accesslist)
            fieldname = accesslist{i};
            if isnan(allPartInfo.(fieldname){idx})
                allPartInfo.(fieldname){idx} = getStringInput(['   ' spec.(fieldname).question ' ']); % pose question
            elseif editIndividual
                oldVal = allPartInfo.(fieldname){idx};
                fprintf('\n   ---------------------------------------\n')
                fprintf('   %s\n   -----------\n   %s\n   old value: %s\n',fieldname,spec.(fieldname).question,oldVal);
                newVal = getStringInput('   new value (blank to keep old): ',true);
                if isempty(newVal)
                    newVal = oldVal;
                end
                allPartInfo.(fieldname){idx} = newVal;
            end
        end
        
        % show summary & check ok
        % extract subset
        thisPartInfo = allPartInfo;
        thisPartInfo.id = partID;
        for i = 1:length(accesslist)
            fieldname = accesslist{i};
            thisPartInfo.(fieldname) = allPartInfo.(fieldname){idx};
        end
        fprintf('   ---------------------------------------\n')
        dispStruct(thisPartInfo)
        fprintf('   ---------------------------------------\n')
        ok = getLogicalInput('   Are these details correct? (y/n): ');
        if ~ok
            editIndividual = true;
        end
    end
    
    % save
    struct2csv(allPartInfo, partInfoFile, true);
    
    % do the same for the database if so required

end