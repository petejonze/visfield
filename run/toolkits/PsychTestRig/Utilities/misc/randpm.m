function y = randpm(m,n)
% [m x n] matrix of (random) +/-1
    
    if nargin < 2 || isempty(n)
        n = m;
    end
    
    y = 1 - (Randi(2,[m,n])-1)*2;

end