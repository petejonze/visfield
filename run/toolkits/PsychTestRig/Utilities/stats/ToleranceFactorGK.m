function [k,int,z,fun,options] = ...
    ToleranceFactorGK(n,coverage,confidence,m,nu,d2,options)
%ToleranceFactorGK computes (by the Gauss-Kronod quadrature) the exact
%tolerance factor k for the two-sided (optionally for the one-sided)
%p-content and (1-alpha)-confidence tolerance interval
%   TI = [Xmean - k * S, Xmean + k * S],
%where Xmean = mean(X), S = std(X), X = [X_1,...,X_n] is a random sample
%of size n from the distribution N(mu,sig2) with unknown mean mu and
%variance sig2.
%
%The value of the tolerance factor k is determined such that the tolerance
%intervals with the confidence (1-alpha) cover at least the fraction p
%('coverage') of the distribution N(mu,sigma^2), i.e.
%   Prob[ Prob( Xmean - k * S < X < Xmean + k * S ) >= p ]= 1-alpha,
%for X ~ N(mu,sig2) which is independent with Xmean and S. For more details
%see e.g. Krishnamoorthy and Mathew (2009).
%
%Syntax:
%k = ToleranceFactorGK(n,coverage,confidence)
%or
%k = ToleranceFactorGK(n,coverage,confidence,m,nu,d2,options)
%k = ToleranceFactorGK(n,coverage,confidence,[],[],[],options)
%if empty, default values are m = 1, nu = n-1, c = 1/n, 
%options is a structure with further possible specifications (see bellow).
%
%If S is a pooled estimator of sig, based on m random samples of size n,
%ToleranceFactorGK computes the simultaneous (optionally non-simultaneous)
%exact tolerance factor k for the two-sided p-content and (1-alpha)-confidence
%tolerance intervals
%   TI = [Xmean_i - k * S, Xmean_i + k * S], for i = 1,...,m
%where Xmean_i = mean(X_i), X_i = [X_i1,...,X_in] is a random
%sample of size n from the distribution N(mu,sig2) with unknown mean mu and
%variance sig2, and S = sqrt(S2), where S2 is the pooled estimator of sig2,
%S2 = (1/nu) * sum_i=1:m ( sum_j=1:n (X_ij - Xmean_i)^2 ), with nu degrees
%of freedom, nu = m * (n-1).
%
%Syntax:
%k = ToleranceFactorGK(n,coverage,confidence,m)
%or
%k = ToleranceFactorGK(n,coverage,confidence,m,nu,d2,options)
%k = ToleranceFactorGK(n,coverage,confidence,m,[],[],options)
%if empty, default values are nu = m*(n-1), d2 = 1/n, 
%options is a structure with further possible specifications (see bellow).
%
%Inputs:
% - n: samlpe size
% - coverage: coverage (or content) probability,
%    Prob( Xmean - k * S < X < Xmean + k * S ) >= coverage,
% - confidence: confidence probability,
%    Prob[ Prob( Xmean - k * S < X < Xmean + k * S ) >= p ] = confidence.
% - m: number of independent random samples (of size n). If empty, default
%    value is m = 1.
% - nu: degrees of freedom for distribution of the (pooled) sample variance
%    S2. If empty, default value is nu = m*(n-1).
% - d2: normalizing constant. For computing the factors of the
%    non-simultaneous tolerance limits (xx'*betaHat +/- k * S) for the
%    linear regression y = XX*beta +epsilon, set d2 = xx'*inv(XX'*XX)*xx.
%    Typically, in simple linear regression the estimator S2 has nu = n-2 
%    degrees of freedom. If empty, default value is d2 = 1/n.
% - options: structure with further optional settings:
% - options.Simultaneous
%    logical flag for calculating the factor for the simultaneous tolerance
%    intervals. If options.Simultaneous = false, ToleranceFactor will
%    calculate the factor for the non-simultaneous tolerance interval.
%    Default value: options.Simultaneous = false;
% - options.Onesided
%    logical flag for calculating the factor the upper limit of the
%    one-sided tolerance interval; 
%    Default value: options.Onesided = false;
% - options.TailProbability
%    logical flag for representing the input probabilities 'coverage' and
%    'confidence'. If options.TailProbability = true, the input parameters
%    are represented as the tailcoverage (i.e. 1 - coverage) and
%    tailconfidence (i.e. 1 - confidence). This option is useful if
%    the interest is to calculate the tolerance factor for extremely large
%    values of coverage and/or confidence, close to 1, as e.g. 
%    coverage = 1 - 1e-18.
%    Default value: options.TailProbability = false;
%
%Output:
% - k: the calculated tolerance factor for tolerance interval
% - int: the final value of the integral for tolerance factor k. For given
%    confidence, the value of int should be close to the value of
%    tailconfidence = (1 - confidence).
% - z: for ploting the integrand, by plot(z,fun), the values on x axis 
% - fun: for ploting the integrand, by plot(z,fun), the values on y axis 
% - options: returns the actually used values in the structure options.
%
%Example:
%Calculate the tolerance factor k for the two-sided statistical p-content
%and (1-alpha)-confidence tolerance interval, with p = 0.80, and 
%(1-alpha) = 0.95.
%
%Generate the random sample X of size n = 7 from a normal distribution
%N(mu,sig2) with mu = 5, sig2 = 0.5^2 and estimate the tolerance interval,
%based on the estimated sample mean and the sample standard deviation.
%
%Check the quality of estimatd TI: Generate a new random sample Z of size
%N = 1000 from N(mu,sig2) and calculate proportion of the generated
%observations that are covered by the estimated TI.
%
%n = 7;
%p = 0.80;
%content = p;
%alpha = 0.05;
%confidence = 1-alpha
%k = ToleranceFactorGK(n,content,confidence)
%
%mu = 5; sig = 0.5; X = mu + sig * randn(1,n);
%Xmean = mean(X);
%S = std(X);
%TI = [Xmean - k * S, Xmean + k * S]
%
%N = 1000;
%Z = mu + sig * randn(1,N);
%prop = sum(TI(1) < Z & Z < TI(2))/N
%
%Dependence:
%stats\chi2inv.m
%
%See also:
%MATLAB\fzero.m, MATLAB\gammainc.m, MATLAB\erfc.m
%
%References:
%
%Krishnamoorthy K, Mathew T. (2009). Statistical Tolerance Regions: Theory,
%Applications, and Computation. John Wiley & Sons, Inc., Hoboken, New
%Jersey. ISBN: 978-0-470-38026-0, 512 pages.
%
%Witkovsky V. (2013). On the exact tolerance intervals for univariate
%normal distribution. In: Proceedings of Computer Data Analysis & Modeling
%– CDAM-2013, Minsk, Belarus, September 10-14, 2013.
%
%ISO 16269-6:2013: Statistical interpretation of data - Part 6:
%Determination of statistical tolerance intervals.
%
%Janiga I., Garaj I.: Two-sided tolerance limits of normal distributions
%with unknown means and unknown common variability. MEASUREMENT SCIENCE
%REVIEW, Volume 3, Section 1, 2003, 75-78.
%
%Cite this algorithm as:
%Witkovsky, V. (2009): ToleranceFactor - A MATLAB algorithm for computing the
%exact tolerance factors of the tolerance limits for normal distribution.
%MATLAB Central File Exchange.
%http://www.mathworks.com/matlabcentral/fileexchange/24135-tolerancefactor .
%
%Viktor Witkovsky
%Institute of Mesaurement Science
%Slovak Academy of Sciences
%Dubravska cesta 9
%84104 Bratislava
%Slovak Republic
%E-mail: witkovsky@savba.sk
%http://www.um.sav.sk/en/department-03/viktor-witkovsky.html

