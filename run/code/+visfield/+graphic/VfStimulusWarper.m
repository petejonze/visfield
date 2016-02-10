classdef VfStimulusWarper < handle
    % Spherical Stimulus Correction
    % Retinotopic coordinates are often defined in units of degrees of visual
    % field, a spherical parameter.  However, monitors are flat, which means
    % that spatial frequency (cyc/deg) and speed (cyc/sec) become gradually
    % reduced for larger eccentricities when they are kept constant in
    % cycles/centimeter.  When the eccentricities are kept to reasonably low
    % values (e.g. <30o), this distortion is small.  However, our experiments
    % call for stimulation over a large enough region of visual space that this
    % distortion becomes quite substantial.   For example, a drifting bar that
    % is kept constant in its width (cm) and speed (cm/sec) will become
    % dramatically smaller (degrees) and slower (deg/sec) at the largest
    % eccentricities of our stimulus.  We thus defined our stimuli such that
    % the angular variables in spherical coordinates (altitude or azimuth) are
    % the independent variables.  For example, our sine wave gratings were
    % defined as a function of spherical variables, and these values were then
    % projected onto a flat surface.
    %
    % The code used here is modified from:
    % http://labrigger.com/blog/2012/03/06/mouse-visual-stim/
    %
    % This uses linear interpolation to 'unwarp' the 2D monitor image into
    % circular values (e.g., ensuring that the test cicle should always
    % appear round, even in the periphery).
    %
    % Note that viewing distance (zdistBottom_cm_cm, zdistTop_cm_cm) is fixed.
    % Although it would ideally be nice to recompute this on a
    % trial-by-trial basis, it is too computationally expensive to justify,
    % given the tiny difference it would make.
    %  
    %   see mess_angle_v4.m for more.
    %
    % VfStimulusWarper Methods:
    %   * VfStimulusWarper  	- Constructor.
    %
    % See Also:
    %   qinterp2.m
    %
    % Example:
    %   none
    %
    % Author:   
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 03/2015 : first_build\n
    %
    % @todo truncate
    %
    % Copyright 2015 : P R Jones
    % *********************************************************************
    % 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================      
    
    properties (Constant)
    end
    
    properties (GetAccess = public, SetAccess = private)
        % cartesian screen coordinates (prior to converting to spherical coordinates)
        cart_pointsX
        cart_pointsY
        cart_pointsZ
        % spherical screen coordiantes
        sphr_pointsPh
        sphr_pointsTh
        sphr_pointsR
    end

        
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = VfStimulusWarper(w_cm, h_cm, w_px, h_px, zdistBottom_cm, zdistTop_cm)
            % VfStimulusWarper Constructor.
            %
            % Distance to bottom of screen, along the horizontal eye line
            % zdistBottom_cm = 80;
            % zdistTop_cm    = 76;
            %
            % @date     12/03/15
            % @author   PRJ
            %

            % init
            cx_cm = w_cm/2;   % eyeball x location, in cm
            cy_cm = h_cm/2; % 11.42; % eyeball y location, in cm

            % internal conversions
            top_cm = h_cm -cy_cm;
            left_cm = cx_cm - w_cm;
            
            % define Cartesian coordinates
            [xi,yi] = meshgrid(1:w_px,1:h_px);
            obj.cart_pointsX = single(left_cm + (w_cm/w_px).*xi);
            obj.cart_pointsY = single(top_cm - (h_cm/h_px).*yi);
            obj.cart_pointsZ = single(zdistTop_cm + ((zdistBottom_cm-zdistTop_cm)/h_px).*yi);

            % convert Cartesian to spherical coord
            % In image space, x and y are width and height of monitor and z is the
            % distance from the eye. I want Theta to correspond to azimuth and Phi to
            % correspond to elevation, but these are measured from the x-axis and x-y
            % plane, respectively. So I need to exchange the axes this way, prior to
            % converting to spherical coordinates:
            % orig (image) -> for conversion to spherical coords
            % Z -> X
            % X -> Y
            % Y -> Z
            %obj.sphr_pointsPh = atan2(obj.cart_pointsY, hypot(cart_pointsZ, obj.cart_pointsX));
            %obj.sphr_pointsTh = atan2(obj.cart_pointsX, cart_pointsZ);
            % ALT:
            [obj.sphr_pointsTh, obj.sphr_pointsPh, obj.sphr_pointsR] = cart2sph(obj.cart_pointsZ, obj.cart_pointsX, obj.cart_pointsY);
            
            % prepare scaling parameters
           	xmaxRad = max(obj.sphr_pointsTh(:));
            ymaxRad = max(obj.sphr_pointsPh(:));
            fx = xmaxRad/max(obj.cart_pointsX(:));
            fy = ymaxRad/max(obj.cart_pointsY(:));
            
            % scale cartesian coordinates
            obj.cart_pointsX = obj.cart_pointsX.*fx;
            obj.cart_pointsY = obj.cart_pointsY.*fy;  
        end
        
        %% == METHODS =====================================================
        
        function [imgMatrix, xidx, yidx] = warp(obj, imgMatrix, stimMx_px, stimMy_px, padding_px)
            
            if nargin < 5 || isempty(padding_px)
                padding_px = 30;
            end
            
            % get indices for the part of the monitor containing
            diam_px = size(imgMatrix,1);
            idx = 1:(diam_px+padding_px*2);
            xidx = stimMx_px + idx - idx(end)/2;
            yidx = stimMy_px - (idx - idx(end)/2);
            
            % pad image with some zeros to give room to warp into
            imgMatrix = padarray(imgMatrix,[padding_px padding_px],0,'both');
            imgBase = nan(size(imgMatrix));

            % prevent any of the padded image falling off the edge of
            % screen (will later manually rencorporate those pixels as NaN
            % values)
            ix = (xidx < 1) | (xidx > size(obj.cart_pointsX,2));
            xidx(ix) = [];
            imgMatrix(:,ix) = [];
            iy = (yidx < 1) | (yidx > size(obj.cart_pointsX,1));
            yidx(iy) = [];
            imgMatrix(iy,:) = [];

            % interpolate
            imgMatrix = interp2(obj.cart_pointsX(yidx,xidx),obj.cart_pointsY(yidx,xidx), imgMatrix, obj.sphr_pointsTh(yidx,xidx),obj.sphr_pointsPh(yidx,xidx)); % /private/qinterp2.m quicker than interp2 for small matrices
            imgMatrix(isnan(imgMatrix)) = 0;
            
            % check
            if any(imgMatrix(:,1)>0.01) || any(imgMatrix(:,end)>0.01) || any(imgMatrix(1,:)>0.01) || any(imgMatrix(end,:)>0.01)
                warning('Insufficient zero-padding for warped image. Some clipping will occur');
            end
 
            % re-add any pixels that fell outside of the screen region (as
            % NaN values)
            imgBase(~iy,~ix) = imgMatrix;
            imgMatrix = imgBase;
            
