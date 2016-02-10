function [hXTickLbl, hYTickLbl, c_axes, hxAxisTitle, hyAxisTitle, axesHandle] = fig_axesFormat(axesHandle, xTick,xTickLbl, yTick,yTickLbl, xAxisTitle,yAxisTitle, xlims,ylims, fontSize, formatData, xMinorTick,yMinorTick,mrTickLgth, xRotation,yRotation, vGridColr,hGridColr)
%FIG_AXESFORMAT Format plot axes.
%
%   Step 3 in the fig package (see: help fig)
%
%   Use this for formatting the axes of a plot, or a single panel in a
%   latice. This affects tickmarks, labels, various font sizes. Use
%   fig_figFormat to finish formatting the figure.
%
%   n.b. using this script doesn't preclude further (manual) formatting
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	axesHandle  Numeric         Handle to axes. Alternatively NaN will
%                                   format all axes in current figure
%                                   @default: gca
%
%    	xTick       Numeric[n]      Vector of XTick values.
%                                   @default: current XTick values
%
%    	xTickLbl    Strcell{n}      StrCell of XTickLabel values. Accepts 
%                                   Latex formatting. Use NaN to supress 
%                                   any labels
%                                   @default: xTick
%
%    	yTick       Numeric[n]      YTick values (as per xTick)
%                                   @default: current YTick values
%
%    	yTickLbl    Strcell{n}      YTickLabel values (as per xTickLbl)
%                                   @default: yTick
%
%    	xAxisTitle  Char            ######
%                                   @default: ####
%
%    	yAxisTitle  Char            ######
%                                   @default: ####
%
%    	xlims       Numeric[2]      Vector of xAxis limits (cf. help xlim)
%                                   @default: current xlim
%
%    	ylims       Numeric[2]      Vector of yAxis limits (cf. help ylim)
%                                   @default: current ylim
%
%    	fontSize    Numeric[2]      FontSize in points to be used for
%                                   (1)axis titles & (2)tickmarks
%                                   @default: [14 10]
%
%    	formatData  Logical         ######
%                                   @default: ####
%
%    	xMinorTick  Numeric[n]      ######
%                                   @default: ####
%
%    	yMinorTick  Numeric[n]      ######
%                                   @default: ####
%
%    	mrTickLgth  Numeric         ######
%                                   @default: ####
%
%    	xRotation   Numeric         ######
%                                   @default: ####
%
%    	yRotation   Numeric         ######
%                                   @default: ####
%
%    	vGridColr   Numeric[3]      Vector of RGB colour values. If empty 
%                                   then no vertical gridlines are drawn
%                                   @default: []
%
%    	hGridColr   Numeric[3]      Horizontl RGB vector (as per vGridColr)
%                                   @default: [] 
%

