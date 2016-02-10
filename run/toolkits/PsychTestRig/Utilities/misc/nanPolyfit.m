function [p,s,nRemoved] = nanPolyfit(x, y, n)
%NANPOLYFIT Calls polyfit after removing any nan values. Returns standard
%polyfit info.
%
%   See: help polyfit
%   Also returns nRemoved.
%   n.b. [p,s,mu] not supported.
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         [p,s,nRemoved] = nanPolyfit(x, y, n)
%
% @See also:        <blank>
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
    p.addRequired('n', @(x)mod(x,1)==0);
    p.FunctionName = 'NANPOLYFIT';
    p.parse(x, y, n);
    %----------------------------------------------------------------------

    idx = isnan(x);
    x(idx) = []; y(idx) = [];
    nRemoved = sum(idx);
    
	idx = isnan(y);
    x(idx) = []; y(idx) = [];
    nRemoved = nRemoved + sum(idx);
    
    [p,s] = polyfit(x, y, n);
    
end