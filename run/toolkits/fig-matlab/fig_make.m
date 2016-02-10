function hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims, varargin)
%FIG_MAKE Creates a figure and initialises the subplot panels.
%
%   Step 1 in the fig package (see: help fig)
%
%   Creates a figure of an appropriate size and initialises the subplot
%   panels. Sets various defaults.
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	figDim      Numeric[1-2]    Size of the figure (cm). If scalar then
%                                   will apply to both dimensions
%                                   @default: [7.5 7.5]
%
%    	nPlots      Numeric[1-2]    Number of panels in lattice. If scalar 
%                                   then will try to guess the best bumber
%                                   of rows/columns
%                                   @default: [1 1]
%
%    	isTight     Logical|Num[2]  Whether to have gaps between panels.
%                                   Alternatively may specify the gap (cm)
%                                   between the axes. False == [0 0]
%                                   @default: [0 0]
%
%    	isSquare    Logical         Whether to force panels to be square
%                                   @default: true
%
%    	styleFlag   Numeric         Default style flag. If specified then
%                                   defaults will be set for line widths/
%                                   styles, marker sizes and colour maps.
%                                   The value specifies the N colours in 
%                                   the colour map (0 for black and white)
%                                   Leave empty to not use default styles
%                                   @default: []
%   	
%    	axesLims    Numeric[2]      The min and max extent of the axes (in
%                                   normalised coords). Assumed to be the
%                                   same for both X and Y axes.
%                                   @default: [.35 .9]
%
%    	varargin                    Additional variables to be passed to
%                                   fig_subplot [see help fig_subplot]
%                                   @default: []
%
% @Returns:  
%
%       hFig   Numeric         Handle to figure
%
%
% @Syntax:
%
%       hFig = fig_make([figDim], [nPlots], [isColour], [isTight], [isSquare], [styleFlag], [axesLims], [varargin])
%
% @Example:    
%
%       figDim = [12.5 7];
%       nPlots = [2 1];
%       isTight = true;
%       isSquare = true;
%       styleFlag = [];
%       axesLims = [];
%       pkgVer = 0.1;
%       hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims, pkgVer);
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	Basic version            	[PJ]
%                   1.0.1	16/02/12	Made axes lims modifiable	[PJ]
%                   1.0.2	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            change fig2 to fig
%                   currently uses a couple of psychtestrig commands
%                   doesn't allow for axis equal
%                   see adaptiveSims_v6 for how to manipulate margin

    %% Process inputs
    if nargin < 1 || isempty(figDim)
        figDim = 8.5;
    end
    if nargin < 2 || isempty(nPlots)
        nPlots = 1;
    end  
    if nargin < 3 || isempty(isTight)
        isTight = true;
    end
    if isnumeric(isTight)
        gap = isTight;
        isTight = false;
    elseif isTight
        gap = [0,0];
    else
        gap = [.05,.05];
    end  
    
    if nargin < 4 || isempty(isSquare)
        isSquare = true;
    end
    if nargin < 5 || isempty(styleFlag)
        styleFlag = [];
    end
    if nargin < 6 || isempty(axesLims)
        axesLims = [.35 .9]; % 0 - 1
    end
    if nargin < 7
        varargin = {};
    elseif length(varargin)==1  && iscell(varargin{1})
        % if user has mistakenly passed in a cell, we'll unpack it here
        varargin = {varargin{1}{:}}; %#ok
    end
    
    % remove inner axes ticklabels (unless user has specified manually)
    if ~any(strcmpi('XTickL',varargin))
        if gap(2) == 0
            varargin = {varargin{:} 'XTickL','Margin'}; %#ok
        else
            varargin = {varargin{:} 'XTickL','All'}; %#ok
        end
    end
    if ~any(strcmpi('YTickL',varargin))
        if gap(1) == 0
            varargin = {varargin{:} 'YTickL','Margin'}; %#ok
        else
            varargin = {varargin{:} 'YTickL','All'}; %#ok
        end
    end
    
    % check specified values are valid
    if length(figDim)==1
        figDim = [figDim figDim];
    end
    figHeight = figDim(1);
    figWidth = figDim(2);
    if figWidth > 80
        error('fig_make:tooBig','Figures cannot be over 80cm wide');
    end
    if figHeight > 80
        error('fig_make:tooBig','Figures cannot be over 80cm heigh');
    end
    
    %% set text engine to LaTeX
    set(0,'DefaultTextInterpreter','latex')
        
    %% Compute plot parameters
    if length(nPlots)==1
        nRows = floor(sqrt(nPlots));
        nCols = ceil(nPlots/nRows);
    else
        nCols = nPlots(2);
        nRows = nPlots(1);
    end
    
    ss = get(0,'ScreenSize');
    mx = floor(ss(3)/2);
    my = floor(ss(4)/2);
    % convert to centimeters
    norm = 2.54 / get(0,'ScreenPixelsPerInch');
    mx = mx * norm;
    my = my * norm;


    %% Create figure
    hFig = figure('Units', 'centimeters','Position',[mx-figWidth/2 my-figHeight/2 figWidth figHeight]);

    %% calculate margin/title space
    axis_min = axesLims(1);
    axis_max = axesLims(2);
      
    axis_min_absMax = 2.2; % slightly increased to ensure that ylabels fit on
    axis_max_absMax = 2;
    
    % compress to ensure enough margin space for titles (?)
    d = min(figWidth,figHeight);
    if axis_min*d > axis_min_absMax
        axis_min = axis_min_absMax / d;
    end
    if (1-axis_max)*d > axis_max_absMax
        axis_max = 1 - axis_max_absMax / d;
    end  
    
	axis_mins = [axis_min axis_min]; % e.g. [0.25 0.25];
    axis_maxs = [axis_max axis_max]; % e.g. [.9 .9];
    
    axis_min_absMin = [.1 1.75];
    axis_max_absMax = [.1 .1];
    if axis_mins(1)*figWidth < axis_min_absMin(1)
        axis_mins(1) = axis_min_absMin(1) / figWidth;
    end
    if axis_mins(2)*figHeight < axis_min_absMin(2)
        axis_mins(2) = axis_min_absMin(2) / figHeight;
    end
    %
    if axis_maxs(1)*figWidth < axis_max_absMax(1)
        axis_maxs(1) = axis_max_absMax(1) / figWidth;
    end
    if axis_maxs(2)*figHeight < axis_max_absMax(2)
        axis_maxs(2) = axis_max_absMax(2) / figHeight;
    end 
    
    %% determine panel sizes
    if isSquare
        % get basic/max plot dimensions
        w = figWidth*(axis_max - axis_min) / nCols;
        h = figHeight*(axis_max - axis_min) / nRows;

        w = w - max(0,nCols-1)*gap(1)*figHeight;
        h = h - max(0,nRows-1)*gap(2)*figWidth;

        if w > h
            newPanelWidth = h/figWidth; % convert panel height to width units
            newTotalWidth = newPanelWidth * nCols;
            extraMargin = ((axis_max - axis_min) - newTotalWidth);
            axis_mins(1) = axis_mins(1) + extraMargin / 2;
            axis_maxs(1) = axis_maxs(1) - extraMargin / 2;
        elseif h > w
            newPanelHeight = w/figHeight;
            newTotalHeight = newPanelHeight * nRows;
            extraMargin = ((axis_max - axis_min) - newTotalHeight);
            axis_mins(2) = axis_mins(2) + extraMargin / 2;
            axis_maxs(2) = axis_maxs(2) - extraMargin / 2;
        end 
    end

	%% set formatting defaults
    if ~isempty(styleFlag)
        if styleFlag > 0
            func = @(x) colorspace('RGB->Lab',x);
            cmap = distinguishable_colors(styleFlag,'w',func);
        else
            cmap = [0 0 0; .5 .5 .5; .25 .25 .25];
        end
        % set styles
        colormap(cmap);
        set(hFig,'DefaultAxesColorOrder',cmap);
        set(hFig,'DefaultAxesLineStyleOrder',{'-','-o','--s',':^','-*'}); % '-|--|:');
        set(hFig,'DefaultLineLineWidth',1.1);
        set(hFig,'DefaultLineMarkerSize',5);
    end

    %% draw panels
  	fig_subplot(nRows,nCols,'Gap',gap,'Min',axis_mins,'Max',axis_maxs,varargin{:}); % .25 for axes, .9 on top for title and on side for consistency

    %% post-hoc formatting   
    if ~isTight
        for i=1:(nRows*nCols)
            fig_subplot(i); box off;
        end
    end

    %% finish up
    fig_subplot(1); % set focus on first panel
end