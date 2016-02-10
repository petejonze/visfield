function thestruct=rnStructField(thestruct, oldFieldName, newFieldName)
%RNSTRUCTFIELD rename a field in a structure
%
%   Renames a structure field by creating a new structure entry, copying over
%   the appropriate data and deleting the old entry.
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	25/08/10
% @Last Update:     25/08/10
%
% @Todo:            <blank>

    [thestruct.(newFieldName)] = thestruct.(oldFieldName);
    thestruct = rmfield(thestruct,oldFieldName);

    %%%%%%%%%%%%%%%%%%%%%
    %%% SUB FUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%%
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%



