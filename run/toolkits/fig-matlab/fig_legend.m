function [hLeg, hBox, hChildren] = fig_legend(hAxes, hDat,datLabels, legTitle, loc, fontSize,markerSize, hScale,vScale, boxOn)
%FIG_LEGEND An expanded wrapper for the standard legend() function.
%
%   Step 4 in the fig package (see: help fig)
%
%   Allows for greater control than legend. A title can be added to the
%   legend, and the horizontal/vertical scaling can be modified. The sizes
%   of the fonts and markers can also be modified. The text is interpreted
%   in LaTeX, allowing for mathematical notation.
%
%   The exact position of the hLeg object can be tweaked posthoc using
%   fig_nudge()
%
%   KNOW BUG: setting location to 'best' (the default), can mess up any
%   LaTeX text on the axes
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	hAxes       Numeric         Handle to axes object
%                                   @default: gca
%
%    	hDat        Numeric[n]      Handle(s) to data objects, e.g., as
%                                   returned by plot()
%                                   @required
%
%    	datLabels   Cellstr{n}      Text labels for each data object / 
%                                   legend entry
%                                   @required
%
%    	legTitle    Char            An optional title for the legend (c.f.,
%                                   help f_legendTitle)
%                                   @default: []
%
%    	loc         Char            Location (c.f., help legend)
%                                   @default: 'Best'
%
%    	fontSize    Numeric         Text size in points
%                                   @default: get(hAxes,'FontSize')
%
%    	markerSize  Numeric         Size of legend markers. By default the
%                                   markersize and linewidth are determined
%                                   by the source data
%                                   @default: []
%
%    	hScale      Numeric         A scaling factor applied to the width
%                                   of any data graphic. Values less than 1
%                                   will result in any lines/patches being
%                                   horizonally compressed
%                                   @default: 0.75
%
%    	vScale      Numeric         A scaling factor applied to the
%                                   vertical spacing between legend
%                                   entries. Values less than 1 will result
%                                   in legend entries being vertically
%                                   compressed
%                                   @default: 0.75
%
%    	boxOn       Logical         Whether to include a box around the
%                                   legend
%                                   @default: false
%
%
% @Returns:  
%
%       hLeg        Numeric         Handle of the legend object
%
%
% @Syntax:
%
%       hLeg = fig_legend([hAxes], hDat,datLabels, [legTitle], [loc], [fontSize],[markerSize], [hScale],[vScale])
%
% @Example:    
%
%       figure();
%       hDat = plot(randn(20,2),'o');
%       %
%       hAxes = gca;
%       datLabels = {'Group 1','Group 2'};
%       legTitle = [];
%       loc = 'NorthEast';
%       fontSize = [];
%       markerSize = [];
%       hScale = .75;
%       vScale = .75;
%       boxOn = false;
%       hLeg = fig_legend(hAxes, hDat,datLabels, legTitle, loc, fontSize,markerSize, hScale,vScale, boxOn);
%       fig_nudge(hLeg, -.05, 0);
%
% @See also:        EXAMPLES.m, f_legTitle.m, fig_nudge.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	24/10/11    First Build             [PJ]
%                   1.0.1	26/01/11    Fixed formatting errors [PJ]
%                   1.0.2	12/05/12    Spacing options added   [PJ]
%                   1.0.3	08/10/12    Tweaks & comments       [PJ]
%
% @Todo:            - ******fix box [draw box *after* vscale?]
%                   - apply hScale to patches (example in
%                   ss11_MASTER_ANALYSIS_v7.m)
%                   - incorporate lines into patches (s11_MASTER_ANALYSIS)
%                   - background box cannot be 'nudged'
%                   - change to return separate handles for text and image
%                   child handles
%
% see acuity_MASTER_ANALYSIS_script_v1_10 for an example of adding a line
% to a patch
rightAlign = false;

    %% init
    if nargin < 1 || isempty(hAxes)
        hAxes = gca();
    end
    %
    if round(hAxes) == hAxes
        fig_subplot(hAxes);
        hAxes = gca;
    end
    
    if nargin < 2 || isempty(hDat)
        hDat = get(hAxes,'child');
        
        % remove any tick labels
        hDat(ismember(hDat,findobj(hDat,'flat','-regexp','tag','TickLabel'))) = [];
        
