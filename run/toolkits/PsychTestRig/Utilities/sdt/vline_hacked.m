function [hhh,hT]=vline_hacked(x,in1,in2,yInit,yMod,txtBakCol)
% function h=vline(x, linetype, label)
% 
% Draws a vertical line on the current axes at the location specified by 'x'.  Optional arguments are
% 'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
% label appears in the same color as the line.
%
% The line is held on the current axes, and after plotting the line, the function returns the axes to
% its prior hold state.
%
% The HandleVisibility property of the line object is set to "off", so not only does it not appear on
% legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
% return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
% overridden by setting the root's ShowHiddenHandles property to on.
%
% h = vline(42,'g','The Answer')
%
% returns a handle to a green vertical line on the current axes at x=42, and creates a text object on
% the current axes, close to the line, which reads "The Answer".
%
% vline also supports vector inputs to draw multiple lines at once.  For example,
%
% vline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% By Brandon Kuczenski for Kensington Labs.
% brandon_kuczenski@kensingtonlabs.com
% 8 November 2001

labelAtTop = false; % pj: hack

labelAtTop = true;

    

if nargin < 5 || isempty(yMod)
    yMod = 1;
end
if nargin < 4 || isempty(yInit)
    yInit = 1-yMod;
end
if nargin < 6 || isempty(txtBakCol)
    txtBakCol = 'w';
end

if length(x)>1  % vector input
    % init
    h = nan(1,length(x));
    hTxt = nan(1,length(x));
    % do each
    for I=1:length(x)
        switch nargin
        case 1
            linetype='r:';
            label='';
        case 2
            if ~iscell(in1)
                in1={in1};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            label='';
    	otherwise % 3+
            if ~iscell(in1)
                in1={in1};
            end
            if ~iscell(in2)
                in2={in2};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            if I>length(in2)
                label=in2{end};
            else
                label=in2{I};
            end
        end
        %h(I)=vline_hacked(x(I),linetype,label);
        [h(I),hTxt(I)]=vline_hacked(x(I),linetype,label,yInit+I,yMod,txtBakCol);
    end
else
    switch nargin
    case 1
        linetype='r:';
        label='';
    case 2
        linetype=in1;
        label='';
	otherwise % 3+
        linetype=in1;
        label=in2;
    end

    g=ishold(gca);
    hold on

    y=get(gca,'ylim');
    h=plot([x x],y,linetype);
    
    hTxt = nan;
    if ~isempty(label)
        xx=get(gca,'xlim');
        xrange=xx(2)-xx(1);
%         xunit=(x-xx(1))/xrange;
%         if xunit<0.8
% y
% yMod
% y(1)
% y(2)
% (0.1*yMod*(y(2)-y(1)))
% y(2)-(0.1*yMod*(y(2)-y(1)))

            if labelAtTop
                hTxt = text(x+0.015*xrange,y(2)-(0.1*yMod*(yInit)*(y(2)-y(1))),label,'color',get(h,'color'),'backgroundcolor',txtBakCol);
            else
                hTxt = text(x+0.015*xrange,y(1)+0.1*yMod*(yInit)*(y(2)-y(1)),label,'color',get(h,'color'),'backgroundcolor',txtBakCol); %#ok
            end
            
            
%         else
%             if labelAtTop
%                 text(x+.05*xrange,y(2)-0.1*(y(2)-y(1)),label,'color',get(h,'color'))
%             else
%                 text(x+.05*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'))
%             end
%         end
    end     

    if g==0
    hold off
    end
    set(h,'tag','vline','handlevisibility','off');
end % else

if nargout
    hhh=h;
    hT=hTxt;
end
