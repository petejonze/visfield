function [hXTitle,hYTitle,hTitle] = fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize, alignLbls)
%FIG_FIGFORMAT format figure window.
%
%   Step 5 in the fig package (see: help fig)
%
%   Use this for finishing the formatting of a figure. Add master titles,
%   align the subtitles, set the colours of the figure, etc.
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	hFig        Numeric         Handle to figure
%                                   @default: gcf
%
%    	xTitle      Char            Text for main X label. Use \n for
%                                   linebreaks. It is LaTeX interpreted, so
%                                   enclose mathematics inside dollar signs
%                                   (e.g., $x_{i} = 1$)
%                                   @default: []
%
%    	yTitle      Char            Text for main Y label, as per xTitle
%                                   @default: []
%
%    	mainTitle   Char            Text for main title
%                                   @default: []
%
%    	fontSize    Numeric         Fontsize for main titles
%                                   @default: 14
%
%    	alignLbls   Logical         Whether to realign any axisTitles that
%                                   were created using fig_axesFormat.m
%                                   @default: true
%
% @Returns:  
%
%       hXTitle     Numeric         Handle for main X label
%
%       hYTitle     Numeric         Handle for main Y label
%
%       hTitle      Numeric         Handle for main title
%
% @Syntax:
%
%       [hXTitle,hYTitle,hTitle] = fig_figFormat([hFig], [xTitle],[yTitle],[mainTitle], [fontSize], [alignLbls])
%
% @Example:    
%
%       hFig = gcf;
%       xTitle = 'Age, years';
%       yTitle = 'Height, cm';
%       mainTitle = [];
%       fontSize = [];
%       alignLbls = true;
%       [hXTitle,hYTitle,hTitle] = fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize, alignLbls)
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            add image resizing, as per secondaryAxes


    %% init
    if nargin < 1 || isempty(hFig)
        hFig = gcf(); % get
    end
    if nargin < 2 || isempty(xTitle)
        xTitle = [];
    end
    if nargin < 3 || isempty(yTitle)
        yTitle = [];
    end
    if nargin < 4 || isempty(mainTitle)
        mainTitle = [];
    end
    if nargin < 5 || isempty(fontSize)
        fontSize = 14;
    end
    if nargin < 6 || isempty(alignLbls)
        alignLbls = true;
    end
    
    %% validate
    if ~ishandle(hFig)
        error('fig_figFormat:invalidInput', 'Specified hFig handle (%1.2f) is not valid', hFig);
    end
    
    %% init (1b)
    fontSize = fontSize(1);
    
    %% init (2)
    hPrevGCA = gca;

    hXTitle = [];
    hYTitle = [];
    hTitle = [];
    
    hYTitle_fontSize = fontSize;
    hXTitle_fontSize = fontSize;
    
    %% init (3)
    dti = get(0,'DefaultTextInterpreter');
    %set(0,'DefaultTextInterpreter','latex')
    if ~(ismac && strcmpi(get(gcf,'Renderer'),'opengl')) % this doesn't work when using opengl on the mac
        set(0,'DefaultTextInterpreter','latex')
    else
        set(0,'DefaultTextInterpreter','tex')
    end
    
    try 
        %% Draw

        % get y sub axis titles
        hAxes = findobj(hFig,'-property','YLabel'); % only look within current figure
        hYLabels = get(hAxes,'YLabel');
        if ~iscell(hYLabels); hYLabels = {hYLabels}; end
        hYLabels = [hYLabels{:}];
        yLabels = get(hYLabels,'String');
        hYLabels = hYLabels(~strcmp(yLabels,'')); % remove blank
        %
        hYTickLabels = findobj(hFig,'tag','yTickLabel');
        
        % get x sub axis titles
        hAxes = findobj(hFig,'-property','XLabel'); % only look within current figure
        hXLabels = get(hAxes,'XLabel');
        if ~iscell(hXLabels); hXLabels = {hXLabels}; end
        hXLabels = [hXLabels{:}];
        xLabels = get(hXLabels,'String');
        hXLabels = hXLabels(~strcmp(xLabels,'')); % remove blank
        %
        hXTickLabels = findobj(hFig,'tag','xTickLabel');
        
        
        % REALIGN
        if alignLbls
            % (re)align any yAxis subtitles so that they are all
            % identically right-justified
            if length(hYLabels) > 1 % no point continuing if 1 or 0 titles
                set(hYLabels,'Units','normalized')
                p = get(hYLabels,'Position'); % get column of positions
                minPos = min(cellfun(@(x)x(1),p)); % find leftmost (right-aligned) value
                % set for all
                for i=1:length(hYLabels)
                    pos = get(hYLabels(i),'Position');
                    pos(1) = minPos;
                    set(hYLabels(i),'Position',pos);
                end
            end
            
            % (re)align any xAxis subtitles so that they are all
            % identically top-justified
            if length(hXLabels) > 1 % no point continuing if 1 or 0 titles
                set(hXLabels,'Units','normalized');
                p = get(hXLabels,'Position'); % get column of positions
                minPos = min(cellfun(@(x)x(2),p)); % find leftmost (right-aligned) value
                % set for all
                for i=1:length(hXLabels)
                    pos = get(hXLabels(i),'Position');
                    pos(2) = minPos;
                    set(hXLabels(i),'Position',pos);
                end
            end
        end
        
        % add main axes titles (X)
        if ~isempty(xTitle)

            xTickYMargin = 0.15;
            
            if ~iscellstr(xTitle)
                xTitle = regexp(xTitle,'\\n','split');
            end
            
            % draw label
            [tmp,hXTitle]=suplabel(xTitle,'x'); %#ok
            set(hXTitle,'Units','centimeters')
            
          	p = get(hXTitle,'Position');
            if ~isempty(hXLabels) % adjust to place below axis title
                yAnchor = getBottomOfStringObjects(hXLabels);
                p(2) = yAnchor - xTickYMargin;
            elseif ~isempty(hXTickLabels) % adjust to place below tickLabels
                yAnchor = getBottomOfStringObjects(hXTickLabels);
                p(2) = yAnchor - xTickYMargin;
            end
            set(hXTitle,'Position',p);
            
            % if more than 1 line will need to reduce font size
            nLines = length(xTitle);
            hXTitle_fontSize = hXTitle_fontSize / ((nLines+2)/3);
        end
        % add main axes titles (Y)
        if ~isempty(yTitle)
            
            yTickXMargin = 0.15;
            
            if ~iscellstr(yTitle)
                yTitle = regexp(yTitle,'\\n','split');
            end
            
            % draw label
            [tmp,hYTitle]=suplabel(yTitle,'y'); %#ok
            set(hYTitle,'Units','centimeters')
            
            p = get(hYTitle,'Position');
            if ~isempty(hYLabels) % adjust to place left of axis titles
                xAnchor = getLeftOfStringObjects(hYLabels);
                yTickXMargin = 0.1; % slightly smaller
                p(1) = xAnchor - yTickXMargin;
            elseif ~isempty(hYTickLabels) % adjust to place below tickLabels
                xAnchor = getLeftOfStringObjects(hYTickLabels);
                p(1) = xAnchor - yTickXMargin;
            end
            set(hYTitle,'Position',p)
            
            % if more than 1 line will need to reduce font size
            nLines = length(yTitle);
            hYTitle_fontSize = hYTitle_fontSize / ((nLines+2)/3);
            
            % N.B:
            %     z = get(hYTitle,'String')
            %     z{2} = sprintf('{\\fontsize{8}{10}\\selectfont %s}', z{2})
            %     set(hYTitle,'String',z(:))
        end 

        % add main title
        if ~isempty(mainTitle)
            [tmp,hTitle] = suplabel(mainTitle,'t'); %#ok
            fig_nudge(hTitle,0,fontSize/2,'pixel');
        end

        %% Format
%         set(hFig                                ...
%             ,'color'        , 'none'            ... %2transparent background
%            );
        set(hFig                                ...
            ,'color'        , 'w'               ... % transparent background no longer allowed, so set it to white(??)
           );
        set(hTitle                              ...
            ,'FontSize'     , fontSize      	...
           );
       set(hXTitle                              ...
            ,'FontSize'     , hXTitle_fontSize	...
           );
       set(hYTitle                              ...
            ,'FontSize'     , hYTitle_fontSize	...
           );
       
        
       
    catch ME
        sub_finishUp();
        rethrow(ME);
    end
    
    sub_finishUp();
    
    
    function [] = sub_finishUp()
        set(0,'DefaultTextInterpreter',dti) % restore previous
        axes(hPrevGCA); % restore focus to previous current axes (may be important, for example for fig_addSecondAxis)        
       	uistack(hPrevGCA,'bottom') % hmmm... but setting the focus messes up the stack order? Reset... (???)
    end
end