%         hDat = get(hAxes, 'child') % gca(); %???
    end
    
    if nargin < 3 || isempty(datLabels)
        datLabels = {};
    end
    
    if nargin < 4 || isempty(legTitle)
        legTitle = [];
    end
    
    if nargin < 5 || isempty(loc)
        loc = 'Best';
    end
    
    if nargin < 6 || isempty(fontSize)
        fontSize = get(hAxes,'FontSize');
    elseif length(fontSize) > 1
        fontSize = fontSize(2);
    end
    
    if nargin < 7 || isempty(markerSize)
        markerSize = [];
    end
    
    if nargin < 8 || isempty(hScale)
        hScale = .75; % can turn off altogether by setting as 0
    end
    if nargin < 9 || isempty(vScale)
        vScale = .75; % 1.5;
    end
    
    if nargin < 10 || isempty(boxOn)
        boxOn = false;
    end
    
    isOutside = false;
    if regexp(loc,'(.)+Outside')
        isOutside = true;
        loc = regexp('EastOutside','(.)+(?=Outside)','Match'); % strip out
        loc = loc{1};
    end
    
    % change to cell if not a cell already (i.e. just a single string)
    if ~iscell(datLabels)
        datLabels = {datLabels};
    end
    
    %% init (2)
    if round(hDat) == hDat
        fig_subplot(hDat);
        hDat = get(gca,'Children'); % grab all the data associated with these axes
    end
    
     
    if isempty(datLabels)
        nData = 0;
        for i=1:length(hDat)
            z = get(hDat(i));
            if isfield(z,'XData') % if contains data
                nData = nData + 1;
            end
        end
        datLabels = strread(sprintf('Anon-%i\n',1:nData),'%s'); %#ok
    end

        
    dti = get(0,'DefaultTextInterpreter');
    set(0,'DefaultTextInterpreter','latex')
    
    %% check for latex formatting, add if necessary
%     for i=1:length(datLabels)
%         if datLabels{i}(1)~='$'
%             datLabels{i} = ['$' datLabels{i}];
%         end
%         if datLabels{i}(end)~='$'
%             datLabels{i} = [datLabels{i} '$'];
%         end
%         % escape any unescaped backslashes
% %         datLabels{i} = regexprep(datLabels{i}, '(?<!\\)\\(?!\\)', '\\\\');
%     end

