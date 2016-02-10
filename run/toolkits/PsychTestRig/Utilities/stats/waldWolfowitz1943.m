function [p,tau] = waldWolfowitz1943(x)
% [p,tau] = waldWolfowitz1943(3-randi(2,[1 N])*2) % tau around 0 if random
% [p,tau] = waldWolfowitz1943(repmat([-1 -1 -1 -1 -1 -1 -1 -1 1 1 1 1 1 1 1],1,20)) % tau positive for too few runs (perseverance)
% [p,tau] = waldWolfowitz1943(repmat([-1 1],1,150)) % tau negative for too few many (alternation)

    N = length(x);

    R = sum(x(1:end-1).*x(2:end)) - 1;

    S1 = sum(x.^1);
    S2 = sum(x.^2);
    S3 = sum(x.^3);
    S4 = sum(x.^4);
    %
    ER = (S1^2 - S2) / (N-1);
    %
    sR = ((S2^2 - S4) / N - 1)  +  ((S1^4 - 4*S1^2*S2 + 4*S1*S3 + S2^2 - 2*S4)/((N-1)*(N-2))) - ( (S1^2 - S2)^2 / (N-1)^2 );
    sR = sqrt(sR);

    tau = (R - ER) / sR;
    p = 2*normcdf(-abs(tau));
    
end