function [F,p] = R2signif(N,R2f,f,R2r,r)

% R2SIGNIF  --  Significance test for hierarchical multiple regression.
%
%  F = R2signif(N,R2f,df_f)
%  F = R2signif(N,R2f,df_f,R2r,df_r)
%  [F,p] = R2signif(...)
%
%  N is the number of observations, R2F and R2R are the squared multiple
%  correlations for the full and reduced models, respectively. DF_F and
%  DF_R are the corresponding degrees of freedom. When not specified, the
%  reduced model defaults to zero and thus the function calculates a
%  test of whether R2F is significantly greater than zero. When two
%  models are specified, the test is whether the increment of R2 is
%  significant. The test statistic is calculated as follows:
%        (R2f - R2r) / (df_f - df_r)
%    F = ----------------------------  ,  df = f-r, N-f-1
%          (1 - R2f) / (N - df_f - 1)
%
%  Reference: Howell, D.C. (1992). Statistical Methods for Psychology
%      (3rd Ed., p. 542). Belmont, CA: Duxbury Press.
%
%  See also REGCOEFS, \, MLDIVIDE.

% Original coding by Alex Petrov, Ohio State University
% $Revision: 1.0 $  $Date: 2001/01/07 19:00 $
%
% Part of the utils toolbox version 1.1 for MATLAB version 5 and up.
% http://alexpetrov.com/softw/utils/
% Copyright (c) Alexander Petrov 1999-2006, http://alexpetrov.com
% Please read the LICENSE and NO WARRANTY statement in ../utils_license.m

if (nargin > 3)
  delta_R2 = R2f - R2r ;
  delta_df = f - r ;
else
  delta_R2 = R2f ;
  delta_df = f ;
end

F = (delta_R2 ./ delta_df) ./ ((1-R2f) ./ (N-f-1)) ;
p = 1 - Fcdf(F,delta_df,N-f-1) ;

%-- Return F and P
%%%%% End of REGCOEFS.M
