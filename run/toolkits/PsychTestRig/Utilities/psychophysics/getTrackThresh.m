function [thresh,reversalVals,idx] = getTrackThresh(x, N, excludeTrial, isReversal)
%getTrackThresh extract summary statistics from a block of raw data
%
%   Called by PTR's extractData() or extractData2Struct()
%   (the name of this script is fed in as a variable)
%
%   Calculates threshold as mean of last n reversals (2 and 4)
%
% @Requires:        <none>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	23/05/13
% @Last Update:     23/05/13
%
% @Todo:            <none>
    

    % Parse inputs & validate
    if ~isPositiveInt(N) && mod(N,2)==0
        error('n of reversals (%1.2f) must be an Even Integer', N);
    end
    if nargin < 3 || isempty(excludeTrial)
        excludeTrial = zeros(size(x));
    elseif ~all(size(excludeTrial)==size(x))
        error('size of excludeTrial (%i,%i) must match size of data vector, x (%i,%i)', size(excludeTrial), size(x));
    end
    if nargin < 4 || isempty(isReversal)
        isReversal = []; % optional, used to validate the manually determined values
    elseif ~all(size(isReversal)==size(x))
        error('size of isReversal (%i,%i) must match size of data vector, x (%i,%i)', size(isReversal), size(x));
    end

    % ensure all row vectors
    x = row(x);
    excludeTrial = row(excludeTrial);
    
    % Calculate reversals
    % (n.b., only changes that reverses the direction are reversals)
    changes = sign(diff(x(~excludeTrial)));
    reversals = zeros(size(x(~excludeTrial)));
    lastChange = changes(find(changes,1,'first'));
    for i = 1:length(changes)
        if changes(i) ~= 0 && changes(i) ~= lastChange
            reversals(i) = 1;
            lastChange = changes(i);
        end
    end
    reversals(end) = 1; % assume that last is a reversal
    
    % pad with zeros to make up to the right length
    tmp = zeros(size(x));
    tmp(~excludeTrial) = reversals;
    reversals = tmp;
    
    % Check reversals against template, if one supplied.
    % (n.b., only check the ones we aren't going to exclude, especially
    % since reversals in the lead-in phase can sometimes be counted
    % slightly oddly - e.g., only after first correct)
    if ~isempty(isReversal) && any(isReversal(~excludeTrial) ~= reversals(~excludeTrial))
        if size(excludeTrial,2) == find(isReversal(~excludeTrial) ~= reversals(~excludeTrial), 1, 'first')
            warning('getTrackThresh: last-trial mismatch');
        else
            isReversal = row(isReversal);
            fprintf('Found  Specified  [excluded?]\n')
            fprintf('  %i        %i           %i\n', [reversals; isReversal; excludeTrial])
            warning('Detected reversals do not match those specified manually (see breakdown, above)');
        end
    end
    
    % remove all but last N indices
    idx = find(~excludeTrial & reversals,N,'last');
    reversalVals = x(idx);
    if length(idx) < N
        thresh = NaN;
    else
        thresh = mean(reversalVals);
    end
end