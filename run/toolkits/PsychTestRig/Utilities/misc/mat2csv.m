function [y]=mat2csv(x, N)
% N number of decimal points precision
    if nargin < 2 || isempty(N)
        N = 7;
    end

    formatStr = repmat(sprintf('%%1.%if, ',N),1,size(x,2));
    formatStr = [formatStr(1:end-2) '\n']; % remove trailing comma/space and add linebreak
    y = sprintf(formatStr,x');
end
