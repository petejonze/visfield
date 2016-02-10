function [hLegTitle] = f_legendTitle(hLeg, titleStr, varargin)
%F_LEGENDTITLE add a title to a legend.
%
%   Adapted from legendtitle.m, by Steve Simon (03/2004)
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	hLeg        Numeric         Handle to legend object
%                                   @required
%
%    	titleStr    Char            Text to use in title
%                                   @required
%
%    	varargin                    Additional parameters for text()
%                                   @default: []
%
% @Returns:  
%
%       hLegTitle   Numeric         Handle to legend title text object
%
%
% @Syntax:
%
%       [hLegTitle] = f_legendTitle(hLeg, [titleStr], [varargin])
%
% @Example:    
%
%       figure();
%       hDat = plot(randn(20),'o')
%       f_legendTitle(legend(hDat,'myData'), 'titleStr')
%
% @See also:        fig_legend.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            <none>

    % process input arguments
    if nargin < 1
        error([upper(mfilename) ' requires at least one argument.']);
    elseif nargin == 1
        if ~ischar(hLeg) && ~iscellstr(hLeg)
            error([upper(mfilename) ' requires a string, if the legend handle is not specified.'])
        else
            titleStr = cellstr(hLeg);
            hLeg = legend;
            if isempty(hLeg)
                error('No legend found.');
            end
        end
    elseif nargin == 2
        if ~ishandle(hLeg) || ~strcmp('axes',get(hLeg,'Type'))
            error('Invalid legend handle')
        end
        if ~ischar(titleStr) && ~iscellstr(titleStr)
            error('Invalid title string')
        end
    else
        if ischar(hLeg) || iscellstr(hLeg) %(titleStr,varargin)
            varargin = [{titleStr} varargin];
            titleStr = hLeg;
            hLeg = legend; 
            if isempty(hLeg)
                error('No legend found.');
            end
        elseif ~ishandle(hLeg) || ~strcmp('axes',get(hLeg,'Type'))
            error('Invalid legend handle')        
        end
        if ~ischar(titleStr) && ~iscellstr(titleStr)
            error('Invalid title string')
        end
    end

    if mod(length(varargin),2) ~= 0
        error('Incorrect specification of parameter/value pairs')
    end

    % convert to pixel units for all calculations
    legUnits = get(hLeg,'Units');
    set(hLeg,'Units','pixels');
    legPos = get(hLeg,'Position');

    % determine current top of the legend axes
    currentLegTop = legPos(2) + legPos(4);

    % store the old legend position
    oldLegPos = legPos;

    % find the text objects in the legend
    htxt = findobj(hLeg,'Type','text');

    % set the text Units to pixels
    txtUnits = get(htxt,'Units');
    set(htxt,'Units','pixels');
    txtExtent = get(htxt,'Extent');
    %txtPos = get(htxt,'Position');
    %txtStr = get(htxt,'String');

    % determine height for each row of text
    %numRows = size(txtStr,1);
    if iscell(txtExtent)
        % sort by y position
        txtExtent = sortrows(cat(1,txtExtent{:}),-2);        
        topTextTop = txtExtent(1,2) + txtExtent(1,4);
    else
        topTextTop = txtExtent(2) + txtExtent(4);
    end

    % new height for the legend axes, based on number of rows in title

    legPos(4) = max(legPos(4),topTextTop + 5);

    newHeight = legPos(4);

    newPos = [legPos(1), currentLegTop - newHeight, legPos(3:4)];

    % determine new YLim for the legend axes
    legYLim = get(hLeg,'YLim');
    yLengthPerPixel = diff(legYLim)/oldLegPos(4);
    newYLim = [legYLim(1) yLengthPerPixel * newHeight];

    % change the YLim and Position of the axes, so it can contain the title
    set(hLeg,'YLim',newYLim,'Position',newPos);

    legXLim = get(hLeg,'XLim');

    % see if there is already a legend title object:
    holdtitle = getappdata(hLeg,'LegendTitleHandle');
    if isempty(holdtitle)
        % create the text object
        htitletxt = text('Parent',hLeg,...
                         'Units','pixels',...
                         'Position',[diff(legXLim)/2, (topTextTop + 5)],...
                         'VerticalAlignment','bottom',...
                         'String',titleStr,...
                         'FontWeight','bold',...
                         'FontName',get(hLeg,'FontName'),...
                         'Tag','LegendTitle',...
                         'HandleVisibility','off',...
                         varargin{:});
    else
        htitletxt = holdtitle;
        set(htitletxt,'String',titleStr,varargin{:})
    end


    % make sure the title doesn't extend beyond the axes           
    currentLegRight = newPos(1) + newPos(3);
    xLengthPerPixel = diff(legXLim)/newPos(3);

    newTxtExtent = get(htitletxt,'Extent');
    if newTxtExtent(1)  < 0 || newTxtExtent(1) +  newTxtExtent(3) > newPos(3)        
        newWidth = max(newTxtExtent(3) + 10,txtExtent(1,1) + txtExtent(1,3));
        newPos = [currentLegRight - newWidth, newPos(2), newWidth, newPos(4)];
        newXLim = [legXLim(1) xLengthPerPixel*newWidth];
        set(hLeg,'Position',newPos,'XLim',newXLim);
    elseif newTxtExtent(1) + newTxtExtent(3) < txtExtent(1,1) + txtExtent(1,3)  || newTxtExtent(3) + 10 < newPos(3)
        newWidth = max(newTxtExtent(3) + 10,txtExtent(1,1) + txtExtent(1,3));
        newPos = [ currentLegRight - newWidth, newPos(2), newWidth,newPos(4)];
        newXLim = [legXLim(1) xLengthPerPixel*newWidth];
        set(hLeg,'Position',newPos,'XLim',newXLim);
    end

    legYLim = get(hLeg,'YLim');
    yLengthPerPixel = diff(legYLim)/newPos(4);
    currentLegTop = newPos(2) + newPos(4);
    if newTxtExtent(2) + newTxtExtent(4) + 10 > newPos(4)
       newHeight = newTxtExtent(2) + newTxtExtent(4) + 10;
       newPos = [newPos(1), currentLegTop - newHeight, newPos(3),newHeight];
       newYLim = [legYLim(1) yLengthPerPixel*newHeight];
       set(hLeg,'Position',newPos,'YLim',newYLim)
    end

    % now, make sure the title is centered
    %legXLim = get(hLeg,'XLim');
    currentPos = get(hLeg,'Position');
    txtPos = get(htitletxt,'Position');
    set(htitletxt,'Position',[currentPos(3)/2 txtPos(2:3)],...
        'HorizontalAlignment','center');

    % restore Units
    set(hLeg,'Units',legUnits);
    set(htxt,{'Units'},cellstr(txtUnits));

    % store the legend title
    setappdata(hLeg,'LegendTitleHandle',htitletxt)

    % return handle to text
    if nargout
        hLegTitle = htitletxt;
    end
    
end