%
% @Returns:  
%
%    	hXTickLbl   Numeric[n]      Handle(s) to custom xAxis tickmark labels
%
%    	hYTickLbl   Numeric[n]      Handle(s) to custom yXxis tickmark labels
%
%       c_axes      Numeric         Handle to figure
%
%
% @Syntax:
%
%       [hXTickLbl, hYTickLbl, c_axes] = fig_axesFormat([axesHandle], [xTick],[xTickLbl], [yTick],[yTickLbl], [xAxisTitle],[yAxisTitle], [xlims],[ylims], [fontSize], [formatData], [xMinorTick],[yMinorTick],[mrTickLgth], [xRotation],[yRotation], [vGridColr],[hGridColr])
%
% @Example:    
%
%       xTick = 0:0.25:1;
%       xTickLabels = 0:0.25:1;
%       yTick = 0:0.5:1;
%       yTickLabels = {'a','b','c'};
%       xAxisTitle = [];
%       yAxisTitle = [];
%       xlims = [-0.2 2];
%       ylims = [-0.2 1.5];
%       fontSize = 11;
%       formatData = false;
%       xMinorTick = 0:.1:1;
%       yMinorTick = 0:.1:1;
%       fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xAxisTitle,yAxisTitle, xlims,ylims, fontSize, formatData, xMinorTick,yMinorTick);
%
%
% @See also:        EXAMPLES.m, f_tickFormat.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	Basic version     	[PJ]
%                   1.0.1	14/11/11	Tweaks & comments	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            change fig2 to fig
%                   currently uses a couple of psychtestrig commands
%                   add option to remove leading zeros from decimals
%                   currently HACK for delete any data (log)
%
%                   mirrorYAxis probably redundent now fig_addSecondAxis
%
%                   change return arguments to: [haxes, hxAxisTitle, hyAxisTitle, hXTickLbl, hYTickLbl] = 
%
%                   fix title placement when axis location is right/top
%
% add linkaxes() ?
%
% fix y axis label when y axis ticks = NaN


  	%%%%%%%
    %% 0 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        tickLength_cm = .15;
        manualXTick = false;
        manualYTick = false;
    
        hxAxisTitle = [];
        hyAxisTitle = [];
        
  	%%%%%%%
    %% 1 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % tmp hack - without this some yticklabels were going a bit crazy when
        % using fig_corrmatrix.m
        if exist('xlims','var') && ~isempty(xlims)
            xlim(xlims)
        end
        if exist('ylims','var') && ~isempty(ylims)
            ylim(ylims)
        end

        if nargin < 1 || isempty(axesHandle)
            axesHandle = gca; % axesHandle = get(figHandle,'CurrentAxes');
        end
        
        % X TICKS
        if isnan(axesHandle)
            if nargin < 2 || isempty(xTick)
                xTick = [];
            end
            if nargin < 3 || isempty(xTickLbl)
                xTickLbl = [];
            end
        else
            if nargin < 2 || isempty(xTick)
                xTick = get(axesHandle, 'XTick');
            elseif isnan(xTick) % unless explicitly instructing to delete
                xTick = [];
            else
                manualXTick = true;
            end
            if nargin < 3 || isempty(xTickLbl)
                if manualXTick
                    xTickLbl = num2cell(xTick); % assume user just wants to use specified tick positions
                else
                    xTickLbl = get(axesHandle, 'XTickLabel'); % assume user just wants to use existing labels
                end
            elseif ~iscell(xTickLbl) & isnan(xTickLbl) %#ok unless explicitly instructing to delete
                xTickLbl = [];
            end
        end

        % Y TICKS
        if isnan(axesHandle)
            if nargin < 4 || isempty(yTick)
                yTick = [];
            end
            if nargin < 5 || isempty(yTickLbl)
                yTickLbl = [];
            end
        else
            if nargin < 4 || isempty(yTick)
                yTick = get(axesHandle, 'YTick');
            elseif isnan(xTick) % unless explicitly instructing to delete
                yTick = [];
            else
                manualYTick = true;
            end
            if nargin < 5 || isempty(yTickLbl)
                if manualYTick
                    yTickLbl = num2cell(yTick); % assume user just wants to use specified tick positions
                else
                    yTickLbl = get(axesHandle, 'YTickLabel'); % assume user just wants to use existing labels
                end
            elseif ~iscell(yTickLbl) & isnan(yTickLbl) %#ok
                yTickLbl = [];
            end
        end

        
        % AXES TITLES
        if nargin < 6 || isempty(xAxisTitle)
            xAxisTitle = [];
        end
        if nargin < 7 || isempty(yAxisTitle)
            yAxisTitle = [];
        end 

        % AXES LIMITS
        if length(axesHandle)>1
            xlims = [];
            ylims = [];
        else
            if nargin < 8 || isempty(xlims)
                xlims = xlim(); %get
                
                if manualXTick
                    if xlims(1) > min(xTick)
                        xlims(1) = min(xTick);
                    end
                    if xlims(2) < max(xTick)
                        xlims(2) = max(xTick);
                    end
                end
            end
            if nargin < 9 || isempty(ylims)
                
                ylims = ylim();
                
                if manualYTick
                    if ylims(1) > min(yTick)
                        ylims(1) = min(yTick);
                    end
                    if ylims(2) < max(yTick)
                        ylims(2) = max(yTick);
                    end
                end
            elseif strcmpi(ylims(1),'x')
                ylims = xlims;
            end
            % check for log
            if ~isnan(axesHandle)
                if (ylims(1) <= 0 && strcmpi(get(axesHandle,'YScale'),'log'))
                    fprintf('\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nWARNING: y tick-labels will not appear if the xscale is logged and xlim(1) <= 0\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n');
                end
                if (xlims(1) <= 0 && strcmpi(get(axesHandle,'XScale'),'log'))
                    fprintf('\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nWARNING: y tick-labels will not appear if the xscale is logged and xlim(1) <= 0\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n');
                end
            end
        end
        
        % FONT SIZE & FORMATTING
        if nargin < 10 || isempty(fontSize)
            fontSize = [16 12]; % [14 10]; % [tickmarks axisLabels]
        end
        if length(fontSize)==1
            fontSize = [fontSize ceil(fontSize*.75)];
        end
        if nargin < 11 || isempty(formatData)
            formatData = true;
        end

        % MINOR TICKS
        if nargin < 12 || isempty(xMinorTick)
            xMinorTick = [];
        end
        if nargin < 13 || isempty(yMinorTick)
            yMinorTick = [];
        end
        if nargin < 14 || isempty(mrTickLgth)
            mrTickLgth = 0.55; % proportion of major 2D tick length
        end

        % TICK MARK ORIENTATION
        if nargin < 15 || isempty(xRotation)
            xRotation = 0;
        end
        if nargin < 16 || isempty(yRotation)
            yRotation = 0;
        end

        % GRID LINES
        if nargin < 17 || isempty(vGridColr)
            vGridColr = [0 0 0];
            isXgrid = 'off';
        else
            isXgrid = 'on';
        end
        if nargin < 18 || isempty(hGridColr)
            hGridColr = [0 0 0];
            isYgrid = 'off';
        else
            isYgrid = 'on';
        end    
        
        % MIRROR
