function [out] = getUnits(h,in,inUnits,outUnits,dim)
%GETUNITS shortdesc.
%
%   long description.
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Creation Date:	20/02/12
% @Last Update:     20/02/12
%
% @Todo:            lots!

    if nargin < 4 || isempty(outUnits)
        outUnits = get(h,'Units');
    end
    if nargin < 5 || isempty(dim)
        dim = [];
    end
    
    % get old units to reinstate at end
    hUnits = get(h,'Units');
 
    
% h,in,inUnits,outUnits

% not sure about this
    if strcmpi(inUnits,'centimeters')
        set(h,'Units','centimeters');
        pos = get(h,'Position');
%         if isempty(dim)
            % get max axis size
            
            
            %parent_cm = max(pos([3 4]));
            parent_cm = max(pos([end-1 end])); % for 3 item text?
            
%         elseif dim == 1
%             % get height
%             parent_cm = pos(4);
%         elseif dim == 2
%             % get width
%             parent_cm = pos(3);
%         else
%             error('a:b','c');
%         end
    end

    % convert (1)
    if strcmpi(inUnits,'centimeters') && strcmpi(outUnits,'normalized')
        % find proportion of max axis size
        out = in / parent_cm; % now in normalized units
    elseif strcmpi(inUnits,'centimeters') && strcmpi(outUnits,'data')
        % get data range
        if dim == 1
            lims = get(h,'ylim'); % ylim();
            parent_scale = get(h,'YScale');
        elseif dim == 2
            lims = get(h,'xlim'); % xlim();
            parent_scale = get(h,'XScale');
        else
            error('getUnits:requiredInputMissing','Dim required when outputting data units!');
        end
        if strcmpi(parent_scale,'linear')
            parent_dat = abs(diff(lims));
            % find proportion of data
            out = parent_dat * (in/parent_cm); % now in data units
            % n.b. when using: x +/- out)
        elseif strcmpi(parent_scale,'log')
            out = (log10(lims(2)) - log10(lims(1))) / parent_cm * in; % calc the proportion of orders of magnitude we wish to shift by and multiply that by the appropriate ratio
            % n.b. when using: 10^(log10(x) +/- out)
        else
            error('a:b','Functionality not yet written');
        end
    elseif strcmpi(inUnits,outUnits)
        out = in;
    elseif strcmpi(inUnits,'pixels') && strcmpi(outUnits,'normalized')
        ss = get(0,'screensize'); wpix = ss(3); hpix = ss(4);
        out = in / max(wpix, hpix);
        %w=(pix/wpix)/posvector(3);
        %h=(pix/hpix)/posvector(4);
        warning('a:b','Functionality untested!!!');
  	elseif strcmpi(inUnits,'centimeters') && strcmpi(outUnits,'pixels')
        ss = get(0,'screensize'); wpix = ss(3); hpix = ss(4);
        out = (in/parent_cm) * max(wpix,hpix);
        warning('a:b','Functionality untested!!!');
        
    elseif strcmpi(inUnits,'data') && strcmpi(outUnits,'pixels')
        warning('a:b','Functionality untested!!!');
        ss= get(0,'screensize'); wpix = ss(3); hpix = ss(4);
        if dim == 1
            lims = get(h,'ylim');
            parent_scale = get(h,'YScale');
%             pos = get(h,'Position')
% set(gcf,'Units','normalized');            
%             pos = get(gcf,'Position')
%             dfdfdf
%             hpix
%             parent_propHeight = pos(4)
%             parent_px = hpix * parent_propHeight % find number of pixels in axes
            
                % no alt, unless recursively go up the hierarchy?
                oldU = get(h,'Units');
                set(h,'Units','pixels');
                pos = get(h,'Position');
                parent_px = pos(4);
                set(h,'Units', oldU);
                
        elseif dim == 2
            lims = get(h,'xlim'); %xlim(); % no, want the parents lims, not necessarily the current axes
            parent_scale = get(h,'XScale');
%             pos = get(h,'Position');
%             parent_propWidth = pos(3)
%             parent_px = wpix * parent_propWidth;
            
                oldU = get(h,'Units');
                set(h,'Units','pixels');
                pos = get(h,'Position');
                parent_px = pos(4);
                set(h,'Units', oldU);
        else
            error('getUnits:requiredInputMissing','Dim required when outputting data units!');
        end
        parent_dat = abs(diff(lims))
        parent_px
        
        d = in - lims(1) % distance from axis in Data units
        PpD = parent_px / parent_dat % Pixels unit per Datum unit
        out = d * PpD
        
        if strcmpi(parent_scale,'log')
            %parent_dat = (log10(lims(2)) - log10(lims(1)))
            %PpD = parent_px / parent_dat % Pixels unit per Datum unit
            %out = d * PpD
            error('a:b','Functionality not yet written');
        end

    elseif strcmpi(inUnits,'data') && any(strcmpi(outUnits,{'normalised','normalized'}))
        warning('a:b','Functionality untested!!!\n Now need to scale by get(gca,''Position'')');
        pos = get(gca,'Position');
        if dim == 1
            ylims = ylim();
            in_ax = (in-ylims(1))/diff(ylims);  % normalize to axis lims
            in_ax = max(min(in_ax,1),0);        % ensure between 0 and 1
            in_fig = pos(2) + pos(4)*in_ax;     % normalize to figure lims
            out = in_fig;
        else
            xlims = xlim();
            in_ax = (in-xlims(1))/diff(xlims);  % normalize to axis lims
            in_ax = max(min(in_ax,1),0);        % ensure between 0 and 1
            in_fig = pos(1) + pos(3)*in_ax;     % normalize to figure lims
            out = in_fig;
        end
    else
        error('a:b','Functionality not yet written');
        % for pixels to cm see fig_make
    end
    
    % reinstate old units
    set(h,'Units',hUnits);
end