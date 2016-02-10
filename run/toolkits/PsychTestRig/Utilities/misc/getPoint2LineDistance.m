function d = getPoint2LineDistance(x1, y1, m, c)
% http://www.worsleyschool.net/science/files/linepoint/method1.html
%
% (x1,y1) = point
% mx + c = line
%
% e.g. getPoint2LineDistance(4,1,2,4)
    
%     % Find the equation of the line represented by distance d 
%     d_m = -1/m;% we know that the slope of a line perpendicular to this is the negative reciprocal of the original slope
%     d_c = d_m*(-x1) + y1; % The equation of a straight line with gradient m, passing through the point (x1,y1), is y?y1 =m(x?x1).
% 
%     % Find the intersection point of the two lines.
%     x = (c - d_c)/(d_m - m); % solve('d_m*x + d_c = m*x + c')
%     y = m*x + c;
% 
%     % Find the length of the line representing distance d
%     d = sqrt((x1 - x)^2 + (y1 - y)^2);
% 
% %     %
% %     figure()
% %     plot(x,z,'-',xx,yy,'x',[x1 x], [y1 x], 'r-')

% http://www.worsleyschool.net/science/files/linepoint/method5.html
a = m;
b = -1;
c = c;
m = x1;
n = y1;
d = (a.*m + b.*n + c) ./ sqrt(a.^2 + b.^2); % ALT: abs(a*m + b*n + c) / sqrt(a^2 + b^2)

end

