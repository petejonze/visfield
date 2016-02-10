function [rData,conditions]=restructureData(dataFileName, conditionCriterion)
%RESTRUCTUREDATA shortdescr.
%
% WHAT IS THIS FOR?!?!?!?!?!
%   
% @Parameters:         
%
% @Example:         <none>
%
% @See also:        
% 
% @Author:          Pete R Jones
%                   
%
% @Creation Date:	16/03/10
% @Last Update:     16/03/10
%
% @Todo:            Help text. Everything!

%     CONDITION_CRITERION = 'sigma';
    

    %-----------------------------------------------------------
    p = inputParser;
    p.addRequired('dataFileName', @(x)exist(x,'file')>0);
    p.addRequired('conditionCriterion', @ischar);
    p.FunctionName = 'EXP1VER8_ANALYSEENRRESULTS2';
    p.parse(dataFileName, conditionCriterion); % Parse & validate all input args
    %----------------------------------------------------------------------

    % initialise
    CONDITION_CRITERION = conditionCriterion;
    
    % load data from csv file
    data = csv2struct(dataFileName);

    % define conditions
    conditions = unique(data.(CONDITION_CRITERION));
    numOfConditions = length(conditions);
    
    % restructure (sub divide by condition)
    rData = struct();
    accessList=fieldnames(data);
    numOfFields = length(accessList);
    for i=1:numOfConditions
        cond = conditions(i);
        for x=1:numOfFields
            fieldName = accessList{x};
            fieldData = data.(fieldName);
            fieldData = fieldData(data.(CONDITION_CRITERION)==cond);
            rData.(['cond' num2str(i)]).(fieldName) = fieldData;
        end
    end
    
    % ensure that the conditions are returned as a cellstr
    if ~iscell(conditions)
        conditions = cellstr(num2str(conditions(:)))'; %convert matrix to cellstr
    else
        conditions = any2str(conditions{:}); %ensure that every item is a string
    end
    
    % display new dataset
%     dispStruct(rData)



    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<none>
 
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<none>

