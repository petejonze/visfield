function h = errorbar1(X, varargin)
%FIG_MAKE shortdesc.
%
%   wrapper
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	11/10/11
% @Last Update:     14/10/11
%
% @Todo:            <blank>
%
% also: errorbar(nanmean(X), nanerr(X));

    if length(varargin) > 1
        if nargin>=3 && size(varargin{2},1)==2
            mu = varargin{1};
            bounds = varargin{2};
            L = mu-bounds(1,:);
            U = bounds(2,:)-mu;
            if nargin==3
                h = errorbar(X, mu, L, U);
            else
                h = errorbar(X, mu, L, U, varargin{3:end});
            end
        else
            h = errorbar(X, varargin{:});
        end
    elseif length(varargin) == 1
        if isnumeric(varargin{1})
            %h = errorbar(X, nanmean(varargin{1}), nanerr(varargin{1}));
            % NEW:
            x = X;
            mu = nanmean(varargin{1});
            LU = nanerr(varargin{1});
            LU = abs(bsxfun(@minus, LU, mu));
            h = errorbar(x, mu, LU(1,:), LU(2,:));
        else
            %h = errorbar(nanmean(X), nanerr(X), varargin{1});
            % NEW:
            x = 1:size(X,2);
            mu = nanmean(X);
            LU = nanerr(X);
            LU = abs(bsxfun(@minus, LU, mu));
            h = errorbar(x, mu, LU(1,:), LU(2,:), varargin{1});
        end
    else
        %h = errorbar(nanmean(X), nanerr(X));
        % NEW:
        LU = nanerr(X);
        LU = abs(bsxfun(@minus, LU, nanmean(X)));
        h = errorbar(1:size(X,2), nanmean(X), LU(1,:), LU(2,:));
    end
    
end