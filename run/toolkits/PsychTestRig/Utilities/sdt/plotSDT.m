function [hDistNoise hDistsSignal hDistNoiseTxt hDistsSignalTxt] = plotSDT(d, c, centreOnZero, cNames, cStyles, dNames, dStyles, showOverlap, autoFormat, xlims, txtBakCol, nName, nStyle)
%PLOTSDT shortdesc.
%
%   plot sdt params
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         close all; plotSDT([2 3 4 5 6],[1 2],false,{'sdsd','dfdf'},{'k-2','r--1'},{'k-1','b-3','k-1','k-1','k-1'},false,true)
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	06/12/11
% @Last Update:     06/12/11
%
% @Todo:            <blank>
%
% v1    :   basic
%
% set dNames to 'NaN' to supress labels

    %% parse inputs
    if nargin < 3 || isempty(centreOnZero)
        centreOnZero = false;
    end
    if nargin < 4 || isempty(cNames)
        % get criteria labels
        if length(c) == 1
            cNames = '$\lambda$'; % 'c';
        else
            cNames = strread(sprintf('$\\lambda_{%i}$\n',1:length(c)),'%s'); % strread(sprintf('$c_{%i}$\n',1:length(c)),'%s');
        end
    end
    if nargin < 5 || isempty(cStyles)
        cStyles = cellfun(@(x)'r--',cell(1,length(c)),'UniformOutput',false);
    end
    nSignals = length(d);
    if nargin < 6 || isempty(dNames)
        % get signal distribution labels
        if nSignals == 1
            dNames = 'S    ';
        else
            dNames = strread(sprintf('S%i    \n',1:nSignals),'%s');
        end
    end
    if nargin < 7 || isempty(dStyles)
        dStyles = cellfun(@(x)'k-',cell(1,length(d)),'UniformOutput',false);
    end
    if nargin < 8 || isempty(showOverlap)
        showOverlap = true;
    end
    if nargin < 9 || isempty(autoFormat)
        autoFormat = 0; % 0 = nothing; 1 = just axes (useful if doing multiple subplots); 2 = full fig
    end
    if nargin < 10 || isempty(xlims)
        xlims = []; % dynamic / fit to data
    end    
    if nargin < 11 || isempty(txtBakCol)
        txtBakCol = 'w';
    end
    if nargin < 12 || isempty(nName)
        nName = [];
    end
    if nargin < 13 || isempty(nStyle)
        nStyle = cellfun(@(x)'k-2',cell(1,length(d)),'UniformOutput',false);
    end

