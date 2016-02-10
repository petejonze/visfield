function h = plotpolyfit(x, y, n, varargin)
%FIG_MAKE shortdesc.
%
%   wrapper
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
% @Creation Date:	11/10/11
% @Last Update:     14/10/11
%
% @Todo:            <blank>


    if nargin == 1
        y = x
        x = (1:size(y,1))'
    end
    if nargin < 3 || isempty(n)
        n = 2;
    end
    if nargin < 4 || isempty(varargin)
        varargin = {};
    end
     
	[x,idx] = sort(x);
  	p = polyfit(x,y(idx),n);
    xFit = linspace(x(1),x(end),1000);
  	yFit = polyval(p, xFit);
    
    h = plot(xFit,yFit,varargin{:});

end