%(c) Viktor Witkovsky, 2009-2013, (witkovsky@savba.sk)
%Ver.: 07-Apr-2013 23:36:15
%% Check the Inputs
narginchk(1, 7);

if nargin < 2
    coverage = [];
end
if nargin < 3
    confidence = [];
end
if nargin < 4
    m = [];
end
if nargin < 5
    nu = [];
end
if nargin < 6
    d2 = [];
end
if nargin < 7
    options = struct();
end

if isempty(coverage)
    coverage = 0.95;
end
if isempty(confidence)
    confidence = 0.95;
end
if isempty(m)
    m = 1;
end
if isempty(nu)
    nu = m * (n-1);
end
if isempty(d2)
    d2 = 1/n;
end

if  isfield(options,'Simultaneous')
    simultaneous = options.Simultaneous;
else
    simultaneous = false;
end
if isfield(options,'Onesided')
    onesided = options.Onesided;
else
    onesided = false;
end
if isfield(options,'TailProbability')
    tailprob = options.TailProbability;
else   
    tailprob = false;
end
options.Simultaneous = simultaneous;
options.Onesided = onesided;
options.TailProbability = tailprob;
%% Set the Result (limit cases)
int = [];
z = [];
fun = [];
% Set values for limit cases
if confidence == 0
    k = NaN;
    return
