function ok=checkSetup(cfgData, varargin)
%CHECKSETUP shortdescr.
%
% Description
%
% Example: none
%
% See also importSetup, exportSetup, pruneCfgData
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('cfgData',@isstruct);
    p.addParamValue('silent', false, @islogical);
    p.addParamValue('indent', 0, @(x)x>=0 && mod(x,1)==0);
    p.FunctionName = 'CHECKSETUP';
    p.parse(cfgData,varargin{:}); % Parse & validate all input args
    silentMode = p.Results.silent;
    indentAmount = p.Results.indent;
    %----------------------------------------------------------------------

    % Initialise local variables
    ok=true;
    addAsterisk = false;
    listOfFields_ideal = fieldnames(getBlankSetup()); %retrieve all the fields from a blank template with which to cross-examine the cfgData with...
    listOfFields_actual = fieldnames(cfgData); %...and vice versa
    listOfFields_required = getRequiredFields(); %...and vice versa
    % and flattened versions including all nested items...
    completelistOfFields_ideal = flatNestedStructAccessList(getBlankSetup());
    completelistOfFields_actual = flatNestedStructAccessList(cfgData);
    
    sub_output('%line')
        
    %--------------------
    % ######   1   ######  check for missing/invalid items
    %--------------------
    %for each field name in the blank template... 
    for i = 1:length(listOfFields_ideal)
        fieldName = listOfFields_ideal{i};
        sub_output(['   ' strFillOut(fieldName,30,'.') '      ']) % <- make number of dots dynamic, determined by length of field name
        if ismember(fieldName, listOfFields_actual) %check that a correspondening field exists in the cfg data.
            isValid = checkSetupItem(fieldName, cfgData.(fieldName)); % ### %check if valid
            if isValid
                if isValid > 0
                    sub_output('[OK]\n');
                else
                    sub_output('[n/a]\n');
                end
            else
               	sub_output('[FAIL: INVALID]\n');
                ok = false; 
            end
        else
        	if ismember(fieldName, listOfFields_required) %if the field isn't present check whether it is required.
                sub_output('[FAIL: MISSING]\n') %Mark as mark as erroneous (MISSING)
                ok = false;
            else
                sub_output('[OK*]\n') %Mark as [OK*]. Is optional anyway, so the default value of '' will suffice
                addAsterisk = true; %Add explanatory endnote
            end
        end
    end
    
    if (addAsterisk)
        sub_output('\n')
        sub_output('* value is missing but optional\n')
    end
    
    
    %--------------------
    % ######   2   ######  check for additional, unecessary items [n.b. the items aren't actually removed here. For that, see pruneCfgData()
    %--------------------
    %for each field name in the cfg data, check that a correspondening field exists in theblank template.
    checks=ismember(completelistOfFields_actual,completelistOfFields_ideal);
    unecessaryItems=completelistOfFields_actual(~checks);

    sub_output('%line')
    if ~isempty(unecessaryItems)
        sub_output('The following were not recognised as valid fields and were ignored:\n')
        for i=1:length(unecessaryItems)
            sub_output(['   ' '''' unecessaryItems{i} '''' '\n'])
        end
        sub_output('%line')
    end


   	%--------------------
    % ######   3   ######  report findings
    %--------------------
    sub_output('\n');
    sub_output('%dline')
    if ok
        sub_output('Setup Valid & Complete.\nSee "help PsychTestRig" for further options.\n')
    else
        sub_output('Setup !!!NOT VALID!!!.\nRun "PsychTestRig -setup" before attempting any other actions.\n'); %sub_output('Setup !!!NOT VALID!!!.\nRun "PsychTestRig -setup" before attempting any other actions.\n')
    end
    sub_output('%dline')
    

    
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    
    function sub_output(text)
        if ~silentMode %output info to console
            if iscell(text)
                disp(text)
            else
                cloutput(text, false, indentAmount)
            end
        end 
    end

end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%

