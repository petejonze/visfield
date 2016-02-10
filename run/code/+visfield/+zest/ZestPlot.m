classdef ZestPlot < handle
	% Graphical output for Zest algorithm, called via Zest.update()
    %
    % Public Zest Methods:
    %   none
    %
    % Public Static Methods:
    %   * runTests  	- Run basic test-suite to ensure functionality.
    %
    % See Also:
    %   Zest.m
    %
    % Example:
    %   Zest.runTests();
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 04/2015 : first_build\n
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================      

    properties (GetAccess = public, SetAccess = protected)
        hFig % figure handle
        
        nLocs
        hText
        
        currThreshs
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
  
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = ZestPlot(locations_deg, validPoints)
            
            % create plot
            obj.hFig = figure('Position',[200 200 1000 800]);
            
            % store N values 
            obj.nLocs = numel(locations_deg(:,:,1));
            
            % plot initial thresholds
            obj.hText = nan(size(obj.currThreshs));
            hold on
            for i = 1:size(locations_deg,1)
                for j = 1:size(locations_deg,2)
                    x = locations_deg(i,j,1);
                    y = locations_deg(i,j,2);
                    if ~validPoints(i,j)
                        T = '';
                    else
                        T = 'x';
                    end
                    obj.hText(i,j) = text(x,y,T, 'HorizontalAlignment','center', 'FontSize',24);
                end
            end
            figure(obj.hFig);
            drawnow();
            
            % format
            xmin = min(min(locations_deg(:,:,1)));
            xmax = max(max(locations_deg(:,:,1)));
            ymin = min(min(locations_deg(:,:,2)));
            ymax = max(max(locations_deg(:,:,2)));
            
            set(gca, 'XLim',[xmin xmax]+[-(xmax-xmin)/10 (xmax-xmin)/10], 'YLim',[ymin ymax]+[-(ymax-ymin)/10 (ymax-ymin)/10]);

            set(gca, 'XTick',locations_deg(1,:,1), 'YTick',flipud(locations_deg(:,1,2)));
            
            plot([0 0], ylim(), 'k-');
            plot(xlim(), [0 0], 'k-');
            
        end
        
        %% == METHODS =================================================

        function [] = update(obj, thresholds)
            for i = 1:obj.nLocs
                if ~isnan(thresholds(i))
                    if thresholds(i) >= 0
                        Tstr = sprintf('%i', thresholds(i));
                    else
                        Tstr = '<0';
                    end
                    set(obj.hText(i), 'String',Tstr, 'FontSize',12)     
                end
            end

            figure(obj.hFig);
            drawnow();
        end
    end
        

    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
  
    methods (Access = private)
        
    end
    
    
   	%% ====================================================================
    %  -----STATIC METHODS-----
    %$ ====================================================================
  
    methods (Static, Access = public)

        function [] = runTests()
            import visfield.zest.*
            close all;
            
            % Test 1 ------------------------------------------------------
            % initialise observer (right eye thresholds)
            trueThresh = [
                NaN, NaN, NaN,  7,   6,   12,  9,  NaN,  NaN,  NaN
                NaN, NaN,  15,  14,  15,  15,  14,  13,  NaN,  NaN
                NaN,  14,  17,  20,  18,  20,  20,  17,   12,  NaN
                10,   12,  18,  20,  19,  20,  19, NaN,   12,  NaN
                11,   16,  18,  18,  17,  20,  17, NaN,   11,  NaN
                NaN,  14,  17,  20,  18,  20,  20,  15,   12,  NaN
                NaN, NaN,  15,  16,  14,  15,  17,  13,  NaN,  NaN
                NaN, NaN, NaN,  9,   11,  9,   7,  NaN,  NaN,  NaN
                ];
            
            % initialise grid
            prior = ThresholdPriors(1, 10000/pi, false);
            Z = Zest(1, prior, 0:30, [], [], true);
            
            % run loop
            while ~Z.isFinished()
                % pick a state
                [x_deg, y_deg, targLum_dB, i, j] = Z.getTarget();
                % test the point
                anscorrect = targLum_dB < trueThresh(i,j); % based on a uniform threshold
                % update the state, given observer's response
                Z.update(x_deg, y_deg, targLum_dB, anscorrect, 400);
            end
            % report summary
            fprintf('\nTrue Thresholds:\n');
            disp(trueThresh)
            fprintf('Estimated Thresholds:\n');
            disp(Z.thresholds)
            fprintf('Total n stimulus presentations: %i\n', sum(Z.nPresentations(~isnan(Z.nPresentations))));

            
            % Test 2 ------------------------------------------------------
            % initialise observer (right eye thresholds)
          	trueThresh = [
                NaN, NaN,  15,  14,  15,  15,  14,  13,  NaN,  NaN
                NaN,  14,  17,  20,  18,  20,  20,  17,   12,  NaN
                10,   12,  18,  20,  19,  20,  19,  18,   12,  NaN
                11,   16,  18,  18,  17,  20,  17,   0,   11,  NaN
                NaN,  14,  17,  20,  18,  20,  20,  15,   12,  NaN
                NaN, NaN,  11,  10,  10,  10,  12,  13,  NaN,  NaN
           	];
            trueThresh = fliplr(trueThresh); % flip for left eye
        
            % initialise grid
            Z = myZestWrapper(0, 155, 0:30, true);
            
            % run loop
            while ~Z.isFinished()
                % pick a state
                [x_deg, y_deg, targLum_dB, i, j] = Z.getTarget();
                % test the point
                anscorrect = targLum_dB < trueThresh(i,j); % based on a uniform threshold
                % update the state, given observer's response
                Z.update(x_deg, y_deg, targLum_dB, anscorrect, 400);
            end
            % report summary
            
            % report summary
            fprintf('\nTrue Thresholds:\n');
            disp(trueThresh)
            fprintf('Estimated Thresholds:\n');
            disp(Z.thresholds)
            fprintf('Total n stimulus presentations: %i\n', Z.getTotalNPresentations() );

            % all done
            close all
            fprintf('\n\nAll checks ok\n');
        end
    end
  
end