%     % wrap up non-cells
%     if ~iscell(cNames)
%         cNames = {cNames};
%     end
%     if ~iscell(cStyles)
%         cStyles = {cStyles};
%     end
%     if ~iscell(dNames)
%         dNames = {dNames};
%     end
%     if ~iscell(dStyles)
%         dStyles = {dStyles};
%     end
    
    %% init
    % sort descending, to minimise labels plotting over each other
    [c,idx] = sort(c,'descend');
    if ~isnan(cNames)
        cNames = cNames(idx);
    end
    cStyles = cStyles(idx);
    
    % parse criteria styles
    if ~iscell(cStyles)
        cStyles = {cStyles}; % wrap up
    end
    % color
    s = regexp(cStyles,'[bgrcmykw]','match');
    if length(s) == length(c) && ~any(cellfun(@(x)isempty(x),s))
        cColors = cellfun(@(x)x(1),s); % pick first match (should only be 1 anyway)
    else
        cColors = cellfun(@(x)'r',cell(1,length(c)),'UniformOutput',false); % fill with default values
    end
    % marker
    s = regexp(cStyles,'[.ox+*sdv\^<>ph]','match');
    if length(s) == length(c) && ~any(cellfun(@(x)isempty(x),s))
        cMarkers = cellfun(@(x)x(1),s); % pick first match (should only be 1 anyway)
    else
        cMarkers = cellfun(@(x)'none',cell(1,length(c)),'UniformOutput',false); % fill with default values
    end
    % linestyle
    s = regexp(cStyles,'(:)|(?<!-)-(?![-\.])|(-\.)|(--)','match'); % : OR - OR -. OR --
    if length(s) == length(c) && ~any(cellfun(@(x)isempty(x),s))
        cLines = cellfun(@(x)x(1),s); % pick first match (should only be 1 anyway)
    else
        cLines = cellfun(@(x)'--',cell(1,length(c)),'UniformOutput',false); % fill with default values
    end
    % linewidth
    s = regexp(cStyles,'[0-9]+(\.[0-9]+)*','match'); % any number (integer or decimal)
    if length(s) == length(c) && ~any(cellfun(@(x)isempty(x),s))
        cLineWidth = cellfun(@(x){str2double(x{1})},s); % pick first match (should only be 1 anyway)
    else
        cLineWidth = cellfun(@(x)2,cell(1,length(c)),'UniformOutput',false); % fill with default values
    end  
    
    % parse signal distribution styles [dStyles]
    if ~iscell(dStyles)
        dStyles = {dStyles}; % wrap up
    end
    % color
    s = regexp(dStyles,'[bgrcmykw]','match');
    if length(s) >= length(d) && ~any(cellfun(@(x)isempty(x),s))
        dColor = cellfun(@(x)x(1),s); % pick first match (should only be 1 anyway)
    else
        dColor = cellfun(@(x)'r',cell(1,length(d)),'UniformOutput',false); % fill with default values
    end
    % marker
    s = regexp(dStyles,'[.ox+*sdv\^<>ph]','match');
    if length(s) >= length(d) && ~any(cellfun(@(x)isempty(x),s))
        dMarker = cellfun(@(x)x(1),s); % pick first match (should only be 1 anyway)
    else
        dMarker = cellfun(@(x)'none',cell(1,length(d)),'UniformOutput',false); % fill with default values
    end
    % linestyle
    s = regexp(dStyles,'(:)|(?<!-)-(?![-\.])|(-\.)|(--)','match'); % : OR - OR -. OR --
    if length(s) >= length(d) && ~any(cellfun(@(x)isempty(x),s))
        dLineStyle = cellfun(@(x)x(1),s); % pick first match (should only be 1 anyway)
    else
        dLineStyle = cellfun(@(x)'--',cell(1,length(d)),'UniformOutput',false); % fill with default values
    end
    % linewidth
    s = regexp(dStyles,'[0-9]+(\.[0-9]+)*','match'); % any number (integer or decimal)
    if length(s) >= length(d) && ~any(cellfun(@(x)isempty(x),s))
        dLineWidth = cellfun(@(x){str2double(x{1})},s); % pick first match (should only be 1 anyway)
    else
        dLineWidth = cellfun(@(x)1,cell(1,length(d)),'UniformOutput',false); % fill with default values
    end   
    
    % parse noise distribution styles [nStyle]
    if ~iscell(nStyle)
        nStyle = {nStyle}; % wrap up
    end
    % color
    s = regexp(nStyle,'[bgrcmykw]','match');
    if length(s) >= length(d) && ~any(cellfun(@(x)isempty(x),s))
        nColor = cellfun(@(x)x(1),s); % pick first match (should only be 1 anyway)
    else
        nColor = cellfun(@(x)'r',cell(1,length(d)),'UniformOutput',false); % fill with default values
    end
    % linestyle
    s = regexp(nStyle,'(:)|(?<!-)-(?![-\.])|(-\.)|(--)','match'); % : OR - OR -. OR --
    if length(s) >= length(d) && ~any(cellfun(@(x)isempty(x),s))
        nLineStyle = cellfun(@(x)x(1),s); % pick first match (should only be 1 anyway)
    else
        nLineStyle = cellfun(@(x)'--',cell(1,length(d)),'UniformOutput',false); % fill with default values
    end
    % linewidth
    s = regexp(nStyle,'[0-9]+(\.[0-9]+)*','match'); % any number (integer or decimal)
    if length(s) >= length(d) && ~any(cellfun(@(x)isempty(x),s))
        nLineWidth = cellfun(@(x){str2double(x{1})},s); % pick first match (should only be 1 anyway)
    else
        nLineWidth = cellfun(@(x)1,cell(1,length(d)),'UniformOutput',false); % fill with default values
    end  

    % NAMES
    % wrap up names
    if ~iscell(cNames) && ~isnan(cNames)
        cNames = {cNames}; % wrap up
    end
    if ~iscell(dNames)
        dNames = {dNames}; % wrap up
    end
    % if names are to be subpressed then make a blank strcell 
    if isnan(dNames{1})
       dNames{1} = []; 
    end
    % duplicate to fill if not long enough (e.g. esp if just specified as
    % NaN)
    dNames = repmat(dNames,1,ceil(length(d)/length(dNames)));

    %% params
    a_sigma = 1;
    b_sigma = 1;
    if centreOnZero
        if length(d) > 1
            error('a:b','Only makes sense to centre on zero when we have 2 distributions');
        end
        a_mu = -d/2;
        b_mu = d/2;
        c = c -d/2;
        xlims = [-diff(xlims)/2 diff(xlims)/2]; % e.g. [-8 4] => [-6 6]. Not sure if this is a great idea or not..
