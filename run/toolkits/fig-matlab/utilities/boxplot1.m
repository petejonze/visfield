function h = boxplot1(varargin)
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

    nNumeric = find(~cellfun(@isnumeric,varargin),1,'first')-1;
    if isempty(nNumeric)
        nNumeric = nargin;
    end
    
    X = [];
    G = [];
    for i = 1:nNumeric
        tmp = varargin{i};
        
        % remove nans
        tmp = tmp(~isnan(tmp));
        
        % append vals
        X = [X; tmp]; %#ok
        G = [G; i*ones(size(tmp))]; %#ok
    end

    pos = get(gca,'Position');
    h = boxplot(X,G,varargin{nNumeric+1:end});
    set(gca,'Position',pos);
    
end