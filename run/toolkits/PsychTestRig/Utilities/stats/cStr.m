function str = cStr(df, N, chi2, p)
%FIG_MAKE shortdesc.
%
%   wrapper
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         stats = regstats(y,x); fStr(stats.fstat.dfe, stats.fstat.f, stats.fstat.pval, stats.beta(2), stats.rsquare)
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	11/10/11
% @Last Update:     14/10/11
%
% @Todo:            <blank>

    str = sprintf('$\\chi^{2}(%i, N = %i) = %1.2f, %s$', df, N, chi2, pStr(p,0));

    
end