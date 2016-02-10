function str = tStr(df,t,p)
%FIG_MAKE shortdesc.
%
%   wrapper
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         [H,P,CI,STATS] = ttest2(x1,x2); tStr(STATS.df,STATS.tstat,P)
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	11/10/11
% @Last Update:     14/10/11
%
% @Todo:            <blank>

    str = sprintf('$t(%i) = %1.2f, %s$', df,t,pStr(p,0));
    
end