%         if nargin < 19 || isempty(mirrorYAxis)
%             mirrorYAxis = false;
%         end


  	%%%%%%%
    %% 1b %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% ####### %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        if length(axesHandle) > 1
            for i = 1:length(axesHandle)
                axes(axesHandle(i));
                fig_axesFormat(axesHandle(i), xTick{i},xTickLbl{i}, yTick{i},yTickLbl{i}, xAxisTitle,yAxisTitle, xlims,ylims, fontSize, formatData, xMinorTick,yMinorTick,mrTickLgth, xRotation,yRotation, vGridColr,hGridColr);
            end
            return;            
        end
            

  	%%%%%%%
    %% 2 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Set All %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if isnan(axesHandle)
            handles = fig_subplot(); 
            handles = handles(:);
            hXTickLbl = cell(1, length(handles));
            hYTickLbl = cell(1, length(handles));
            c_axes = nan(1, length(handles));
            for i = 1:length(handles)
                fig_subplot(i);
                %[hXTickLbl{i}, hYTickLbl{i}, c_axes{i}] = fig_axesFormat(gca, xTick,xTickLbl,xRotation, yTick,yTickLbl,yRotation, vGridColr,hGridColr, xlims,ylims, fontSize, formatData, xAxisTitle,yAxisTitle, xMinorTick,yMinorTick,mrTickLgth);
                [hXTickLbl{i}, hYTickLbl{i}, c_axes(i)] = fig_axesFormat(gca, xTick,xTickLbl, yTick,yTickLbl, xAxisTitle,yAxisTitle, xlims,ylims, fontSize, formatData, xMinorTick,yMinorTick,mrTickLgth, xRotation,yRotation, vGridColr,hGridColr);
            end
            return;
        end
    
  	%%%%%%%
    %% 3 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Init (2) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fh = get(axesHandle,'Parent');
        dti = get(0,'DefaultTextInterpreter');
        if ~(ismac && strcmpi(get(gcf,'Renderer'),'opengl')) % this doesn't work when using opengl on the mac
            set(0,'DefaultTextInterpreter','latex')
        else
            set(0,'DefaultTextInterpreter','tex')
        end
        hXTickLbl = []; %#ok
        hYTickLbl = []; %#ok
        
        % get pre-existing title visibility [HACKED]
        tmp = {'on','off'};
        xAxisTitle_visible = tmp{isempty(get(gca,'XTickLabel'))+1}; % 'on'; % get(get(gca,'xlabel'),'visible')
        yAxisTitle_visible = tmp{isempty(get(gca,'YTickLabel'))+1}; % get(get(gca,'ylabel'),'visible')


   	%%%%%%%
    %% 4 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Etc. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        try 
            %% Draw

            xlim(xlims);
            ylim(ylims);

            % tick marks
            % x
            if ~isempty(xTick)
                set(axesHandle,'XTick',xTick);
            end

            if ~isempty(get(axesHandle,'XTickLabel')) % i.e. will be empty if subplot has deleted the labels (i.e. if is an inner panel))
                set(axesHandle,'XTick',xTick,'XTickLabel',xTickLbl);
            end

            % y
            if ~isempty(yTick)
                set(axesHandle,'YTick',yTick);
            end
            if ~isempty(get(axesHandle,'YTickLabel')) % i.e. will be empty if subplot has deleted the labels (i.e. if is an inner panel))
                set(axesHandle,'YTick',yTick,'YTickLabel',yTickLbl);
            end

            % tick labels
            xTickLbl = get(axesHandle,'XTickLabel');
            if ischar(xTickLbl) && ~isempty(xTickLbl); xTickLbl = {xTickLbl}; end;
            yTickLbl = get(axesHandle,'YTickLabel');
            if ischar(yTickLbl) && ~isempty(yTickLbl); yTickLbl = {yTickLbl}; end;
            %

