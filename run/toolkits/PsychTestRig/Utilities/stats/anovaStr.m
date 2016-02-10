function str = anovaStr(df1,df2,F,p,pEta2)
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

    str = sprintf('$F(%i,%i) = %1.2f, %s, \\eta_{p}^{2} = %1.2f$', df1,df2,F,pStr(p,0),pEta2);
    
end