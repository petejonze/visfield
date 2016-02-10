function [reversalVals,idx,reversals] = getLastNReversals(x, N, nextTargWouldHaveBeen)
% x should be a binary vector [0 1]...

    if nargin < 2 || isempty(N)
        N = [];
    end
    if nargin < 3 || isempty(nextTargWouldHaveBeen)
        nextTargWouldHaveBeen = [];
    end

    changes = sign(diff(x));
    
    % but only a changes that reverse the direction are reversals
    reversals = zeros(size(x));
    lastChange = changes(1);
    for i = 1:length(changes)
        if changes(i) ~= 0 && changes(i) ~= lastChange
            reversals(i) = 1;
            lastChange = changes(i);
        end
    end
    
    if isempty(nextTargWouldHaveBeen)
        % assume that last trial is a reversal
        reversals(end) = true;
    else
        % compute whether the last trial was a reversal
        change = sign(diff([x(end) nextTargWouldHaveBeen]));
        reversals(end) = change ~= 0 & change ~= lastChange;
    end
    
    
    % remove all but last N indices
    tmp = find(reversals);
    idx = zeros(size(x));
    if isempty(N)
        idx(tmp) = 1;
    else
        idx(tmp(end-(N-1):end)) = 1;
    end
    idx = (idx == 1);
    
    % get values
    reversalVals = x(idx);
    
end