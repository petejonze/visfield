classdef ThresholdPriors < handle
    % Values from:
    % 	The normal visual field on the Humphrey field analyzer.
    %  	by RS Brenton
    %       - www.ncbi.nlm.nih.gov/pubmed/3822395
    %       - http://www.karger.com/Article/Pdf/309679
    %
    % ThresholdPriors Methods:
    %   * ThresholdPriors    - Constructor.
    %   * getThreshold      - Get normative threshold value for a given <x,y> coordinate.
    %
  	% Public Static Methods:
    %   * runTests          - Run basic test-suite to ensure functionality.    
    %
    % See Also:
    %   none
    %
    % Example:
    %   prior   = ThresholdPriors(1, 10000/pi, false) % for HFA scaling, right eye
    %   myPrior = ThresholdPriors(0, 155, false)      % for monitor with max 155 cdm2 scaling, left eye
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 04/2015 : first_build\n
    %
    % @todo add option to specify age range (at the moment restricted to
    %       20-30 year old, healthy adults)
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================      
    
    properties (Constant)
        X_LIMS_DEG = [-70 70];
        Y_LIMS_DEG = [-70 70];
        raw_deltaMax_asb = 10000;
     	raw_background_cdm2 = 10;
    end
    properties (GetAccess = public, SetAccess = private)
        eye
        xyl_raw
    end
    properties (GetAccess = private, SetAccess = private)
        mapFunction
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = ThresholdPriors(eye, delta_max_cdm2, doPlot)
            % ThresholdPriors Constructor.
            %
            % @return   obj         ThresholdPriors object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse inputs
            if nargin < 1 || isempty(eye)
                error('eye must be set (0==left, 1==right, 2==both)');
            end
            if nargin < 2 || isempty(delta_max_cdm2)
                error('Must specific maximum delta-output of the machine, in cd/m2 (N.B. delta is stimulus-background)')
            end
            if nargin < 3 || isempty(doPlot)
                doPlot = false;
            end
            
            % raw values (1/2) [Right eye only]
            X_0to30 = ones(10,1) * (-27:6:27);
            Y_0to30 = flipud((-27:6:27)' * ones(1,10));
            DLS_0to30 = [
                NaN  NaN  NaN  26.8 26.3 25.5 25.1 NaN  NaN  NaN    % +27
                NaN  NaN  29.0 29.2 28.3 27.6 27.8 28.0 NaN  NaN    % +21
                NaN  28.9 29.1 29.8 30.2 29.8 30.9 30.4 28.8 NaN    % +15
                28.3 29.6 31.2 32.6 32.3 31.7 31.2 30.6 30.4 30.3   % +9
                28.9 30.4 32.1 32.8 33.7 33.5 32.2 24.7 31.3 31.9   % +3
                29.4 31.0 32.6 33.3 33.8 33.8 32.7 09.2 31.5 31.3   % -3
                29.6 30.4 31.5 33.4 32.9 32.8 32.8 31.1 31.6 31.1   % -9
                NaN  30.5 30.6 31.2 32.1 31.3 30.9 32.4 31.2 NaN    % -15
                NaN  NaN  30.1 29.8 30.9 31.4 31.8 31.2 NaN  NaN    % -21
                NaN  NaN  NaN  29.0 30.1 30.8 30.7 NaN  NaN  NaN    % -27
                ];
               %-27  -21  -15   -9   -3   +3   +9  +15  +21  -27

            % raw values (2/2) [Right eye only]
            X_30to60 = ones(10,1) * (-54:12:54);
            Y_30to60 = flipud((-54:12:54)' * ones(1,10));
            DLS_30to60 = [
                NaN  NaN  NaN  01.8 03.3 02.5 03.9 NaN  NaN  NaN 
                NaN  02.8 06.8 11.4 14.4 12.6 15.4 15.3 13.8 NaN 
                02.5 13.8 22.1 25.5 25.1 22.4 23.4 24.5 22.7 21.0
                07.2 22.4 26.4 NaN  NaN  NaN  NaN  27.9 27.6 25.2 
                12.6 23.7 27.9 NaN  NaN  NaN  NaN  29.9 29.2 27.1
                15.2 24.5 27.3 NaN  NaN  NaN  NaN  31.1 30.0 27.5
                07.6 24.1 28.2 NaN  NaN  NaN  NaN  30.6 29.2 23.6
                NaN  13.6 26.4 27.7 29.7 30.5 30.4 29.2 27.5 NaN 
                NaN  01.1 15.2 23.4 24.9 27.9 27.5 26.3 25.1 NaN 
                NaN  NaN  02.9 16.7 20.1 22.8 23.8 22.8 NaN  NaN 
                ];

            % set eye
            switch eye
                case 0 % left
                    DLS_0to30 = fliplr(DLS_0to30);
                    DLS_30to60 = fliplr(DLS_30to60);
                case 1 % right
                    % do nothing (already in right-eye form by default)
                case 2
                    % A) assuming 2 eyes integrated:
                    %DLS_0to30 = sqrt(DLS_0to30.^2 + fliplr(DLS_0to30).^2);
                    %DLS_30to60 = sqrt(DLS_30to60.^2 + fliplr(DLS_30to60).^2);
                    % B) assuming use max:
                    DLS_0to30 =  max(cat(3,DLS_0to30,fliplr(DLS_0to30)),[],3);
                    DLS_30to60 =  max(cat(3,DLS_30to60,fliplr(DLS_30to60)),[],3);
                otherwise
                    error('eye must be either: 0==left, 1==right, 2==both');
            end
            
            % fit interpolation function
            % A. interp2 won't work, because of missing values in the corners
            % B. TriScatteredInterp good, but cannot extrapolate beyond the convex hull of
            % the input...
            % C. Therefore we'll fit an extrapolated/interpolated surface first, and then
            % fit to that
            X = [X_0to30(:); X_30to60(:)]; % combine and put into columnar format
            Y = [Y_0to30(:); Y_30to60(:)]; 
            DLS_dB = [DLS_0to30(:); DLS_30to60(:)];
                        
            % recode decibels in the format of the specific machine being
            % used
            delta_asb = obj.raw_deltaMax_asb./10.^(DLS_dB/10); % ALT: 1./10.^(DLS_dB./10)*obj.raw_deltaMax_asb
            delta_cdm2 = delta_asb/pi;      
            DLS_dB = 10*log10(delta_max_cdm2./delta_cdm2);
            % set lower limit to be 0
            DLS_dB(DLS_dB<0) = 0; % do it this way to preserve NaNs, otherwise: DLS_dB = max(DLS_dB, 0);

            % for debugging:
            %delta_cdm2B = delta_max_cdm2./10.^(DLS_dB/10);
            %DLS_dB_hfaRescaled = 10*log10(obj.raw_deltaMax_asb./(delta_cdm2B*pi));
            %fprintf('%10.2f   %10.2f    %10.2f   %10.2f    %10.2f\n', [[DLS_0to30(:); DLS_30to60(:)] delta_cdm2 DLS_dB delta_cdm2B DLS_dB_hfaRescaled]')

            Xi = obj.X_LIMS_DEG(1):obj.X_LIMS_DEG(2);
            Yi = obj.Y_LIMS_DEG(1):obj.Y_LIMS_DEG(2);
            % fit!
            Zi = gridfit(X,Y,DLS_dB, Xi,Yi,  'regularizer','gradient', 'overlap',0.5);

            % plot
            if doPlot
                figure()
                subplot(1,2,1);
                surf(X_0to30,Y_0to30,DLS_0to30); xlabel('x');
                subplot(1,2,2);
                surf(Xi,Yi,Zi, 'linestyle','none'); xlabel('x');
            end
            
            % fit to new surface
            [Xi,Yi] = meshgrid(Xi,Yi);
            obj.mapFunction = TriScatteredInterp(Xi(:),Yi(:),Zi(:));
            % exampleValue = obj.mapFunction(10, 16.66667) % get example value
            
            % store raw x/y coordinate
            obj.xyl_raw = [X Y DLS_dB(:)];
            obj.xyl_raw(isnan(obj.xyl_raw(:,3)),:) = []; % remove NaNs
            
            % store eye
            obj.eye = eye;
        end
        
        %% == METHODS =====================================================
        
        function [DLS_dB, delta_cdm2, targAbs_cdm2] = getThreshold(obj, x_deg, y_deg, extrapolationAllowed)
            %@todo vectorize to allow multiple values to be queried
            % delta gives differential luminance: The difference between
            % the target (stimulus) and the background (pedestal)
            %
            
            if nargin < 4 || isempty(extrapolationAllowed)
                extrapolationAllowed = true;
            end
            
            % check that requested value appeared in original data exactly

            idx = ismember(obj.xyl_raw(:,1:2),[x_deg, y_deg],'rows');
            if any(idx)
                % get value
                DLS_dB = obj.xyl_raw(idx,3);
            else
                % try to use extrapolation to find a suitable value, unless
                % user has requested otherwise
                if ~extrapolationAllowed
                    error('Coordinates [%1.2f, %1.2f] not contained in raw data. Specify different coordinates, or set the extrapolationAllowed flag to true', x_deg, y_deg);
                else
                    obj.verifyWithinRange(x_deg, y_deg);
                    DLS_dB = obj.mapFunction(x_deg, y_deg); % e.g., DLS_dB = 54
                end
            end
                
            % convert dB to cdm2
            delta_asb = obj.raw_deltaMax_asb/10.^(DLS_dB/10); % ALT: 1./10.^(DLS_dB./10)*obj.raw_deltaMax_asb
            delta_cdm2 = delta_asb/pi;
            targAbs_cdm2 = delta_cdm2 + obj.raw_background_cdm2;
        end
    end
    
            
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
  
    methods (Access = private)

        function [] = verifyWithinRange(obj, x_deg,y_deg)
            if x_deg < obj.X_LIMS_DEG(1) || x_deg > obj.X_LIMS_DEG(2) || y_deg < obj.Y_LIMS_DEG(1) || y_deg > obj.Y_LIMS_DEG(2)
                error('Specified coordinates {%1.2f, %1.2f} lie outside the permissible range {%1.2f:%1.2f, %1.2f:%1.2f}', x_deg, y_deg, obj.X_LIMS_DEG, obj.Y_LIMS_DEG);
            end
        end
    end
        
            
   	%% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
  
    % test functions
    methods (Static, Access = public)

        function [] = runTests()
            import visfield.zest.*
            
            % right eye
            prior = ThresholdPriors(1, 155, false);
            
            DLS_dB = prior.getThreshold(3.001,27);
            raw_dB = prior.getThreshold(3,27,false);
            if abs(DLS_dB-raw_dB) > 0.1
                error('Detected fitted-prior (%1.2f) differs by more than 0.1 from raw prior (%1.2f)', DLS_dB, raw_dB);
            end
            DLS_dB = prior.getThreshold(3.001,-27);
            raw_dB = prior.getThreshold(3,-27,false);
            if abs(DLS_dB-raw_dB) > 0.1
                error('Detected fitted-prior (%1.2f) differs by more than 0.1 from raw prior (%1.2f)', DLS_dB, raw_dB);
            end
            DLS_dB = prior.getThreshold(27.001,3);
            raw_dB = prior.getThreshold(27,3,false);
            if abs(DLS_dB-raw_dB) > 0.1
                error('Detected fitted-prior (%1.2f) differs by more than 0.1 from raw prior (%1.2f)', DLS_dB, raw_dB);
            end
            DLS_dB = prior.getThreshold(15.001,-3);
            raw_dB = prior.getThreshold(15,-3,false);
            if abs(DLS_dB-raw_dB) > 0.3 % bit more lenient for the blind spot
                error('Detected fitted-prior (%1.2f) differs by more than 0.1 from raw prior (%1.2f)', DLS_dB, raw_dB);
            end
            
            % left eye
            prior = ThresholdPriors(0, 155, false);
            
            DLS_dB = prior.getThreshold(-3.001,27);
            raw_dB = prior.getThreshold(-3,27,false);
            if abs(DLS_dB-raw_dB) > 0.1
                error('Detected fitted-prior (%1.2f) differs by more than 0.1 from raw prior (%1.2f)', DLS_dB, raw_dB);
            end
            
            % all done
            fprintf('All checks ok\n');
        end
    end
    
end