% Uncomment to add latex formatting by default
    
    %%
    try
        
        %% make
        hDat = hDat(:);
        datLabels = datLabels(:);
        hLeg = legend(hAxes, hDat, datLabels,'interpreter','latex');
        
        %% format
        set(hLeg                      	...
            ,'Box'           , 'off'       	 ...
            ,'Location'      , loc          ...
            );

        %% reposition
        if isOutside
            oldUnits = get(hLeg,'Units');
            set(hLeg, 'Units', 'normalized');
            axPos = get(hAxes,'position'); % assuming normalized
            lgPos = get(hLeg,'position');
            if strcmpi(loc, 'East')
                lgPos(1) = axPos(1) + axPos(3);
                set(hLeg, 'position', lgPos);
            else
                error('make:me','unfinished');
            end
            set(hLeg, 'Units', oldUnits);
        end

        
        %% set font size
        set(hLeg,'fontSize',fontSize);
        

       	%% change marker size
        % when using PLOT each 'child' is composed of 3 objects.
        % The first is the marker
        % The second is the line
        % The third is the text
        % HOWEVER, when using errorbar things seem to be completely fucking
        % different. Grrrrreat. Ok, so we shall start by assuming plot, and
        % if that throws an error, move on to assuming errorbar. This is
        % going to be one hell of a dodgy hack..
        hLegChildren = get(hLeg, 'children');

        
        % ok, new plan. Markers and lines are both 'line' type. Will assume
        % that come in pairs, with first the marker and second the line.
        % Will assume that all the objects of 'text' type are the labels
        hChildren = [];
        hChildren.lineMarkers = findobj(hLegChildren, 'Type', 'line');
        hChildren.hLegMarkers =  hChildren.lineMarkers(1:2:end);
        hChildren.hLegLines = hChildren.lineMarkers(2:2:end);
        hChildren.hLegText = findobj(hLegChildren, 'Type', 'text', 'Visible', 'on'); 
        hChildren.hLegPatch = findobj(hLegChildren, 'Type', 'patch');

        if ~isempty(markerSize)
            set(hChildren.hLegMarkers,'markerSize',markerSize);
        end
        
        %% vScale

        hAllObj = sort([hChildren.hLegLines; hChildren.hLegMarkers; hChildren.hLegPatch]);
        newGap = [];
        
        if length(hAllObj) > 1

            tmp1 = get(hChildren.hLegLines(:),'YData');
            if iscell(tmp1), tmp1 = cell2mat(get(hChildren.hLegLines(:),'YData')); end % if multiple will return as cell
            %
            tmp2 = get(hChildren.hLegMarkers(:),'YData');
            if iscell(tmp2), tmp2 = cell2mat(get(hChildren.hLegMarkers(:),'YData')); end % if multiple will return as cell
            %
            tmp3 = get(hChildren.hLegPatch(:),'YData');
            if iscell(tmp3), tmp3 = cell2mat(get(hChildren.hLegPatch(:),'YData')')'; end % if multiple will return as cell
            tmp3 = mean(tmp3,2); % take middle of patch
            
            oldY = [];
            if ~isempty(tmp1), oldY = [oldY; tmp1(:,1)]; end
            if ~isempty(tmp2), oldY = [oldY; tmp2(:,1)]; end
            if ~isempty(tmp3), oldY = [oldY; tmp3(:,1)]; end
            oldY = unique(oldY);
            oldGap = diff(oldY);
            newGap = oldGap * vScale;

            
            initialY = min(oldY); % y position of lowest object
            
            for i = 1:length(hChildren.hLegMarkers)
                thisY = get(hChildren.hLegMarkers(i),'YData');
                ii = find(oldY==thisY(1));
                if ii > 1 % < length(oldY)
                    newY = initialY + (ii-1).*newGap(ii-1);
                    newY = repmat(newY,size(thisY));
                    set(hChildren.hLegMarkers(i),'YData', newY);
                end
            end
            
            % adjust lines (e.g. plot.ms)
            for i = 1:length(hChildren.hLegLines)
                thisY = get(hChildren.hLegLines(i),'YData');
                ii = find(oldY==thisY(1));
                if ii > 1
                    newY = initialY + (ii-1).*newGap(ii-1);
                    newY = repmat(newY,size(thisY));
                    set(hChildren.hLegLines(i),'YData', newY);
                end
            end
            
            % adjust patches (e.g. hist.m)
            for i = 1:length(hChildren.hLegPatch)
                thisY = get(hChildren.hLegPatch(i),'YData');
                ii = find(oldY==mean(thisY));
                if ii > 1
                    newY1 = initialY + (ii-1).*newGap(ii-1);
                    oldHeight = diff(thisY([1 2]));
                    newY1 = newY1 - oldHeight/2;
                    newHeight = oldHeight*min(1,vScale); % don't bother making bigger if *increasing* linespacing
                    newY2 = newY1 + newHeight;
                    newY = [newY1 newY2 newY2 newY1];
                    set(hChildren.hLegPatch(i),'YData', newY);
                else % still need to adjust height
                    newY1 = thisY(1);
                    oldHeight = diff(thisY([1 2]));
                    newHeight = oldHeight*min(1,vScale); % don't bother making bigger if *increasing* linespacing
                    newY2 = newY1 + newHeight;
                    newY = [newY1 newY2 newY2 newY1];
                    set(hChildren.hLegPatch(i),'YData', newY);
                end
            end
            
            %
            if length(hChildren.hLegText) > 1
                tmp = cell2mat(get(hChildren.hLegText(:),'Position'));
                oldGap = diff(tmp(:,2));
                initialPos = get(hChildren.hLegText(1),'Position');
                initialY = initialPos(2);
                newGap = oldGap * vScale;
                for i = 2:length(hChildren.hLegText)
                    get(hChildren.hLegText(i),'String');
                    oldPos = get(hChildren.hLegText(i),'Position') ;
                    newY = initialY + (i-1).*newGap(i-1);
                    newPos = [oldPos(1) newY oldPos(3)];
                    set(hChildren.hLegText(i),'Position', newPos);
                end
            end
            
        end
           
        if ~isempty(regexpi(loc,'north')) && ~isempty(newGap) % shift up
            %warning('fig_legend:unstestedFunctionality','This functionality is untested!!!!')
            yShift = sum(oldGap-newGap);
            pos = get(hLeg,'Position');
            yShift = yShift * pos(3); % convert from proportion of legend to proportion of axes
            yShift = yShift / 2; % hack
            fig_nudge(hLeg, 0, yShift, 'normalized');
        end
            
        %% title
        hTitle = [];
        if ~isempty(hLeg) && ~isempty(legTitle)
            hTitle = legTitle(hLeg,legTitle);
        end
        
        %% change line width
        
        if ~isempty(hChildren.hLegLines) % if there are any lines..
            % arbitrarily use the first child as an exemplar
            XData = get(hChildren.hLegLines(1),'XData');
            XScale = XData(2) - XData(1);

            % calc shift [& shift text]
            loc = get(hLeg, 'location');
            if ~isempty(regexpi(loc,'west')) % compress holding left point constant
                tmp = get(hChildren.hLegText(1),'position');
                txtBuf = tmp(1) - XData(2); % get current gap between text and line
                XData(2) = XData(1) + XScale * hScale;  % with thanks to Hui Song on mathworks 155063
            else % compress holding right point constant
                XData(1) = XData(2) - XScale * hScale;  % with thanks to Hui Song on mathworks 155063
            end

            if XData(2) == XData(1)
                XData = [NaN NaN]; % jut hide altogether
            end

            % compress/expand lines
            set(hChildren.hLegLines,'XData',XData); 

            % nudge markers to (re)centre on the line
            set(hChildren.hLegMarkers,'XData',mean(XData));
        end
                        
        if ~isempty(hChildren.hLegPatch) % if there are any patches..
            % arbitrarily use the first child as an exemplar
            XData = get(hChildren.hLegPatch(1),'XData');
            XScale = XData(3) - XData(1);

            % calc shift [& shift text]
            loc = get(hLeg, 'location');
            if ~isempty(regexpi(loc,'west')) % compress holding left point constant
                tmp = get(hChildren.hLegText(1),'position');
                txtBuf = tmp(1) - XData(2); % get current gap between text and line
                XData(3:4) = XData(1:2) + XScale * hScale;  % with thanks to Hui Song on mathworks 155063
            else % compress holding right point constant
                XData(1:2) = XData(3:4) - XScale * hScale; 
            end

            if XData(3) == XData(1)
                XData = [NaN NaN NaN NaN]; % jut hide altogether
            end

            % compress/expand patches
            set(hChildren.hLegPatch,'XData',XData)
        end
        
        if (~isempty(hChildren.hLegLines) || ~isempty(hChildren.hLegPatch)) && ~isempty(regexpi(loc,'west'))
            % nudge text left also
            p = get(hChildren.hLegText,'position');
            if ~iscell(p)
                p = {p};
            end
            p = cellfun(@(x)([XData(end) + txtBuf x(2:end)]), p, 'UniformOutput',false);
            set(hChildren.hLegText,{'position'},p)

            % nudge the title too
            set(hTitle,'units','data')
            p = get(hTitle,'position');
            p(1) = XData(end);
            set(hTitle,'position',p);
        end
        
        
        %% clear location
        % this is useful to prevent any printing from attempting to mess
        % with the location and thereby causing things to become distorted
        set(hLeg, 'location', 'none');
        
        
        %% add box
        hBox = [];
        if boxOn
%             annotation('rectangle',get(hLeg,'Position')+[.035 0.005 -.0375 -0.0155],'Color','k')

            pos = get(hLeg,'Position');
            hDiff = pos(3) - pos(3)*hScale;
            vDiff = pos(4) - pos(4)*vScale;
            pos = pos + [hDiff/2 vDiff/2-0.01 -hDiff -vDiff];
             
            hBox = annotation(gcf,'rectangle',pos,'Color','k','FaceColor',[1 1 1],'FaceAlpha',1);
            uistack(hLeg,'top'); % ensure the rectangle is behind the text
            uistack(hBox,'bottom');
        end
        
        
        
%%
if rightAlign
    warning('fig_legend:finish me!');
    hLabels = findobj(hLeg,'-property','HorizontalAlignment')
    set(hLabels,'Units','Centimeters');
    r = getRightOfStringObjects(hLabels);
    
    for i = 1:length(hLabels)
        e = get(hLabels(i),'Extent');
        width = e(3);
        pos = get(hLabels(i),'Position');
        ri = pos(1) + width;
        pos(1) = pos(1) + (r - ri);
        set(hLabels(i),'Position', pos);
    end
end

        
    catch ME
        sub_finishUp();
        rethrow(ME);
    end

    sub_finishUp();
    
    function [] = sub_finishUp()
        set(0,'DefaultTextInterpreter',dti) % restore previous
    end

end