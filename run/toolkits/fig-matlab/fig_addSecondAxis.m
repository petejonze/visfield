function [hTickLbl, hAxisLabel] = fig_addSecondAxis(hAxes, location, tick, tickLbl, axisLabel, fontSize)
%FIG_ADDSECONDAXIS Add second axis on the top/right
%
%   To be called after fig_axesFormat AND after fig_figFormat (!!!!)
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	hAxes  Numeric         Handle to axes. Alternatively NaN will
%                                   format all axes in current figure
%                                   @default: gca
%   
%       location	Char            'top' or 'right' (new axis location)
%
%    	tick        Numeric[n]      Vector of XTick values.
%                                   @default: current XTick values
%
%    	tickLbl     Strcell{n}      StrCell of XTickLabel values. Accepts 
%                                   Latex formatting. Use NaN to supress 
%                                   any labels
%                                   @default: xTick
%
%
% @Returns:  
%
%    	hTickLbl    Numeric[n]      Handle(s) to custom tickmark labels
%
%
%
% @Syntax:
%
%       ######
%
% @Example:    
%
%       #####
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	03/03/14	Basic version     	[PJ]
%
% @Todo:            must currently be called after fig_format


% fontSize = 14;
yTickXMargin = .15 + 0.15; % HACK!
xTickYMargin = 0.1;


  	%%%%%%%
    %% 1 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        if nargin < 1 || isempty(hAxes)
            hAxes = gca;
        end
axes(hAxes); % tmp hack to get it to work % <-- removed for bland altman
% plot, required for 2 panel horizontal plots
        
        if nargin < 2 || isempty(location)
            location = 'right';
        end
        
        switch lower(location)
          case 'right' % {'left', 'right'}
            isXAxis = false;
          case 'top' % {'top', 'bottom'}
            isXAxis = true;
          otherwise
            error('axis location must be one of: {''left'', ''right'', ''top'', ''bottom''}');
        end
        
        manualTick = false;
        if nargin < 3 || isempty(tick)
            if isXAxis
                tick = get(hAxes, 'XTick');
            else
                tick = get(hAxes, 'YTick');
            end
        else
            manualTick = true;
        end
        
        if nargin < 4 || isempty(tickLbl)
            if ~manualTick
                if isXAxis
                    tickLbl = flipud(get(findobj(hAxes,'Tag','xTickLabel'),'String'));
                else
                    tickLbl = flipud(get(findobj(hAxes,'Tag','yTickLabel'),'String'));
                end
                if isempty(tickLbl)
                    error('no tick labels detected and none specified? Did you remember to run fig_axesFormat first?');
                end
            else
                 tickLbl = tick; % assume user just wants to use specified tick positions (n.b., overwritten with cellstr below)
            end
        end
        if ~iscell(tickLbl) && length(tickLbl)==1 && isnan(tickLbl)
            tickLbl = [];
        end
     
        if nargin < 5
            axisLabel = [];
        end
        
        if nargin < 6 || isempty(fontSize)
            fontSize = [14 10]; % [tickmarks axisLabels]
        end
        if length(fontSize)==1
            fontSize = [fontSize ceil(fontSize*.75)];
        end
        
        
  	%%%%%%%
    %% 2 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Run %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % init
        xTickLbl = [];
        yTickLbl = [];
        
        % set normal axis to determine positions
        if isXAxis
            set(hAxes,'XTick',tick, 'XTickLabel',tickLbl, 'XAxisLocation', location)
            xTickLbl = get(hAxes, 'XTickLabel'); % tickLbl; % This way we ensure that is not numeric
            if ischar(xTickLbl) && ~isempty(xTickLbl); xTickLbl = {xTickLbl}; end;
            %             xTickLbl = tickLbl;
        else
            set(hAxes,'YTick',tick, 'YTickLabel',tickLbl, 'YAxisLocation', location)
            yTickLbl = get(hAxes, 'YTickLabel'); % tickLbl;
            if ischar(yTickLbl) && ~isempty(yTickLbl); yTickLbl = {yTickLbl}; end;
            %             yTickLbl = tickLbl
        end
        
        % add latex textfields
        [hXTickLbl, hYTickLbl] = f_tickFormat(hAxes,xTickLbl,yTickLbl,true,[],[]);
        
        % format tick labels
        set([hXTickLbl; hYTickLbl], 'FontSize', fontSize(2));
            
        % add axis label
        if ~isempty(axisLabel)
            if isXAxis
                hAxisLabel = xlabel(hAxes,axisLabel,'interpreter',get(0,'DefaultTextInterpreter'),'FontSize',fontSize(1),'FontWeight','bold','tag','secondXAxisTitle');
                set(hAxisLabel,'units','centimeters', 'Visible','on');
                
                % shift label below tick marks
                p = get(hAxisLabel,'Position');
                if ~isempty(hXTickLbl) % adjust to place below tickLabels
                    yAnchor = getTopOfStringObjects(hXTickLbl);
                    p(2) = yAnchor;
                end
                p(2) = p(2) + xTickYMargin;
                set(hAxisLabel,'Position',p); % set new postion
            else
                hAxisLabel = ylabel(hAxes,axisLabel,'interpreter',get(0,'DefaultTextInterpreter'),'FontSize',fontSize(1),'FontWeight','bold','tag','secondYAxisTitle');
                set(hAxisLabel,'units','centimeters', 'Visible','on');
                
                % shift label to the right of tick marks
                p = get(hAxisLabel,'Position');
                if ~isempty(hYTickLbl) % adjust to place below tickLabels
                    xAnchor = getRightOfStringObjects(hYTickLbl);
                    p(1) = xAnchor;
                end
                p(1) = p(1) + yTickXMargin;
                %                 extent = get(hAxisLabel,'Extent')
                %                 p(1) = p(1) + extent(4);
                set(hAxisLabel,'Position',p); % ,'VerticalAlignment','top'); % set new postion
            end
        end
 
        % Make new axes
        set(findobj(gcf,'Tag','c_axes'),'box','off');
