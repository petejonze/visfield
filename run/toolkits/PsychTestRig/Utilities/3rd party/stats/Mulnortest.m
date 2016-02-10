function [Mulnortest] = Mulnortest(X,alpha)
% Multivariate Normality Statistical Test.
%(The file gives you the option to explore each of all the n points data directly on the
%graphic display. The program will wait you while you read a brief intructions. For continue,
%you must to press any kay. If you decides not to explore the points data, it will display
%anyway the plot of data including all the statistics but without the chance to do this.)
%
%   Syntax: function [Mulnortest] = Mulnortest(X,alpha) 
%      
%     Inputs:
%          X - multivariate data matrix. 
%      alpha - significance level (default = 0.05). 
%     Output:
%          n - sample-size.
%          p - variables.
%          b1 - estimated sample slope.
%          t - observed Student's t statistic used to test any deviation from
%              a expected slope of 1.0 (b1 = 1.0), which means a deviation of the
%              multivariate normality.
%          P - probability that null Ho: is true.
%          Figure - plot of the ordered Mahalanobis distances along with the
%                   corresponding chi-square values, as well as the expected
%                   straight line.
%
%
% On the literature there are available several tests of the multivariate normality.
% Among them is the graphic approach based on a chi-square quantile-quantile plot of 
% the observations' squared Mahalanobis distances. Besides the graphic q-q approaching,
% in this file we proposes an alternative statistical test to this.
%
%    Example: For the example of Pope et al. (1980) given by Stevens (1992, p. 249), 
%             with 12 cases (n = 12) and three variables (p = 3). We are interested
%             to test it multivariate normality with a significance level = 0.05.
%                      --------------    --------------
%                       x1   x2   x3      x1   x2   x3
%                      --------------    --------------
%                      2.4  2.1  2.4     4.5  4.9  5.7
%                      3.5  1.8  3.9     3.9  4.7  4.7
%                      6.7  3.6  5.9     4.0  3.6  2.9
%                      5.3  3.3  6.1     5.7  5.5  6.2
%                      5.2  4.1  6.4     2.4  2.9  3.2
%                      3.2  2.7  4.0     2.7  2.6  4.1
%                      --------------    --------------
%
%             Total data matrix must be:
%              X=[2.4 2.1 2.4;3.5 1.8 3.9;6.7 3.6 5.9;5.3 3.3 6.1;5.2 4.1 6.4;
%              3.2 2.7 4.0;4.5 4.9 5.7;3.9 4.7 4.7;4.0 3.6 2.9;5.7 5.5 6.2;2.4 2.9 3.2;
%              2.7 2.6 4.1];
%
%             Calling on Matlab the function: 
%                Mulnortest(X,0.05)
%
%             Answer is:
%   ------------------------------------------------------
%    Sample-size    Variables    Slope        t       P
%   ------------------------------------------------------
%         12            3        1.4492    2.7564  0.0101
%   ------------------------------------------------------
%   With a given significance level of: 0.05
%   Assumption of multivariate normality is not tenable.
%
%    -Next the file ask you whether or not are you interested to 
%     explore the n data points; here it's decided not to explore it.
%   Are you interested to explore all the n data points? (y/n): n
%

%  Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.mx
%             And the special collaboration of the post-graduate students of the 2002:2
%             Multivariate Statistics Course: Karel Castro-Morales, Alejandro Espinoza-Tenorio,
%             Andrea Guia-Ramirez, Raquel Muniz-Salazar, Jose Luis Sanchez-Osorio and
%             Roberto Carmona-Pina.
%
%  November 2002. 
%  $Updated: June 10, 2003$
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A., R. Hernandez-Walls, K. Castro-Morales, A. Espinoza-Tenorio,
%    A. Guia-Ramirez, R. Muniz-Salazar, J. Luis Sanchez-Osorio and R. Carmona-Pina.
%    (2002). Mulnortest: Multivariate normality statistical test. A MATLAB file.
%    [WWW document]. URL http://www.mathworks.com/matlabcentral/fileexchange/
%    loadFile.do?objectId=2746&objectType=FILE
%
%  References:
% 
%  Johnson, R. A. and Wichern, D. W. (1992), Applied Multivariate Statistical Analysis.
%              3rd. ed. New-Jersey:Prentice Hall. pp. 158-160.
%  Stevens, J. (1992), Applied Multivariate Statistics for Social Sciences. 2nd. ed.
%              New-Jersey:Lawrance Erlbaum Associates Publishers. pp. 247-248.
  