elseif confidence == 1
    k = Inf;
    return
elseif coverage == 1
    k = Inf;
    return
elseif coverage == 0
    k =  0;
    return
end
%% Start the Algorithm
%Set the constants
if tailprob
    tailconfidence = confidence;
    tailcoverage = coverage;
else
    tailconfidence = round(1e+16*(1-confidence))/1e+16;
    tailcoverage = round(1e+16*(1-coverage))/1e+16;
end
sqrt2 =   1.4142135623730950488;
quantile1 = sqrt2 * erfcinv(tailcoverage);

%Return the result for nu = Inf 
if nu == Inf
    k = quantile1;
    return
elseif nu <= 0
    error('VW:ToleranceFactor','Degrees of freedom should be positive ...')
end

%Compute the one-sided tolerance factor
if onesided && ~simultaneous
     k = sqrt(d2)*nctinv(confidence,nu,norminv(coverage)/sqrt(d2));
%    k = sqrt(c)*nctinvVW(confidence,nu,norminv(coverage)/sqrt(c));
    return
elseif onesided
    error('VW:ToleranceFactor',...
        'NOW, the required onesided tolerance factor is not available ...')
end

%Compute the two-sided tolerance factor
%Set the tolerance for High and Low precission of the Gaussian quadrature
% tolLowPrec = 1e15*eps(tailconfidence);
tolHighPrec = eps(tailconfidence);

%Get the starting guess for the factor k0: W approximation
%Set the integration limits [A,B]. In most cases [0,10] is safe.
%In extreme cases, with confidence close to 1 (e.g. 1 - 1e-15) and with
%large number of samples m (e.g. m = 10000), the upper limit should be
%slightly greater, (e.g. B = 12). Check the integrand by plot(z,fun).
A = 0;B = 10;
% quantile1 = quantile1^2;
% quantile2 = chi2inv(tailconfidence,nu);
if m > 1
    k0 = ApproxTolFactorW(tailcoverage,tailconfidence,d2,m,nu,A,B);
else
    k0 = ApproxTolFactorWW(tailcoverage,tailconfidence,d2,nu);
end

% if nu < 2^20,
%     k0 = sqrt( nu * (1+d2) * quantile1 / quantile2);
% else
%     k0 = sqrt( (1+d2) * quantile1);
% end

% 
% if m > 1
%     %Get the improved starting value k0 of the tolerance factor
%     %k based on fast Gauss quadrature with N = 8 Legendre nodes
%     k0 = Initialize(k0,m,nu,A,B,d2,tailcoverage,tailconfidence,...
%         tolLowPrec,simultaneous);
% end

%Compute the tolerance factor
[k,int] = fzero(@(k) IntegralGK(k,nu,m,d2,tailcoverage,simultaneous,...
    A,B,tolHighPrec)...
    -tailconfidence,k0,optimset('TolX',tolHighPrec));
int = int + tailconfidence;

%This could be avoided if the is no need for plotting the integrand
z = linspace(A,B);
fun = Fun(z,k,nu,m,d2,tailcoverage,simultaneous);

