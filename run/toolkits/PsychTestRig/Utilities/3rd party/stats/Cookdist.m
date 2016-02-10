function Cookdist(D)
% COOKDIST Cook's Distance Influence Index.
%  This quantity measures how much the entire regression function changes when
%  the i-th observation is deleted. Should be comparable to F_p,n-p: if the 'p-value'
%  of  D_i is 50 percent or more, then the i-th point is likely influential:
%  investigate this point further. Cook's distance (D_i) [Cook, 1977,1979] is an
%  influence measure based on the difference between the regression parameter
%  estimates b and what they become if the i-th data point is removed, b_-1.
%  Let y_(i) be the value opf the fitted response corresponding to the ith observation
%  removed. Then e_(i)=y_i - y_(i) is called the deleted residual. This is easily
%  computed if the leverage h_ii of the observation is known,
%
%                             e_(i) = e_i/(1 - h_ii).
%
%  According to the i-th studentized residual,
%
%                         r_i = e_i/sqrt(MSRes*(1-h_ii)),
%
%   D_i = (r_i^2/p)*(h_ii/(1-h_ii)) = (e_i^2/p*MSRes*(1-h_ii))*(h_ii/(1-h_ii))
%
%                    = e_i^2*(h_ii/(1-h_ii)^2)*(1/(p*MSRes)).
%
%  The usual criterion is that a point is influential if D_i exceeds the median of
%  the F_p,n-p distribution, where p is the number of regression coefficients (including
%  the intercept) and n the number of data.
%
%  **NOTE.- One should be careful. This procedure it is not a conclusive test to detect
%  any outliers on regression models, but unusual observations by its very high leverage
%  and high influence values. For such a case you should to check it under the appropriate 
%  assumptions.**
%
%  Syntax: cookdist(D) 
%      
%  Inputs:
%       D - matrix data (=[X Y]) (last column must be the Y-dependent variable).
%           (X-independent variable entry can be for a simple [X], multiple [X1,X2,X3,...Xp] 
%           or polynomial [X,X^2,X^3,...,X^p] regression model).
%
%  Outputs:
%       A complete summary (table and/or plot) of the Cook's influence index. For the graph,
%       the cross-hair can be positioned with the mouse at the selected location.  
%
%  From the example 4.1 of Jennrich (1995), we are interested to investigate if there is some
%  effect on the fitted response of removing the i-th observation or influence.
%
%              -------------------   -------------------
%                 X1    X2     Y        X1    X2     Y
%              -------------------   -------------------
%                 68    60    75        71    86    70
%                 49    94    63        95    94    96
%                 60    91    57        61    94    76
%                 68    81    88        72    94    75
%                 97    80    88        87    79    85
%                 82    92    79        40    50    40
%                 59    74    82        66    92    74
%                 50    89    73        58    82    70
%                 73    96    90        58    94    75
%                 39    87    62        77    78    72
%              -------------------   -------------------
%
%  Data matrix must be:
%  D=[68 60 75;49 94 63;60 91 57;68 81 88;97 80 88;82 92 79;59 74 82;50 89 73;73 96 90;
%  39 87 62;71 86 70;95 94 96;61 94 76;72 94 75;87 79 85;40 50 40;66 92 74;58 82 70;
%  58 94 75;77 78 72];
%
%  Calling on Matlab the function: 
%             cookdist(D)
%
%  Answer is:
%
%  Exploring the influence of observation by the Cook's distance to list those
%  particulary suspicious.
%  ----------------------------------------------------------------------------
%   Observation                Y                   e                 Cook              
%  ----------------------------------------------------------------------------
%        16                 40.0000            -10.3917             1.414
%  ----------------------------------------------------------------------------
%  (Fp,n-p(0.5) = 0.82121, p = 3, n = 20)
%
%  Created by A. Trujillo-Ortiz, R. Hernandez-Walls and F.A. Trujillo-Perez
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.mx
%             And the special collaboration of the post-graduate students of the 2005:2
%             Multivariate Statistics Course: D.A. Paz-Garcia, H.E. Chavez-Romo, 
%             K. Xolaltenco-Coyotl, and A. Montiel-Boehringer.
%  Copyright (C) October 6, 2005.
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A., R. Hernandez-Walls, F.A. Trujillo-Perez, D.A. Paz-Garcia, H.E. Chavez-Romo,
%         K. Xolaltenco-Coyotl and A. Montiel-Boehringer. (2005). COOKDIST:Cook's Distance Influence Index. 
%         A MATLAB file. [WWW document]. URL http://www.mathworks.com/matlabcentral/fileexchange/
%         loadFile.do?objectId=8716
%
%  References:
%  Cook, R. D. (1977), Detection of influential observations in linear regression.
%          Technometrics, 19:15-18.
%  Cook, R. D. (1979), Influential observations in linear regression. Journal of
%          the American Statistical Association, 74:169-174.
%  Jennrich, R. I. (1995), An Introduction to Computational Statistics:Regression Analysis.
%          Inglewood Cliffs, NJ: Prentice Hall.    
%
%  -------------------------------
%  Modified 10/15/05 to address suggestions by Urs Schwartz.
%  -------------------------------
%

[r c] = size(D);

n = r; %number of data

Y = D(:,c); %response vector

X = [ones(n,1) D(:,1:c-1)]; %design matrix

p = size(X,2); %number of parameters

b = inv(X'*X)*(X'*Y); %least squares parameters estimation

Ye = X*b; %expected response value

e = Y-Ye; %residual term

SSRes = e'*e;  %residual sum of squares

[rb,cb] = size(b);

v2 = n-rb; %residual degrees of freedom

MSRes = SSRes/v2; %residual mean square

Rse = sqrt(MSRes); %standard error term

H = X*inv(X'*X)*X'; %hat matrix

hii = diag(H); %leverage of the i-th observation

ri = e./(Rse*sqrt(1-hii)); %Studentized residual

Di = diag((ri.^2/p)*[(hii./(1-hii))]'); %Cook's distance

F50 = finv(0.5,p,n-p); %mean of the F-distribution

d = [];
for i=1:n,
    d=[d;i];
end;

in = any(Di>F50,2);
I = [Di(in)];
O = d(in);
y = Y(in);
ee = e(in);

disp('  ')
if sum(in)==0;
    disp('No influence of the i-th observation is identified.');
    disp(['(Fp,n-p(0.5) = ',num2str(F50) ', ' 'p = ',num2str(p) ', ' 'n = ',num2str(n) ')']);
else (sum(in)>0);
    disp('Exploring the influence of observation by the Cook''s distance to list those');
    disp('particulary suspicious.');
    disp('----------------------------------------------------------------------------');
    disp(' Observation                Y                   e                 Cook              ');
    disp('----------------------------------------------------------------------------');
    fprintf('      %i                 %.4f            %.4f             %.3f\n',[O y ee I]');
    disp('----------------------------------------------------------------------------');
    disp(['(Fp,n-p(0.5) = ',num2str(F50) ', ' 'p = ',num2str(p) ', ' 'n = ',num2str(n) ')']);
end;

hold on
stem(Di,'*b')
xlabel('Observation number');
ylabel('Cook''s distance');
st = (['(Fp,n-p(0.5) = ',num2str(F50) ', ' 'p = ',num2str(p) ', ' 'n = ',num2str(n) ')']);
title({'Cook''s distance plot.','' num2str(st) ''})

id = [I O];
if sum(in)>=1.0,
    plot(id(:,2),id(:,1),'sb');
    legend(['+',['   ' 2] ' = Influential observation(s) '],0);
else
end;
hold off

return;