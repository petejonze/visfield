function mergedStruct=mergeStructs(masterStruct, extraStruct)
%MERGESTRUCTS shortdescr.
%
% Description
%
% Example: none
%
% See also getStructVal, setStructVal
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('masterStruct', @isstruct);
    p.addRequired('extraStruct', @isstruct);
    p.FunctionName = 'MERGESTRUCTS';
    p.parse(masterStruct, extraStruct);
    %----------------------------------------------------------------------

    % Initialise local variables
    completelistOfFields_master = flatNestedStructAccessList(masterStruct); %retrieve all the fields from a blank template with which to cross-examine the cfgData with...
    completelistOfFields_extra = flatNestedStructAccessList(extraStruct); %...and vice versa
    mergedStruct = masterStruct;
    
    
    %for each field name in the extraStruct, check that a correspondening
    %field exists in the masterStruct. If not then add it & its value.
    checks=ismember(completelistOfFields_extra,completelistOfFields_master);
    extraItems=completelistOfFields_extra(~checks);
    
    if ~isempty(extraItems)
        for i=1:length(extraItems)
            newVal = getStructVal(extraStruct, extraItems{i});
            mergedStruct = setStructVal(mergedStruct, extraItems{i}, newVal);
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