%         	% plot generic warping templates
%             figure
%             subplot(3,2,1)
%             imagesc(obj.cart_pointsX)
%             colorbar
%             title('image/cart coords, x')
%             subplot(3,2,3)
%             imagesc(obj.cart_pointsY)
%             colorbar
%             title('image/cart coords, y')
%             subplot(3,2,5)
%             imagesc(obj.cart_pointsZ)
%             colorbar
%             title('image/cart coords, z')
%             %
%             subplot(3,2,2)
%             imagesc(rad2deg(obj.sphr_pointsTh))
%             colorbar
%             title('mouse/sph coords, theta')
%             subplot(3,2,4)
%             imagesc(rad2deg(obj.sphr_pointsPh))
%             colorbar
%             title('mouse/sph coords, phi')
%             subplot(3,2,6)
%             imagesc(obj.sphr_pointsR)
%             colorbar
%             title('mouse/sph coords, radius')
        end
    end
    
    
        
    %% ====================================================================
    %  -----STATIC METHODS-----
    %$ ====================================================================
          
    methods (Static, Access = public)    
    
        function [] = exampleOfUse(X_px, Y_px)
            % run using: visfield.graphic.VfStimulusWarper.exampleOfUse
            % (from within the directory containing ./+visfield/)
            %
            % may be instructive to compare with mess_angle.vOriginal.m
            
            if nargin < 1
                X_px = 300; % dot x-position (centre)
                Y_px = 500; % dot y-position (centre)
            end
            
            % Monitor size and position variables
            screenwidth_cm = 64;  % width of screen, in cm
            screenheight_cm = 40; % 34.29;  % height of screen, in cm
            zdistBottom_cm = 60;     % in cm
            zdistTop_cm    = 60;     % in cm
            w_px = 2560; % number of pixels in an image that fills the whole screen, x
            h_px = 1600; % number of pixels in an image that fills the whole screen, y
            
            % create warper object
            warper = visfield.graphic.VfStimulusWarper(screenwidth_cm, screenheight_cm, w_px, h_px, zdistBottom_cm, zdistTop_cm);
            
            % make source image
            radius_px = 60; % radius, in pixels
            I_original = single(Ellipse(radius_px,radius_px));
        
            % try a distortion
            tic()
            padding_px = 150;  % n.b., increase this number if a large amount of warping is required (i.e., to prevent image being cut off at the edges) 
            I_warped = warper.warp(I_original, X_px, Y_px, padding_px);
            toc()
            
            % plot results
            visfield.graphic.VfStimulusWarper.plot(I_original, I_warped, X_px, Y_px, w_px, h_px);
            
            % compute shift
            s = regionprops(I_warped>0.5, 'centroid');
            xy_shift = floor(s.Centroid-size(I_warped)/2);
            subplot(2,2,2), vline(X_px+xy_shift(1),'g');
            subplot(2,2,4), vline(length(I_warped)/2+xy_shift(1),'g');

%             tic();
%             x = zeros(size(imgMatrix));
%             size(x)
%             x(size(x,1)/2, size(x,2)/2) = 1; 
%             size(x)
%             x = interp2(obj.cart_pointsX(yidx,xidx),obj.cart_pointsY(yidx,xidx), x, obj.sphr_pointsTh(yidx,xidx),obj.sphr_pointsPh(yidx,xidx)); % /private/qinterp2.m quicker than interp2 for small matrices
%             [maxval maxloc] = max(x(:));
%             [maxloc_row maxloc_col] = ind2sub(size(x), maxloc)
%             toc()
            
        end
        
        function [] = plot(I_original, I_warped, X_px, Y_px, w_px, h_px)

            % plot results of warping
            % insert into full scene for visualising
            brgd = zeros(h_px, w_px);
            %
            all_original = brgd;
            d_px = size(I_original,2);
            all_original(Y_px-d_px/2+(1:d_px), X_px-d_px/2+(1:d_px)) = I_original;
            %
            all_warped = brgd;
            d_px = size(I_warped,2);
            all_warped(Y_px-d_px/2+(1:d_px), X_px-d_px/2+(1:d_px)) = I_warped;
            
            % plot
            figure();
            subplot(2,2,1)
            imshow(all_original)
            hline(Y_px), vline(X_px);
            subplot(2,2,2)
            imshow(all_warped)
            hline(Y_px), vline(X_px);
            subplot(2,2,3)
            imshow(I_original)
            subplot(2,2,4)
            imshow(I_warped)
        end
    end

end