%             % add a set of ticklabels on the right if required
%             if mirrorYAxis
%                 axesHandleR = copyobj(axesHandle, gcf); % gcf == hack?
%                 set(axesHandleR, 'YAxisLocation', 'right')
%                 [~, ~] = f_tickFormat(axesHandleR,xTickLbl,yTickLbl,true,[],[],xRotation,yRotation);
%             end
            
            % Format axes
            [hXTickLbl, hYTickLbl] = f_tickFormat(axesHandle,xTickLbl,yTickLbl,true,[],[],xRotation,yRotation);

            % append to figure tag
            % this way all the xticklabels could be retrieved via:
            %     h = regexp(get(gcf,'Tag'), '(?<=x=)[\d\.]+(?=(\$))', 'match')
            %     get(cellfun(@str2num, h), 'String')
            % but note, an easier method is just to do:
            %     get(findobj(gcf,'Tag','xTickLabel'),'String')
            tag = get(fh,'Tag');
            if ~isempty(hXTickLbl)
%                 tag = sprintf('%s£x=%1.19f$',tag,hXTickLbl(1));
                tag = sprintf('%s£x=%1.19f$',tag,hXTickLbl);
            end
            if ~isempty(hYTickLbl)
                % tag = [tag '£y=' num2str(hYTickLbl(1)) '$'];
%                 tag = sprintf('%s£y=%1.19f$',tag,hYTickLbl(1));
                tag = sprintf('%s£y=%1.19f$',tag,hYTickLbl);
            end
            set(fh,'Tag',tag);


            %% Format any lines/data-markers
            if formatData

                %h = findobj(gca,'type','hggroup'); % 'line');
                h = findobj(gca,'type','hggroup','-property','linewidth'); % 'line');
                
                try
                    set(h,'linewidth',1.4);
                catch ME
                    warning(ME.message);
                end
                
%                 dflt_c = num2cell(get(fh,'DefaultAxesColorOrder'),2);
%                 l = cellstr(get(fh,'DefaultAxesLineStyleOrder'));
%                 dflt_ls = regexp(l,'[-:]+','match');
%                 dflt_ls = [dflt_ls{:}]';
%                 dflt_ms = regexp(l,'[^-:]','match');
%                 dflt_ms = [dflt_ms{:}]';
% 
%                 for i=1:length(h)
%                     c = dflt_c{rem(i-1,numel(dflt_c))+1};
% 
%                     ls = get(h(i), 'LineStyle');
%                     if ~strcmpi(ls,'none');
%                         ls = dflt_ls{rem(i-1,numel(dflt_ls))+1};
%                     else
%                         ls = 'none';
%                     end
% 
%                     ms = get(h(i), 'Marker');
%                     if ~strcmpi(ms,'none');
%                         ms = dflt_ms{rem(i-1,numel(dflt_ms))+1};
%                     else
%                         ms = 'none';
%                     end
% 
%                     set(h(i) ...
%                         ,'Color', c   ...
%                         ,'LineStyle', ls                           ...
%                         ,'Marker', ms                           ...
%                         )
%                 end
% 
%                 for i=1:length(h)
%                     hLink = regexp(get(h(i),'Tag'), '(?<=\£formatLink=)(\d+.\d+)(?=\$)', 'match');
%                     if ~isempty(hLink) % if this data has been linked to another data set (e.g. f_breakXAxis)..
%                         hLink = get(str2num(hLink{1})); %#ok convert string to num, and retrive object given handle
%                         %
%                         hLink.Color
%                         set(h(i) ... % set formatting to be equal to the linked-to's
%                             ,'Color',       hLink.Color       	...
%                             ,'LineStyle',   hLink.LineStyle     ...
%                             ,'Marker',      hLink.Marker     	...
%                             )
%                     end
%                 end
            end

            %% Format
            tickLength_norm = getUnits(axesHandle,tickLength_cm,'centimeters','normalized');
            % ,'TickLength'   , [.03 .03]     ...