% [k,int] = fzero(@(k) IntegralGK(k,nu,m,d2,tailcoverage,simultaneous,...
%     A,B,tolHighPrec)...
%     -confidence,k0,optimset('TolX',tolHighPrec));
% int = int + confidence;
% z = linspace(A,B);
% fun = Fun(z,k,nu,m,c,tailcoverage,simultaneous);
end
%% Function Initialize
function k0 = Initialize(k0,m,nu,A,B,c,tailcoverage,...
    tailconfidence,tol,simultaneous)
% Initialize returns the improved starting value k0 of the tolerance factor
% k based on fast Gauss quadrature with N = 8 Legendre nodes in the
% interval [A,B].

%(c) Viktor Witkovsky (witkovsky@savba.sk)
%Ver.: 05-Sep-2009 15:17:34

sqrt2 = 1.4142135623730950488;
sqrt2pi = 2.5066282746310005024;
[nodes,weights] = SetLegpts(A,B);
root = FindRoot(sqrt(c) * nodes,tailcoverage);
ncx2pts = nu * root.^2;
factor = exp(-0.5 * nodes.^2) / sqrt2pi;
if simultaneous
    factor = factor .* (m * (1 - (erfc(nodes ./ sqrt2))) .^(m-1));
end
k0 = fzero(@(k) IntegralGL(k,nu,weights,ncx2pts,factor)-tailconfidence,k0,...
    optimset('TolX',tol));
end
%% Function IntegralGK (Gauss-Kronod)
function int = IntegralGK(k,nu,m,c,tailcoverage,simultaneous,A,B,tol)
%IntegralGK evaluates the integral defined by eqs. (1.2.4) and (2.5.8) in
%Krishnamoorthy and Mathew: Statistical Tolerance Regions, Wiley, 2009,
%(pp.7 and 52), by the adaptive Gauss-Kronod quadrature. 
%See the MATLAB function quadgk.

%(c) Viktor Witkovsky (witkovsky@savba.sk)
%Ver.: 05-Sep-2009 15:17:34

int = 2 * quadgk(@(z) Fun(z,k,nu,m,c,tailcoverage,simultaneous),...
    A,B,'AbsTol',tol);
end
%% Function Fun (Integrand for the Gauss-Kronod quadrature)
function fun = Fun(z,k,nu,m,c,tailcoverage,simultaneous)
%Fun evaluates the Integrand function for the Gauss-Kronod quadrature.

%(c) Viktor Witkovsky (witkovsky@savba.sk)
%Ver.: 05-Sep-2009 15:17:34

sqrt2 =   1.4142135623730950488;
sqrt2pi = 2.5066282746310005024;
root = FindRoot(sqrt(c) * z,tailcoverage);
ncx2pts = nu * root.^2;
factor = exp(-0.5 * z.^2) / sqrt2pi;
if simultaneous
    factor = factor .* (m * (1 - (erfc(z ./ sqrt2))) .^(m-1));
end
x = ncx2pts / k^2;
fun = gammainc(x/2,nu/2) .* factor;

% fun = gammainc(x/2,nu/2,'upper') .* factor;
% ind = ~isfinite(x);
% fun(ind) = 0;
end
%% Function IntegralGL (Gauss-Legendre)
function int = IntegralGL(k,nu,weights,ncx2pts,factor)
%IntegralGL evaluates the integral defined by eqs. (1.2.4) and (2.5.8) in
%Krishnamoorthy and Mathew: Statistical Tolerance Regions, Wiley, 2009,
%(see pp.7 and 52), by the fast Gauss-Legendre quadrature with N = 8 nodes.

%(c) Viktor Witkovsky (witkovsky@savba.sk)
%Ver.: 05-Sep-2009 15:17:34

x = ncx2pts / k^2;
fun = gammainc(x/2,nu/2) .* factor;
int = 2 * weights' * fun;
end
%% Function FindRoot
function r = FindRoot(x,tailcoverage)
%FindRoot numerically finds the solution (root), of the equation
%normcdf(x+root) - normcdf(x-root) = coverage = 1 - tailcoverage,
%by the Halley's method for finding the root of the function fun(r) =
%fun(r|x,tailcoverage), based on two derivatives, funD1(r|x,tailcoverage)
%and funD1(r|x,tailcoverage) of the fun(r|x,tailcoverage), (for given x
%and tailcoverage).
%Note that r = sqrt(ncx2inv(1-tailcoverage,1,x^2)), where ncx2inv is the
%inverse of the noncentral chi-square cdf.

