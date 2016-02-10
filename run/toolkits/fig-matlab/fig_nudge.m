function [] = fig_nudge(handles, horz, vert, units)
%FIG_NUDGE additively transpose graphic objects.
%
%   Useful for nudging axis labels, legends, etc
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	handles     Numeric[n]      Handle(s) of graphic objects
%                                   @required
%
%    	horz        Numeric         Units of horizontal movement (negative
%                                   = left, positive = right)
%                                   @default: 0
%
%    	vert        Numeric         Units of vertical movement (negative
%                                   = down, positive = up)
%                                   @default: 0
%
%    	units       Char            Type of units to use. By default the
%                                   current unit of the object will be used
%                                   @default: []
%
% @Returns:  
%
%       <none>
%
%
% @Syntax:
%
%       fig_nudge(handles, [horz], [vert], [units])
%
% @Example:    
%
%       figure(); plot(randn(20));
%       hTxt = text(0,0,'hello world');
%       fig_nudge(hTxt, 5, -3);
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            <none>


    %% init
    if nargin < 2 || isempty(horz)
        horz = 0;
    end
    if nargin < 3 || isempty(vert)
        vert = 0;
    end
    if nargin < 4 || isempty(units)
        units = []; % e.g. 'pixels'
    end
    
    %% nudge
    for i = 1:length(handles)
        h = handles(i);
        oldUnits = get(h, 'Units');
        try
            if ~isempty(units)
                set(h,'Units', units)
            end
            pos = get(h,'Position');
            set(h,'Position',[pos(1)+horz,pos(2)+vert,pos(3:end)]);
            sub_finishUp();
        catch ME
            try
            sub_finishUp();
            catch
            end
            rethrow(ME);
        end
    end
    
    function sub_finishUp()
         set(h, 'Units', oldUnits); % restore old units
    end

end