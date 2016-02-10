function [hx,hy] = f_tickFormat(hAxes, xTickLbl,yTickLbl, forceLatex, xTick,yTick, rotx,roty, offset, varargin)
%F_TICKFORMAT improved TickLabels.
%
%   Replace or appends XTickLabels and YTickLabels of axis handle hAxes
%   with input xTickLbl and yTickLbl array. Adapted from format_tick.m, by Alex
%   Hayes (08/2007)
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	hAxes       Numeric         Handle of axis to change tick labels
%                                   @default: gca
%
%    	xTickLbl       Cellstr{n}      Cell array of XTickLabels to append to
%                                   current labels
%                                   @default: get(hAxes,'XTickLabel');
%
%    	yTickLbl       Cellstr{n}      Cell array of YTickLabels, as per xTickLbl
%                                   @default: get(hAxes,'YTickLabel');
%
%    	forceLatex  Logical         If true then all text is wrapped in
%                                   dollar signs (inline math mode)
%                                   @default: false
%
%    	xTick    Numeric[n]      Vector of x positions at which to place
%                                   the XTickLabels
%                                   @default: get(hAxes,'XTick')
%
%    	yTick    Numeric[n]      Vector of y positions, as per xTick
%                                   @default: get(hAxes,'YTick')
%
%    	rotx        Numeric         Number of degrees to rotate XTickLabels
%                                   @default: 0
%
%    	roty        Numeric         Number of degrees to rotate YTickLabels
%                                   @default: 0
%
%    	offset      Numeric         Label offsets from axis in cm
%                                   @default: 0.2
%
%    	varargin                    Additional parameters for text()
%                                   @default: []
%
% @Returns:  
%
%       hx          Numeric[n]      Handles(s) of text object(s) used as
%                                   XTickLabels
%
%       hy          Numeric[n]      Handles of YTickLabels, as per hx
%
%
% @Syntax:
%
%       [hx,hy] = f_tickFormat([hAxes], [xTickLbl],[yTickLbl], [forceLatex], [xTick],[yTick], [rotx],[roty], [offset], [varargin])
%
% @Example:    
%
%       figure(); plot(randn(20),'o');
%       %
%       hAxes = gca;
%       xTickLbl = {'$0$','$2\frac{1}{2}$','$5$','$7\frac{1}{2}$','$10$'};
%       yTickLbl = arrayfun(@(x)sprintf('$%i^{\\circ}$',x),-3:3,'uni',0);
%       forceLatex = false;
%       xTick = [0,2.5,5,7.5,10];
%       yTick = -3:3;
%       rotx = 0;
%       roty = 45;
%       offset = [];
%       varargin = {'FontWeight','Bold'};
%       f_tickFormat(hAxes, xTickLbl,yTickLbl, forceLatex, xTick,yTick, rotx,roty, offset, varargin{:})
%
% @See also:        fig_axesFormat.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/12	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            <none>

hx = []; hy = [];

% %define axis text offset (percentage of total range)
% if ~exist('offset','var') || isempty(offset)
%     offset = 0.02;
% end;
%define axis text offset (cm)
if ~exist('offset','var') || isempty(offset)
    xTickLbl_offset = .2; % cm
    yTickLbl_offset = .2; % cm
else
   xTickLbl_offset = offset;
   yTickLbl_offset = offset;
end
% xTickLbl_offset_norm = getUnits(h,xTickLbl_offset,'centimeters');
% yTickLbl_offset_norm = getUnits(h,yTickLbl_offset,'centimeters');
xTickLbl_offset_dat = getUnits(hAxes,xTickLbl_offset,'centimeters','data',1); % text is set to Data units by default. Dim is 1 because we are arranging the VERTICAL position of the xAxis ticks!
yTickLbl_offset_dat = getUnits(hAxes,yTickLbl_offset,'centimeters','data',2);

if nargin<4 || isempty(forceLatex)
    forceLatex = false;
end
 
%make sure the axis handle input really exists
if ~exist('hAxes','var');
    hAxes = gca;
    warning('f_tickFormat:bad_input',['Axis handle NOT Input, Defaulting to Current Axes, '...
        num2str(hAxes)]);
elseif isempty(hAxes);
    hAxes = gca;
    warning('f_tickFormat:bad_input',['Axis Handle NOT Input, Defaulting to Current Axes, '...
        num2str(hAxes)]);
elseif ~ishandle(hAxes(1))
    warning('f_tickFormat:bad_input',['Input (' num2str(hAxes(1)) ') is NOT an axis handle, ' ...
        'defaulting to current axis, ' num2str(h)]);
        hAxes = gca;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%BEGIN: FIRST THE X-AXIS TICK LABELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fix the XTickLabels if they have been erased in the past