if nargin < 2, 
   alpha = 0.05;  %(default)
end; 

if nargin < 1, 
   error('Requires at least one input arguments.');
end;

mX = mean(X); %Means vector from data matrix X.
[n,p] = size(X);
difT = [];

for j = 1:p;
   eval(['difT=[difT,(X(:,j)-mean(X(:,j)))];']);
end;

S = cov(X);
D2T = difT*inv(S)*difT'; 
D2 = sort(diag(D2T));  %Ascending squared Mahalanobis distances.

Pr = [];
for i = 1:n;
   eval(['pr' num2str(i) '=(i-0.5)/n;'])
   eval(['x= pr' num2str(i) ';'])
   Pr = [Pr,x];  %Corresponding sampling percentiles. 
end;

X2 = [];
for i = 1:n
   eval(['X2' num2str(i) '=chi2inv(pr' num2str(i) ',p);'])
   eval(['x= X2' num2str(i) ';']);
   X2=[X2,x];  %Expected chi-square distribution with p degrees of freedom, associated
               %to the sampling percentiles.
end;
            
X = D2;
Y = X2'; 
%Test of the straight line by the least squares fitting method.
X = [ones(size(X)) X];
b = inv(X'*X)*(X'*Y);
b1 = b(2,1); %Unbiased stimation of slope.
Ye = X*b; %Expected Y values.
e = Y-Ye; %Estimation of the fitted residuals.
SCRes = e'*e;  %Sum of squares of the fitted residuals.
[rb,cb] = size(b);
v2 = n-rb;  %Degrees of freedom of the fitted residuals. 
CMRes = SCRes/v2;  %Residuals mean square (random variance).
varb = CMRes*inv(X'*X);
EEb = diag(sqrt(varb));
EEb1 = EEb(2,1);  %Slope standard error.
t = abs((b1-1)/EEb1);  %Observed Student's t statistic assuming a slope expected value of 1.0.
P = 1-tcdf(t,v2);  %Probability that null Ho: is true.

fprintf('------------------------------------------------------\n');
disp(' Sample-size    Variables    Slope        t       P')
fprintf('------------------------------------------------------\n');
fprintf('%8.i%13.i%14.4f%10.4f%8.4f\n',n,p,b1,t,P);
fprintf('------------------------------------------------------\n');
fprintf('With a given significance level of: %.2f\n', alpha);
     
if P >= alpha;
   fprintf('Assumption of multivariate normality is tenable.\n\n');
else
   fprintf('Assumption of multivariate normality is not tenable.\n\n');
end;

pt = input('Are you interested to explore all the n data points? (y/n): ','s');
if pt == 'y';
   fprintf('Warning: You must to explore all the n data points. It is convenient you\n');
   fprintf('put the more centered (focus) possible the croosshair pointer in order\n');
   fprintf('to get a good point-coordinate. In each point you must to give it a paused\n');
   fprintf('double-click on left mouse button. If you interrupt it by figure deletion it\n');
   fprintf('will display an error message. For continue, please press any key.\n');
   disp(' ');
   
   pause
   
   X = X(:,2);
   plot(X,Y,'*',Y,Y,'--');
   title('Multivariate Normality Test','FontSize',12);
   xlabel('Mahalanobis Distance  D^2');
   ylabel('Chi-square  \chi^2');
   text(4.2,1.5,['Slope = ',num2str(b1),';','n = ',num2str(n),',','p = ',num2str(p)]);
   text(5.2,1,['(P = ',num2str(P),')']);
   a = [X,Y];
   for i = 1:n
      a(i,:) = ginput(1);
      gtext([num2str(a(i,:))],'FontSize',8);
   end;
else
   X = X(:,2);
   plot(X,Y,'*',Y,Y,'--');
   title('Multivariate Normality Test','FontSize',12);
   xlabel('Mahalanobis Distance  D^2');
   ylabel('Chi-square  \chi^2');
   text(4.2,1.5,['Slope = ',num2str(b1),';','n = ',num2str(n),',','p = ',num2str(p)]);
   text(5.2,1,['(P = ',num2str(P),')']);
end;
clear all
