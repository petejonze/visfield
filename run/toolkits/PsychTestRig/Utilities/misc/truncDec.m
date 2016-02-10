function xr = truncDec(x, n)
%TRUNCDEC Truncate a decimal number to n decimal places.
%
%   ######
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         x = truncDec(1.123456789,4)
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	30/04/11
% @Last Update:     30/04/11
%
% @Todo:            Everything!

	%----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('x', @isnumeric);
    p.addRequired('n', @(x)mod(x,1)==0); % number of digits after the decimal
    p.parse(x, n);
    %----------------------------------------------------------------------

    
    n = 10 ^ -n;
    xr = round(x/n)*n;
    
end