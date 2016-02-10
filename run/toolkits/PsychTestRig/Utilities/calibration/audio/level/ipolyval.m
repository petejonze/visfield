function x = ipolyval(p,y)
% using the polynomial model in reverse
% (x-c)/m rather than mx+c (i.e. polyval)


% Ex=fliplr(1:length(z)-1)
% K=p(1:(end-1)).^Ex
% gg = z(1:(end-1)).*

    m = p(1);
    c = p(2);
    x = (y-c)/m;

end