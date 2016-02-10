function [x,idx] = getLeftOfStringObjects(h)
%GETLEFTOFSTRINGOBJECTS find leftmost edge of 1 or more graphic objects.
%
%   Convenience function for finding the left edge of 1 or more graphic
%   objects containing text. Returns the result in CENTIMETERS. getUnits.m
%   can be used to convert the result to other units.
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	h           Numeric[n]      Handle(s) to graphic objects     
%                                   @required
%
% @Returns:  
%
%       x           Numeric         Leftmost position (cm)
%
%       idx        	Numeric         Index of leftmost graphic object
%
%
% @Syntax:
%
%       [x,idx] = getLeftOfStringObjects(h)
%
% @Example:    
%
%       figure(); plot(randn(10));
%       h(1) = xlabel('x');
%       h(2) = ylabel('y');
%       hTxt = text(5,0,'dfdfdf');
%       set(hTxt,'units','centimeters','Rotation',90,'HorizontalAlignment','center');
%       pos = get(hTxt,'Position');
%       pos(1) = getLeftOfStringObjects(h);
%       set(hTxt,'Position',pos);
%
% @See also:        getBottomOfStringObjects.m, fig_axesFormat.m,
%                   fig_figFormat.m, getUnits.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	08/11/12	First Build            	[PJ]
%
% @Todo:            <none>

    pos = nan(length(h),1);
    for i = 1:length(h)

        z = copyobj(h(i),get(h(i),'parent'));
        set(z,'Units','centimeters');
        obj = get(z);
        x0 = obj.Position(1);
        y0 = obj.Position(2);
        width = obj.Extent(3);
        height = obj.Extent(4);
        delete(z);
            
        r = round(rem(obj.Rotation,90.0000001));
    	xpos = x0 + (width*(1 - r/90) + height*(r/90));
       	if ~isnan(y0)
            pos(i) = xpos;
        end
    end

    [maxPos,idx] = max(pos); % find rightmost value
    x = maxPos;
end