%(c) Viktor Witkovsky (witkovsky@savba.sk)
%Ver.: 05-Sep-2009 15:17:34

%Set the constants
sqrt2 =   1.4142135623730950488;
maxiter = 100;
iter = 0;

%Set the appropriate tolerance
if eps(tailcoverage) < eps
    tol = min(10*eps(tailcoverage),eps);
end

%Set the starting value of the root r: r0 = x + norminv(coverage)
r = x + sqrt2 * erfcinv(2*tailcoverage);

%Main loop (Halley's method)
while true
    iter = iter + 1;
    [fun,funD1,funD2] = ComplementaryContent(r,x,tailcoverage);
    % Halley's method
    r  = r - 2 * fun .* funD1 ./ (2 * funD1.^2 - fun .* funD2);
    if iter > maxiter
        break
    end
    if all(abs(fun) < tol)
        break
    end
end
end
%% Function ComplementaryContent
function [fun,funD1,funD2] = ComplementaryContent(r,x,tailcoverage)
%ComplementaryContent calculates difference between the complementary
%content and given the tailcoverage
%fun(r|x,tailcoverage) = 1 - (normcdf(x+r) - normcdf(x-r)) - tailcoverage,
%and the first (funD1) and the second (funD2) derivative of the function
%fun(r|x,tailcoverage)

%(c) Viktor Witkovsky (witkovsky@savba.sk)
%Ver.: 05-Sep-2009 15:17:34

sqrt2 =   1.4142135623730950488;
sqrt2pi = 2.5066282746310005024;
fun = 0.5 * ( erfc((x+r)/sqrt2) + erfc(-(x-r)/sqrt2) ) - tailcoverage;
aux1 = exp(-0.5 * (x + r).^2);
aux2 = exp(-0.5 * (x - r).^2);
funD1 = -(aux1 + aux2)/sqrt2pi;
funD2 = -((x - r) .* aux2 - (x + r) .* aux1) / sqrt2pi;
end
%% Function SetLegpts
function [nodes,weights] = SetLegpts(a,b)
% SetLegpts returns the nodes - Legendre points (N = 8) in the interval
% [a,b] and a vector of weights for Gauss quadrature.

%(c) Viktor Witkovsky (witkovsky@savba.sk)
%Ver.: 05-Sep-2009 15:17:34

nodes = [0.019855071751232; 0.101666761293187; 0.237233795041835; ...
    0.408282678752175; 0.591717321247825; 0.762766204958164; ...
    0.898333238706813; 0.980144928248768];

weights = [0.050614268145188; 0.111190517226687; 0.156853322938944; ...
    0.181341891689181; 0.181341891689181; 0.156853322938943;
    0.111190517226687; 0.050614268145188];

nodes = a + (b-a) * nodes;
weights = (b-a) * weights;
end
%% Function ApproxTolFactorWW
function [k,r] = ApproxTolFactorWW(tailcoverage,tailconfidence,c,nu)
%Compute the approximate tolerance factor (Wald-Wolfowitz)

r = FindRoot(sqrt(c),tailcoverage);
k = r * sqrt(nu/chi2inv(tailconfidence,nu));
end
%% Function ApproxTolFactorW
function [k,r] = ApproxTolFactorW(tailcoverage,tailconfidence,c,m,nu,A,B)
%Compute the approximate tolerance factor (Witkovsky)

r = sqrt(2 * quadgk(@(z) ExpectFun(z,c,tailcoverage,m),A,B));
k = r * sqrt(nu/chi2inv(tailconfidence,nu));
end
%% Function ExpectFun
function f = ExpectFun(z,c,tailcoverage,m)

sqrt2 =   1.4142135623730950488;
r = FindRoot(sqrt(c)*z,tailcoverage);
f = r.^2 .* normpdf(z);
if m > 1;
    f = f .* (m * (1 - (erfc(z ./ sqrt2))) .^(m-1));
end
end
% End of ToleranceFactor