function [r,nRemoved] = nanCorrcoef(x, y)
%NANCORRCOEF As nanPolyFit but for corrcoef
%
%   See: help corrceof
%   Also returns nRemoved.
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         [p,s,nRemoved] = nanCorrcoef(x, y)
%
% @See also:        nanPolyFit
% 
% @Author:          Pete R Jones
%
% @Creation Date:	08/06/11
% @Last Update:     08/06/11
%
% @Todo:            Everything!

	%----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('x', @isnumeric);
    p.addRequired('y', @isnumeric);
    p.FunctionName = 'NANCORRCOEF';
    p.parse(x, y);
    %----------------------------------------------------------------------

    idx = isnan(x);
    x(idx) = []; y(idx) = [];
    nRemoved = sum(idx);
    
	idx = isnan(y);
    x(idx) = []; y(idx) = [];
    nRemoved = nRemoved + sum(idx);
    
    r = corrcoef(x, y);
    
end