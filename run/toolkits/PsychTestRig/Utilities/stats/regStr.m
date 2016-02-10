function str = regStr(stats)
%FIG_MAKE shortdesc.
%
%   wrapper
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         regStr(regstats(x,y))
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	11/10/11
% @Last Update:     14/10/11
%
% @Todo:            <blank>


    str = sprintf('$F(%i) = %1.2f, %s, r^{2} = %1.2f, \\beta = %1.2f$', stats.fstat.dfe, stats.fstat.f, pStr(stats.fstat.pval,0), stats.rsquare, stats.beta(1));
    
end