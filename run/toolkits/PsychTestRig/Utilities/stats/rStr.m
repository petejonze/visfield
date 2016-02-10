function str = rStr(r,p,df)
%FIG_MAKE shortdesc.
%
%   n.b., df is N-2
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         [r,p] = corr(ages, avTimeLast'); rStr(r,p)
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	11/10/11
% @Last Update:     14/10/11
%
% @Todo:            <blank>

    str = sprintf('$r_{%i} = %1.2f, %s$',df, r, pStr(p,0));
    
end