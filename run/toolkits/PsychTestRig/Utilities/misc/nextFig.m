function figHandle = nextFig(varargin)
%NEXTFIG shortdesc.
%
%   Makes a new figure (iterates the num of figures open)
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
% @Creation Date:	30/08/10
% @Last Update:     30/08/10
%
% @Todo:            <none>

    fnum = length(findobj('Type','figure'))+1;
    figHandle = figure(fnum);
end