%        	set(findobj(hAxes,'Tag','c_axes'),'box','off');

        % establish axes with same core properties as the user-specified
        % input axes: hAxes
        ax2 = axes ('Position',get(hAxes,'Position'), 'Ylim',get(hAxes,'Ylim'), 'Xlim',get(hAxes,'Xlim'), 'TickLength',get(hAxes,'TickLength'), 'XScale',get(hAxes,'XScale'), 'YScale',get(hAxes,'YScale'));
        if isXAxis
            set (ax2, 'XTick',tick, 'YTick', []);
        else
            set (ax2, 'XTick',[], 'YTick', tick);
        end
        set(ax2, 'Box', 'off', 'Color', 'none', 'XTickLabel',[], 'YTickLabel',[], 'XAxisLocation','top', 'YAxisLocation','right', 'LineWidth',1);
        
        % ensure legend stack order ok
        %(failure to do this will cause problems such as occluding the
        % fig_legend with a copied background rectangle)
        drawnow();
        uistack(findobj(gcf,'Tag','legend'),'top')
         
        
        % Expand figure to ensure new axis labels fit
        if exist('hAxisLabel','var')
            % set all elements to have an absolute position, which will not
            % change if the figure dimensions are altered
            oldUnits = get(findobj(gcf,'-property','Units'),'Units');
            set(findobj(gcf,'-property','Units'),'Units','centimeters');
            %
            set(findall(gcf, 'Type','hggroup', '-property','Units'),'Units','centimeters') % also set any annotations with hidden handles
            annotation(gcf, 'line', [NaN NaN], [NaN NaN]); % total hack to return any annotations to the top
            %
            pos = get(gcf,'Position'); % get current figure position
            p = get(hAxisLabel, 'Position'); % get label location (relative to lefthand y axis)
            e = get(hAxisLabel, 'Extent'); % [left,bottom,width,height]
            axisP = get(hAxes, 'Position');
            if isXAxis
                %             set(gcf,'Position',pos.*[1 1 1 1.05]); % expand figure height (HACK: amount to expand by is a complete guess)
                % expand exactly:
                y1 = axisP(2) + p(2) + e(4);
                pos(4) = y1; % expand figure height
            else
                %             set(gcf,'Position',pos.*[1 1 1.1 1]); % expand figure width (HACK: amount to expand by is a complete guess)
                % expand exactly:
                x1 = axisP(1) + p(1) + e(4); % n.b., assume rotated on its side (so add the height)
                pos(3) = x1; % expand figure width
            end
            % set modified position
            set(gcf,'Position',pos);
            
            % restore old units
            o = findobj(gcf,'-property','Units');
            for i = 1:length(o)
                set(o(i), 'Units', oldUnits{i});
            end
            % for-loop alternative doesn't work (?)
            % set(o, 'Units', oldUnits')
        end
        
% reorder axes stacking [Hack for patches?]
% tmp = get(gcf,'Children');
% axes(tmp(end));
        
        % set output
        if isXAxis
            hTickLbl = hXTickLbl;
        else
            hTickLbl = hYTickLbl;
        end