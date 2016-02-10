function [p, chi2, nDeg, grandTotal] = contTabChi2(X)
    % init
    nRows = size(X,1); % h
    nCols = size(X,2); % k
    nElements = nRows * nCols;
    nDeg = (nRows-1)*(nCols-1); % v
    
    % calc observed/expected
    O = nan(nElements, 1);
    E = nan(nElements, 1);
    grandTotal = sum(sum(X));
    
    k = 1;
    for i = 1:nRows
        rowTotal = sum(X(i,:));
        for j = 1:nCols
            colTotal = sum(X(:,j));
            
            O(k) = X(i,j);
            E(k) = (rowTotal*colTotal) / grandTotal;
            
            k = k + 1;
        end
    end

    if nDeg == 1 % use Yates' continuity correction
        chi2 = sum((abs(O-E)-.5).^2 ./ E);
    else
        chi2 = sum((O-E).^2 ./ E);
    end
    
    p = 1 - chi2cdf(chi2,nDeg); % ALT: p = gammainc(chi2/2,nDeg/2,'upper')

end