%                 ,'TickDir'      , 'in'          ...            
            set(axesHandle                      ...
                ,'TickLength'   , [tickLength_norm tickLength_norm]     ...
                ,'XMinorTick'   , 'off'         ...
                ,'YMinorTick'   , 'off'         ...
                ,'XGrid'        , isXgrid     	...
                ,'YGrid'        , isYgrid       ...
                ,'XColor'       , vGridColr     ... % actually setting the grid colour, the axes are always black (see below)
                ,'YColor'       , hGridColr     ...
                ,'LineWidth'    , 1             ...
                ,'Color'        , [1 1 1]    	...
                );
            set([hXTickLbl; hYTickLbl]  	...
                ,'FontSize'     , fontSize(2) 	...
                );

            % The gridline color cannot be changed without affecting the
            % tick-mark and tick-label colors. However, you can work around
            % this issue by copying the existing axes and using it as a mask.
            % The copy will lay over the existing axes, without gridlines, and
            % using the default black for the axes tick-marks and tick-labels.
            c_axes = copyobj(axesHandle, fh); % get(axesHandle,'parent')); % Cf: c_axes = copyobj(gca,gcf);
            set(c_axes, 'color', 'none', 'xcolor', 'k', 'xgrid', 'off', 'ycolor','k', 'ygrid','off','tag','c_axes', 'XMinorTick','off'); % axes are always black

            % delete any data
            if strcmpi(get(axesHandle,'XScale'),'log') || strcmpi(get(axesHandle,'YScale'),'log')
                % HACK: temporarily disabled, seems to screw things up
                %warning('a:b','axesFormat logaxis thing tmp_disabled');
            else
                children = get(c_axes,'Children');     
                if ~isempty(children)
                    z = get(children,'type');
                    idx = ~strcmpi(z,'text'); % preserve any text (e.g. useful when break axes)            
                    delete(children(idx));
                end
            end



