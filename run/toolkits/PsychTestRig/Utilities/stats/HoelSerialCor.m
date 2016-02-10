function [p,R] = HoelSerialCor(y)
% Perform the non-parametric serial correlation of lag=1 , from 13.4 of
% Hoel (1947) Introduction to Mathematical Statistics
% (code from mess_serial_correlation
% EXAMPLE:
% y = [.22 .213 .221 .222 .219 .214 .222 .216 .212 .221 .223 .214 .221 .216 .217 .215]'
% HoelSerialCor(y)
%
% [p,R] = HoelSerialCor([1 1 1 1 2 2 2 2 2 1 1 1 1 1 1 2 2 2 2 2 2 2])
% [p,R] = HoelSerialCor([1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2])

    % init
    n = length(y);

    % calc
    S = (y-mean(y));
    S1 = sum(S.^1);
    S2 = sum(S.^2);
    S3 = sum(S.^3);
    S4 = sum(S.^4);
    %
    E_R = (S1^2 - S2) / (n-1);
    sigmaR = sqrt( (S2^2 - S4) / (n-1) );
    %
    ss = S; ss(end+1) = ss(1);
    R = sum( S(1:end).*ss(2:end) );
    %
    tau = (R - E_R) / sigmaR;
    %
    p = 2*normcdf(-abs(tau));

end