function prunedCfgData=pruneCfgData(cfgData)
%PRUNECFGDATA shortdescr.
%
% Description
%
% Example: none
%
% See also checkSetup
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('cfgData',@isstruct);
    p.FunctionName = 'PRUNECFGDATA';
    p.parse(cfgData); % Parse & validate all input args
    %----------------------------------------------------------------------

    % Initialise local variables
    completelistOfFields_ideal = flatNestedStructAccessList(getBlankSetup()); %retrieve all the fields from a blank template with which to cross-examine the cfgData with...
    completelistOfFields_actual = flatNestedStructAccessList(cfgData); %...and vice versa
    prunedCfgData = cfgData;
    
    
    %for each field name in the cfg data, check that a correspondening
    %field exists in theblank template. If not, remove [n.b. this is
    %essentially taken from checkSetup()
    checks=ismember(completelistOfFields_actual,completelistOfFields_ideal);
    unecessaryItems=completelistOfFields_actual(~checks);
    
    if ~isempty(unecessaryItems)
        for i=1:length(unecessaryItems)
            prunedCfgData = rmfield(prunedCfgData, unecessaryItems{i});
        end
    end

    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%

