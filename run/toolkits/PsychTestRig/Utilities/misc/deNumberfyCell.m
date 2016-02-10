function outCell = deNumberfyCell(inCell)
%DENUMBERFYCELL convert any numeric string cols to be numeric
%
%   convert all values in cell to string.
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        csv2struct()
%                   numberfyCell
% 
% @Author:          Pete R Jones
%
% @Creation Date:	25/08/10
% @Last Update:     25/08/10
%   
% @Todo:            Everything!
    
    
    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('inCell', @iscell);
    p.FunctionName = 'DENUMBERFYCELL';
    p.parse(inCell); % Parse & validate all input args
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------

    outCell = cell(size(inCell));
    
    nRow = size(inCell,1);
    nCol = size(inCell,2);
    
    for i=1:nRow
        for j=1:nCol
            outCell{i,j} = any2str(inCell{i,j});
        end
    end
        
    return;
end