% delete all tick labels in the copied axis to avoid duplication
% findobj(c_axes,'Tag','xTickLabel')
delete(findobj(c_axes,'Tag','xTickLabel'));
delete(findobj(c_axes,'Tag','yTickLabel'));
% findobj(c_axes,'Tag','xTickLabel')


            % rearrange axes order so that the new child axis appears directly
            % after the original axes (this is important since the handle order
            % determines the stack / order in which objects are drawn. In
            % between their creation and the formatting call other axes may
            % have been drawn / overlayed. e.g. popout.m
            allHandles = get(fh,'children');
            %idx_master = allHandles==axesHandle; % find(allHandles==axesHandle)
            %idx_new = allHandles==c_axes; % find(allHandles==c_axes)

            allHandles(allHandles==c_axes) = []; % remove new handle
            idx_master = find(allHandles==axesHandle);
            allHandles = [allHandles(1:(idx_master-1)); c_axes; allHandles((idx_master+0):end)];

            set(fh,'children',allHandles)

            % from fig_axesFormat2.m
            % duplicate any axis label properties
            % xlabel
            h1 = get(axesHandle,'XLabel');
            h2 = get(c_axes,'XLabel');
            set(h2,'Position',get(h1,'Position'));
            % ylabel
            h1 = get(axesHandle,'YLabel');
            h2 = get(c_axes,'YLabel');
            set(h2,'Position',get(h1,'Position'));
            
            % scale
            set(c_axes,'XScale',get(axesHandle,'XScale'));
            set(c_axes,'YScale',get(axesHandle,'YScale'));
  
            
            % hide old axes
            set(axesHandle, 'visible', 'off');


%             c_axes
%             axesHandle
% axes(c_axes)          
% n.b., axesHandle contains the data handles?

%             % hide old axes
%             set(axesHandle, 'visible', 'off');

            %% add any minor ticks
            xlims = xlim();
            ylims = ylim();
            majorTickLength = get(gca,'TickLength'); majorTickLength = majorTickLength(1); % 2D

            % x
            if ~isempty(xMinorTick)
                mrTickLgth_abs = majorTickLength * (ylims(2)-ylims(1)) * mrTickLgth;
                hold on
                for x = xMinorTick
                    if ~ismember(x, get(gca, 'XTick')) % if not a major tick position already
                        h = plot([x x], [ylims(1) ylims(1)+mrTickLgth_abs], 'k-');
                        set(h, 'LineWidth', 0.1);
                    end
                end
                hold off
            end

            % y
            if ~isempty(yMinorTick)
                mrTickLgth_abs = majorTickLength * (xlims(2)-xlims(1)) * mrTickLgth;
                hold on
                for y = yMinorTick
                    if ~ismember(y, get(gca, 'YTick')) % if not a major tick position already
                        h = plot([xlims(1) xlims(1)+mrTickLgth_abs], [y y], 'k-');
                        set(h, 'LineWidth', 0.1);
                    end
                end
                hold off
            end

            %% Add any axis titles
            if ~isempty(yAxisTitle)

                yTickXMargin = 0.15;
                
                % line breaks
                if iscellstr(yAxisTitle) && length(yAxisTitle)==1
                    yAxisTitle = yAxisTitle{1};
                end
                if ~iscellstr(yAxisTitle)
                    yAxisTitle = regexp(yAxisTitle,'\\n','split');
                end
                
                % add label
                hyAxisTitle = ylabel(c_axes,yAxisTitle,'interpreter',get(0,'DefaultTextInterpreter'),'FontSize',fontSize(1),'FontWeight','bold','tag','yAxisTitle');
                set(hyAxisTitle,'units','centimeters');
                
                % shift label below tick marks
                p = get(hyAxisTitle,'Position');
                if ~isempty(hYTickLbl) % adjust to place below tickLabels
                    xAnchor = getLeftOfStringObjects(hYTickLbl);
                    p(1) = xAnchor;
                end
                p(1) = p(1) - yTickXMargin;
                set(hyAxisTitle,'Position',p); % set new postion
                
                % append handle reference to figure tag
                tag = get(fh,'Tag');
                tag = sprintf('%s£yAxisTitle=%1.19f$',tag,hyAxisTitle);
                set(fh,'Tag',tag);
                
                % apply pre-existing title visibility
                set(hyAxisTitle, 'visible', yAxisTitle_visible);
            end

            if ~isempty(xAxisTitle)
                
                xTickYMargin = 0.15;
                
                % line breaks
                if iscellstr(xAxisTitle) && length(xAxisTitle)==1
                    xAxisTitle = xAxisTitle{1};
                end
                if ~iscellstr(xAxisTitle)
                    xAxisTitle = regexp(xAxisTitle,'\\n','split');
                end
                
                % add label
                hxAxisTitle = xlabel(c_axes,xAxisTitle,'interpreter',get(0,'DefaultTextInterpreter'),'FontSize',fontSize(1),'FontWeight','bold','tag','xAxisTitle');
                set(hxAxisTitle,'units','centimeters');
                
                % shift label below tick marks
                p = get(hxAxisTitle,'Position');
                if ~isempty(hXTickLbl) % adjust to place below tickLabels
                    yAnchor = getBottomOfStringObjects(hXTickLbl);
                    p(2) = yAnchor;
                end
                p(2) = p(2) - xTickYMargin;
                set(hxAxisTitle,'Position',p); % set new postion

                % append handle reference to figure tag
                tag = get(fh,'Tag');
                tag = sprintf('%s£xAxisTitle=%1.19f$',tag,hxAxisTitle);
                set(fh,'Tag',tag);
                
                % apply pre-existing title visibility
                set(hxAxisTitle, 'visible', xAxisTitle_visible);
            end


            % ensure that all changes are made prior to any other
            % formatting commands (e.g., fig_figFormat)
            drawnow();
            
        catch ME
            sub_finishUp();
            rethrow(ME);
        end

        sub_finishUp();


        function [] = sub_finishUp()
            set(0,'DefaultTextInterpreter',dti) % restore previous
        end
end