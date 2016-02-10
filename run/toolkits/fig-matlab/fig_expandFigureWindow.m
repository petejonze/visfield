function [] = fig_expandFigureWindow(hFig, widthPlus, heightPlus)
% from fig_addSecondAxis

    if isempty(hFig)
        hFig = gcf;
    end

    % set all elements to have an absolute position, which will not
    % change if the figure dimensions are altered
    oldUnits = get(findobj(hFig,'-property','Units'),'Units');
    set(findobj(hFig,'-property','Units'),'Units','centimeters');
    %
    set(findall(hFig, 'Type','hggroup', '-property','Units'),'Units','centimeters') % also set any annotations with hidden handles
    annotation(hFig, 'line', [NaN NaN], [NaN NaN]); % total hack to return any annotations to the top

    % get current position/size
    pos = get(hFig,'Position'); % get current figure position

    % set modified position
    set(hFig,'Position',pos+[0 0 widthPlus heightPlus]);

    % restore old units
    o = findobj(hFig,'-property','Units');
    if ~iscell(oldUnits) % if only 1 item returned..
        oldUnits = {oldUnits};
    end
    for i = 1:length(o)
        set(o(i), 'Units', oldUnits{i});
    end
    % for-loop alternative doesn't work (?)
    % set(o, 'Units', oldUnits')
end