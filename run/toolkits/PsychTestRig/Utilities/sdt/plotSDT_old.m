function [h] = plotSDT(d, c, centreOnZero)
%PLOTSDT shortdesc.
%
%   plot sdt params
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	06/12/11
% @Last Update:     06/12/11
%
% @Todo:            <blank>
%
% v1    :   basic

    %% params
    a_sigma = 1;
    b_sigma = 1;
    if centreOnZero
        a_mu = -d/2;
        b_mu = d/2;
        %c = c + a_mu;
    else
        a_mu = 0;
        b_mu = d;
    end
        
    %% plot data
    x = linspace(-3*d, 3*d, 1000);
    a = normpdf(x, a_mu, a_sigma);
    b = normpdf(x, b_mu, b_sigma);
    
    %% get labels
    if length(c) == 1
        c_txt = 'c';
    else
        c_txt = strread(sprintf('$c_{%i}$\n',1:length(c)),'%s')
    end
    
    %% plot
    hold on
        
        
        % lines
        plot(x,a);
        plot(x,b);
        % shading
        area(x, a,'FaceColor',[1 0.7 0.7],'LineStyle', 'none','LineWidth',0.1); % shade all of distribution A
        shadedplot(x,a,b,'w'); % recolour non-intersecting part of the left pdf in white (leaving just the overlap)
        
        
        vline_hacked(c,'r--',c_txt);
    hold off

end