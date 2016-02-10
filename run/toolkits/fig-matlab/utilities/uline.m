function h=uline(linetype, linewidth, lims)
% function h=uline()
%
%
% Draws a unity line, similar to hline or vline
%
% Pete Jones
% 23/10/11
% 14/02/12

    if nargin<1 || isempty(linetype)
        linetype = 'k-';
    end
    if nargin<2 || isempty(linewidth)
            linewidth = [];
    end
    if nargin<3 || isempty(lims)
        x=get(gca,'xlim');
        %y=get(gca,'ylim');
        y=x;
    else
        x = lims;
        y = lims;
    end
        
    % hold on, if not held already
    g=ishold(gca);
    hold on
    
    % plot line
    h=plot([x y],[x y],linetype);

    % return hold to original state
    if g==0
        hold off
    end

    % stop the line from appearing in legend
    set(h,'tag','hline','handlevisibility','off') % this last part is so that it doesn't show up on legends
    
    % do any user-specified formatting
    if ~isempty(linewidth)
        set(h,'linewidth',linewidth);
    end
    
end