%         a_mu = 0;
%         b_mu = d;
        %c = c + a_mu;
    else
        a_mu = 0;
        b_mu = d;
    end
        
    %% establish plot
    if autoFormat >= 2
        figHandle = fig_make([10 20],[],[],false,false); % false to remove box
    end
    
    %% plot data
    % get x range
    if isempty(xlims)
        if centreOnZero
            x = linspace(-2*d, 2*d, 1000);
        else
            %x = linspace(-1*mean(d), 2*mean(d), 1000);
            x = linspace(-1*max(d), 2*max(d), 1000);
        end
    else
        x = linspace(xlims(1), xlims(2), 1000);
    end
  
    % plot noise distribution
    a = normpdf(x, a_mu, a_sigma);
    % plot signal distribution(s)
    b = nan(length(x),nSignals);
    for i = 1:length(d);
        b(:,i) = normpdf(x, b_mu(i), b_sigma);
    end

    %% plot
    hold on
        % signal distributions (though first [potentially only] will be overwritten by shadedplot below)
        hDistNoise = plot(x,a);
        hDistsSignal = plot(x,b);
        % shading
        if showOverlap
            area(x, a,'FaceColor',[1 0.7 0.7],'LineStyle', 'none','LineWidth',0.1); % shade all of distribution A
            [ha hDistNoise hDistsSignal(end+1)] = shadedplot(x,a,b(:,1)','w'); %#ok recolour non-intersecting part of the left pdf in white (leaving just the overlap)
        end
        % criteria
        ylims = ylim(); % set limits
        ylims(2) = ylims(2) * 1.2; % add some additional height (criteria above distributions)
        ylim(ylims);
        if ~isempty(c)
            yInit = 1; % -.4;
            yMod = 1.1;
            if isnan(cNames)
                cNames = [];
            end
            [hC,hTxt] = vline_hacked(c,'r--',cNames,yInit,yMod,txtBakCol);
        else
            hC = []; hTxt = [];
        end
        ylims(2) = ylims(2) * 1.1; % add some additional height (criteria below top)
        ylim(ylims);
        
     	% signal distribution(s) labels
        [yy,idx] = max(b);
        yy = yy * 1.03; % nudge upwards by 3%
        xx = x(idx);
        hDistsSignalTxt = text(xx,yy,dNames(1:nSignals),'verticalalign','bottom','horizontalalign','right','backgroundcolor','none');
        % noise distribution label
        [yy,idx] = max(a);
        yy = yy * 1.03; % nudge upwards by 3%
        xx = x(idx);
        if ~isempty(nName)
            nDistName = nName;
        else
            if all(cellfun(@isempty,dNames)) % hack
                nDistName = '';
            else
                nDistName = 'N    ';
            end
        end
        hDistNoiseTxt = text(xx,yy,nDistName,'verticalalign','bottom','horizontalalign','right','backgroundcolor','none');
    hold off
    
    %% format data
    % Make styles
    % criteria
    hCriteria_propNames = {'Color','Marker','LineStyle','LineWidth'};
    hCriteria_propVals = cell(length(hC), length(hCriteria_propNames));  
    if ~isempty(c)
        hCriteria_propVals(:,1) = cColors;
        hCriteria_propVals(:,2) = cMarkers;
        hCriteria_propVals(:,3) = cLines;
        hCriteria_propVals(:,4) = cLineWidth;
    end
    % criteria text
    hTxt_propNames = {'Color'};
    hTxt_propVals = cell(length(hTxt), length(hTxt_propNames));
    if ~isempty(c)
        hTxt_propVals(:,1) = cColors;
    end
    % noise distribution
    nPlots = length(hDistNoise);
    hDistNoise_propNames = {'Color','LineStyle','LineWidth'};
    hDistNoise_propVals = cell(length(hDistNoise), length(hDistNoise_propNames));
    hDistNoise_propVals(:,1) = nColor(1:nPlots);
    hDistNoise_propVals(:,2) = nLineStyle(1:nPlots);
    hDistNoise_propVals(:,3) = nLineWidth(1:nPlots);
    % signal distribution(s)
    hDistsSignal_propNames = {'Color','Marker','LineStyle','LineWidth'};
    hDistsSignal_propVals = cell(length(hDistsSignal), length(hDistsSignal_propNames));
    hDistsSignal_propVals(:,1) = dColor(1:nSignals); % discard any extra
    hDistsSignal_propVals(:,2) = dMarker(1:nSignals);
    hDistsSignal_propVals(:,3) = dLineStyle(1:nSignals);
    hDistsSignal_propVals(:,4) = dLineWidth(1:nSignals);
   	% noise distribution text
    hDistNoiseTxt_propNames = {'Color','fontSize'};
    hDistNoiseTxt_propVals = cell(length(hDistNoiseTxt), length(hDistNoiseTxt_propNames));
    hDistNoiseTxt_propVals(:,1) = {'k'};
    hDistNoiseTxt_propVals(:,2) = {12};
 	% signal distribution(s) text
    hDistsSignalTxt_propNames = {'Color','fontSize'};
    hDistsSignalTxt_propVals = cell(length(hDistsSignalTxt), length(hDistsSignalTxt_propNames));
    hDistsSignalTxt_propVals(:,1) = dColor(1:nSignals);
    hDistsSignalTxt_propVals(:,2) = {12};

    % Apply styles
    set(hC,hCriteria_propNames,hCriteria_propVals);
    if ~isnan(hTxt), set(hTxt,hTxt_propNames,hTxt_propVals);, end
    set(hDistNoise,hDistNoise_propNames,hDistNoise_propVals);
    set(hDistsSignal,hDistsSignal_propNames,hDistsSignal_propVals);
    set(hDistNoiseTxt,hDistNoiseTxt_propNames,hDistNoiseTxt_propVals);
    set(hDistsSignalTxt,hDistsSignalTxt_propNames,hDistsSignalTxt_propVals);
    

    %% format plot
    if autoFormat >= 1
        xlims = [x(1) x(end)];
        ylims = ylim();
        axes_fontSize = 12;
        yTicks = NaN; % none
        % xticks
        if centreOnZero
            % a bit confusing, but  we often don't want to change the
            % actually values, but just the axis labels. This way the
            % distributions will appear in the same place, but just the
            % labels will change
            xticks = [a_mu 0 b_mu]; % [a_mu b_mu/2 b_mu]; % [a_mu 0 b_mu];
            xtickLbls = {'-\frac{d^{\prime}}{2}',0,'\frac{d^{\prime}}{2}'};
        else
            xticks = [0 d];
            if nSignals > 1
                % xtickLbls = [{'0'}; strread(sprintf('d_{%s}^{\\prime}\n',signalsTxt{:}),'%s')];
                xtickLbls = [{'0'}; strread(sprintf('d_{%i}^{\\prime}\n',1:nSignals),'%s')]; % No 'S' in subscript
            else
                xtickLbls = {'0' 'd^{\prime}'};
            end
        end

        % format the axes
        axesHandle = [];
        xTick = xticks;
        xTickLbl = xtickLbls;
        yTick = yTicks;
        yTickLbl = [];
        xAxisTitle = [];
        yAxisTitle = [];
        xlims = xlims; %#ok
        ylims = ylims; %#ok
        fontSize = axes_fontSize;
        [hXTickLbl, hYTickLbl, c_axes] = fig_axesFormat(axesHandle, xTick,xTickLbl, yTick,yTickLbl, xAxisTitle,yAxisTitle, xlims,ylims, fontSize);

        % hide y axis
        set(c_axes,'YColor',[1 1 1])
        
        if autoFormat >= 2
            xTitle = 'Decision Dimension';
            yTitle = []; % 'Probability Density';
            fig_fontSize = 16;
            fig_figFormat(          figHandle,xTitle,yTitle,[],fig_fontSize);
        end
        
    end
    
end