% no - now just skips if xlabel is blank
if isempty((get(hAxes,'XTickLabel')))
    % set(h,'XTickLabel',get(h,'XTick'));
    hx = [];
else
    
    % temporarily set the xtick positions if entered (n.b., may seem a bit
    % long-winded, but by setting then getting, invalid points will
    % automatically be weeded out)
    if exist('xTick','var')
        if ~isempty(xTick);
            set(hAxes,'XTick',xTick);
        end;
        xTick = get(hAxes,'XTick');
        set(hAxes,'XTickLabel',xTick);
    end;
    
    % get tick positions (irrespective of whether or not specified
    % manually)
    xTick = get(hAxes,'XTick');

    %get the tick labels and positions if the user did not input them
    if ~exist('xTickLbl','var');
        xTickLbl = get(hAxes,'XTickLabel');
        if ischar(xTickLbl);
            temp = xTickLbl;
            xTickLbl = cell(1,size(temp,1));
            for j=1:size(temp,1);
                xTickLbl{j} = strtrim( temp(j,:) );
            end;
        end;
        append = '^{\circ}';
        for j=1:length(xTickLbl);
            xTickLbl{j} = [xTickLbl{j} append];
        end;
    elseif isempty(xTickLbl);
        xTickLbl = get(hAxes,'XTickLabel');
        if ischar(xTickLbl);
            temp = xTickLbl;
            xTickLbl = cell(1,size(temp,1));
            for j=1:size(temp,1);
                xTickLbl{j} = strtrim( temp(j,:) );
            end;
        end;
        append = '^{\circ}';
        for j=1:length(xTickLbl);
            xTickLbl{j} = [xTickLbl{j} append];
        end;
    elseif ischar(xTickLbl);
        append = xTickLbl;
        xTickLbl = get(hAxes,'XTickLabel');
        if ischar(xTickLbl);
            temp = xTickLbl;
            xTickLbl = cell(1,size(temp,1));
            for j=1:size(temp,1);
                xTickLbl{j} = strtrim( temp(j,:) );
            end;
        end;
        if strcmp(append(1),'$');
            for j=1:length(xTickLbl);
                xTickLbl{j} = ['$' xTickLbl{j} append(2:end)];
            end;
        else          
            for j=1:length(xTickLbl);
                xTickLbl{j} = [xTickLbl{j} append];
            end;
        end;
    elseif ~iscell(xTickLbl );
        warning('f_tickFormat:bad_input',['Input TICKX variable is not a compatible string ' ...
            'or cell array! Returning...']);
        return;
    elseif iscell(xTickLbl) && length(xTickLbl)==1 && ischar(xTickLbl{1}) %pj
        xTickLbl = cellstr(xTickLbl{1})';
    end
    
    %find out if we have to use the LaTex interpreter
    if ~forceLatex
        temp = xTickLbl{1};
        if strcmp(temp(1),'$');
            latex_on = 1;
        else
            latex_on = 0;
        end;
    else
        xTickLbl = cellfun(@(x)['$' x '$'], xTickLbl,'UniformOutput',false);
        latex_on = 1;
    end
    
    %erase the current tick label
    set(hAxes,'XTickLabel',{});
    
    % erase any tickmarks that lie outside the axis limits
    xlims =   get(hAxes,'XLim');
    idx_outOfRange = xTick < xlims(1) | xTick > xlims(2);
    if any(idx_outOfRange)
        warning('f_tickFormat:bad_input','Reducing length of xTick! (Out of range of xlims)');
        xTick(idx_outOfRange) = [];
        xTickLbl(idx_outOfRange) = [];
    end

    %set the new tick positions
    set(hAxes,'XTick',xTick);
    
    %check the lengths of the xtick positions and xtick labels match
    %(remove any unnecessary labels)
    l1 = length(xTickLbl);
    l2 = length(xTick);
    if l1==0; 
        set(hAxes,'XTickLabel',xTickLbl);
    end;
    if l1~=l2;
        disp(['Length of XTick = ' num2str(length(xTick))]);
        disp(['Length of XTickLabel = ' num2str(length(xTickLbl))]);
        if l2 < l1;
            warning('f_tickFormat:bad_input','Reducing Length of XTickLabel!');
        else
            warning('f_tickFormat:bad_input','Reducing Length of XTick!');
        end;   
        l3 = min([l1,l2]);
        xTickLbl = xTickLbl(1:l3);
        xTick = xTick(1:l3);
    end;
    
    %set rotation to 0 if not input
    if ~exist('rotx','var');
        rotx = 0;
    elseif isempty(rotx); 
        rotx = 0;
    end;
    
    %Convert the cell labels to a character string
    xTickLbl = cellstr(xTickLbl);
    
    %Make the XTICKS!
    if rotx == 0;
        hAlign = 'center';
        vAlign = 'top';
    elseif rotx < 0;
        hAlign = 'left';
        vAlign = 'middle';   
    else
        hAlign = 'right';
        vAlign = 'middle';      
    end
    %
    if latex_on;
        interp = 'LaTex';
    else
        interp = 'Tex';
    end
    
    if strcmpi(get(hAxes, 'XAxisLocation'), 'top')
        isTophand = true;
        vAlign = 'bottom';
    else
        isTophand = false;
    end
    
    % PLOT----------------------------------
    lim = get(hAxes,'YLim');
    if strcmp(get(hAxes,'YScale'), 'log') % reintroduced to get corrmatrix working
        if isTophand
            yposition = 10^(log10(lim(2)) + xTickLbl_offset_dat);
        else
            yposition = 10^(log10(lim(1)) - xTickLbl_offset_dat);
        end
    else
        if isTophand
            yposition = lim(2) + xTickLbl_offset_dat;
        else
            yposition = lim(1) - xTickLbl_offset_dat; % shift xTicks down
        end
        
    end 
    hx = text(xTick,...
        repmat(yposition,length(xTick),1),...
        xTickLbl,'HorizontalAlignment',hAlign,...
        'VerticalAlignment',vAlign,'rotation',rotx,'interpreter',interp,'tag','xTickLabel'); % useful when debugging: ,'BackgroundColor',[.7 .9 .7]);
    % PLOT----------------------------------
    
    %Get and set the text size and weight
    set(hx,'FontSize',get(hAxes,'FontSize'));
    set(hx,'FontWeight',get(hAxes,'FontWeight'));

    %Set the additional parameters if they were input
    if length(varargin) > 2;
        command_string = 'set(hx';
        for j=1:2:length(varargin);
            command_string = [command_string ',' ...
                '''' varargin{j} ''',varargin{' num2str(j+1) '}']; %#ok
        end;
        command_string = [command_string ');'];
        eval(command_string);
    end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%END: FIRST THE X-AXIS TICK LABELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%BEGIN: NOW THE Y-AXIS TICK LABELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%only move forward if we are doing anything to the yticks
if ~exist('yTickLbl','var') || isempty(yTickLbl) || isempty((get(hAxes,'YTickLabel')))
    hy = []; % empty is better than -1, since less likely throw invalid handle exceptions
else
    %fix the YTickLabels if they have been erased in the past
    if isempty(get(hAxes,'YTickLabel'));
        set(hAxes,'YTickLabel',get(hAxes,'YTick'));
    end;
    
    % temporarily set the ytick positions if entered (n.b., may seem a bit
    % long-winded, but by setting then getting, invalid points will
    % automatically be weeded out)
    if exist('yTick','var');
        if ~isempty(yTick);
            set(hAxes,'YTick',yTick);
            set(hAxes,'YTickLabel',yTick);
        end;
    end;
    
    % get tick positions (irrespective of whether or not specified
    % manually)
    yTick = get(hAxes,'YTick');

    %get the tick labels and positions if the user did not input them
    if ~exist('yTickLbl','var');
        yTickLbl = get(hAxes,'YTickLabel');
        if ischar(yTickLbl);
            temp = yTickLbl;
            yTickLbl = cell(1,size(temp,1));
            for j=1:size(temp,1);
                yTickLbl{j} = strtrim( temp(j,:) );
            end;
        end;
        append = '^{\circ}';
        for j=1:length(yTickLbl);
            yTickLbl{j} = [yTickLbl{j} append];
        end;
    elseif isempty(yTickLbl);
        yTickLbl = get(hAxes,'YTickLabel');
        if ischar(yTickLbl);
            temp = yTickLbl;
            yTickLbl = cell(1,size(temp,1));
            for j=1:size(temp,1);
                yTickLbl{j} = strtrim( temp(j,:) );
            end;
        end;
        append = '^{\circ}';
        for j=1:length(yTickLbl);
            yTickLbl{j} = [yTickLbl{j} append];
        end;
    elseif ischar(yTickLbl);
        append = yTickLbl;
        yTickLbl = get(hAxes,'YTickLabel');
        if ischar(yTickLbl);
            temp = yTickLbl;
            yTickLbl = cell(1,size(temp,1));
            for j=1:size(temp,1);
                yTickLbl{j} = strtrim( temp(j,:) );
            end;
        end;
        if strcmp(append(1),'$');
            for j=1:length(yTickLbl);
                yTickLbl{j} = ['$' yTickLbl{j} append(2:end)];
            end;
        else
            for j=1:length(yTickLbl);
                yTickLbl{j} = [yTickLbl{j} append];
            end;
        end;
    elseif ~iscell(yTickLbl );
        warning('f_tickFormat:bad_input',['Input TICKY variable is not a compatible string ' ...
            'or cell array! Returning...']);
        return;
    elseif iscell(yTickLbl) && length(yTickLbl)==1 && ischar(yTickLbl{1}) %pj
        yTickLbl = cellstr(yTickLbl{1})';
    end
    
    %find out if we have to use the LaTex interpreter
    if ~forceLatex
        temp = yTickLbl{1};
        if strcmp(temp(1),'$');
            latex_on = 1;
        else
            latex_on = 0;
        end;
    else
        yTickLbl = cellfun(@(x)['$' x '$'], yTickLbl,'UniformOutput',false);
        latex_on = 1;
    end
    
    %erase the current tick label
    set(hAxes,'YTickLabel',{});

    %get the x tick positions if the user did not input them  
    if ~exist('xTick','var');
        xTick = get(hAxes,'XTick'); %????? CHANGED FROM YTICK(????)
    elseif isempty(xTick);
        xTick = get(hAxes,'XTick');
    end;
      
  	% erase any tickmarks that lie outside the axis limits
    ylims =   get(hAxes,'YLim');
    idx_outOfRange = yTick < ylims(1) | yTick > ylims(2);
    if any(idx_outOfRange)
        warning('f_tickFormat:bad_input','Reducing length of yTick! (Out of range of ylims)');
        yTick(idx_outOfRange) = [];
        yTickLbl(idx_outOfRange) = [];
    end
    
    %set the new tick positions
    set(hAxes,'YTick',yTick)
    
    %check the lengths of the xtick positions and xtick labels match
    %(remove any unnecessary labels)
    l1 = length(yTickLbl);
    l2 = length(yTick);
    if l1==0;
        set(hAxes,'YTickLabel',yTickLbl);
    end;
    if l1~=l2;
        disp(['Length of YTick = ' num2str(length(yTick))]);
        disp(['Length of YTickLabel = ' num2str(length(yTickLbl))]);
        if l2 < l1;
            warning('f_tickFormat:bad_input','Reducing Length of YTickLabel!');
        else
            warning('f_tickFormat:bad_input','Reducing Length of YTick!');
        end;
        l3 = min([l1,l2]);
        yTickLbl = yTickLbl(1:l3);
        yTick = yTick(1:l3);
    end;
    
    %set rotation to 0 if not input
    if ~exist('roty','var');
        roty = 0;
    elseif isempty(roty);
        roty = 0;
    end;
    
    %Convert the cell labels to a character string
    yTickLbl = cellstr(yTickLbl);
    
    %Make the YTICKS!
    lim = get(hAxes,'XLim');
    if min(xTick) < lim(1);
        lim(1) = min(xTick);
    end;
    if max(xTick) > lim(2);
        lim(2) = max(xTick);
    end;
    
% new    
if strcmpi(get(hAxes, 'YAxisLocation'), 'right')
    isRighthand = true;
else
    isRighthand = false;
end

    if isRighthand
        hAlign = 'left';
    else
        hAlign = 'right';
    end
   	vAlign = 'middle';

%     if roty == 0;
%         hAlign = 'right';
%         vAlign = 'middle';
%     elseif roty < 0;
%         hAlign = 'right';
%         vAlign = 'middle';
%     else
%         hAlign = 'right';
%         vAlign = 'middle';
%     end
    %
    if latex_on;
        interp = 'LaTex';
    else
        interp = 'Tex';
    end
    
    % PLOT----------------------------------
    yTickLbl = yTickLbl';
    if strcmpi(get(hAxes,'XScale'), 'log') % reintroduced to get corrmatrix working
        if isRighthand
            xposition = 10^(log10(lim(2)) + yTickLbl_offset_dat);
        else
            xposition = 10^(log10(lim(1)) - yTickLbl_offset_dat);
        end
    else
        if isRighthand
            xposition = lim(2) + yTickLbl_offset_dat; % nudge y axis ticklabels (negative => left)
        else
            xposition = lim(1) - yTickLbl_offset_dat; % nudge y axis ticklabels (negative => left)
        end
    end

    hy = text(...
        repmat(xposition,length(yTick),1),...
        yTick,...
        yTickLbl,'VerticalAlignment',vAlign,...
        'HorizontalAlignment',hAlign,'rotation',roty,'interpreter',interp,'tag','yTickLabel'); % useful when debugging: ,'BackgroundColor',[.7 .9 .7]);
    % PLOT----------------------------------

    
    %Get and set the text size and weight
    set(hy,'FontSize',get(hAxes,'FontSize'));
    set(hy,'FontWeight',get(hAxes,'FontWeight'));

    %Set the additional parameters if they were input
    if length(varargin) > 2;
        command_string = 'set(hy';
        for j=1:2:length(varargin);
            command_string = [command_string ',' ...
                '''' varargin{j} ''',varargin{' num2str(j+1) '}']; %#ok
        end;
        command_string = [command_string ');'];
        eval(command_string);
    end;
end;