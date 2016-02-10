classdef Zest < handle
	% 24-2 Zest.
    %
    % # Perform a ZEST procedure at each location in a 24-2 pattern, using
    % # the HFA growth pattern to set the priors at each location. 
    % #
    % # The prior pdf at each location is bimodal, with the guess from the
    % # HFA growth pattern as the mode of the normal part of the pdf, and
    % # the damaged part is fixed. The guess for the primary points is
    % # taken from previous normative data, as detailed in the code.
    %
    % This code is based on the OPI R functions, written by Andrew Turpin &
    % Luke Chong (on 12 Jun 2013).
    %
    % To cite the ZEST method:
    %     Turpin A., McKendrick A.M., Johnson C.A., & Vingrys A.J. (2003) Properties of perimetric threshold estimates from full threshold, ZEST, and SITA-like strategies, as determined by computer simulation. IOVS, 44(11), 4787-4795.
    %     Turpin A., McKendrick A.M., Johnson C.A., & Vingrys A.J. (2002) Development of Efficient Threshold Strategies for Frequency Doubling Technology Perimetry Using Computer Simulation. IOVS, 43(2), 322-331.
    %
    % Further reading:
    %     Anderson A.J. (2003) Utility of a dynamic termination criterion in the ZEST adaptive threshold method. Vis. Res., 43, 165-170.
    %     McKendrick A.M. & Turpin A. (2005) Advantages of Terminating Zippy Estimation by Sequential Testing (ZEST) With Dynamic Criteria for White-on-White Perimetry. Optometry and Vis. Sci., 82(11), 981-987.
    %
    % For simplicity the stimulus location grid is built-in, however it
    % would be simple to modify the code to allow the user to pass custom
    % grid parameters into the constructor.
    %
    % Note that in the original, OPI version, the state object itself was
    % passed back to the user. In this version, for simplicity, the state
    % object is kept internal, and the user is just simply queries the Zest
    % master object for the next <x, y, luminance level>. To update, the
    % user then feeds these values back to Zest, along with the user's
    % response.
    %
    % Public Zest Methods:
    %   * Zest          - Constructor.
    %   * getTarget  	- Get x, y, luminance values for next presentation.
    %   * update        - Update a given state, specifying what the user's response was.
    %   * isFinished	- Returns True if Zest algorithm complete.
    %
    % Public Static Methods:
    %   * runTests  	- Run basic test-suite to ensure functionality.
    %
    % See Also:
    %   ZestState.m
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

    properties (GetAccess = public, SetAccess = ?visfield.zest.myZestWrapper) % SetAccess = protected)
        growthPattern
        locations_deg
        
        nPresentations
        thresholds % final thresholds
        
      	currentWave
        
        states
        currentStates
        
        plotObj
        
        priorThresholds
    end
    properties (GetAccess = private, SetAccess = protected)
        currentThresholds
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
  
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = Zest(eye, prior, domain, locations_deg, growthPattern, doPlot)
            import visfield.zest.*;
            
            % N.B. if growth-pattern is specified then it must be
            % passed in for the RIGHT eye (will be automatically flipped if
            % a left eye requested)
            
            if nargin < 1 || isempty(eye)
                error('Eye must be specified (0==left, 1===right, 2==both)');
            end
            if nargin < 2 || isempty(prior) || isempty(regexp(class(prior), 'ThresholdPriors$','once')) % ~isa(prior, 'ThresholdPriors') % isa cannot handle package prefixes, e.g., visfield.zest.ThresholdPriors
                error('a ThresholdPriors object is required.\n  %s detected', class(prior));
            end
            if nargin < 3 || isempty(domain) || ~all(isnumeric(domain))
                error('a domain row vector is required');
            end
            if nargin < 4
                obj.locations_deg = [];
            else
                obj.locations_deg = locations_deg;
            end
            if nargin < 5
                obj.growthPattern = [];
                if ~isempty(obj.locations_deg)
                    error('If a custom locations_deg grid has been specified, then a growth pattern must also be specified');
                end
            else
                obj.growthPattern = growthPattern;
            end
            if nargin < 6 || isempty(doPlot)
                doPlot = false;
            end
            
            % check domain is valid
            if (any(domain>54)) || (~all(round(domain)==domain))
                error('domain must be a vector of integers, 0:N, where N < 55');
            end
            
            % defensive: check that prior comes from same eye
            if eye ~= prior.eye
                error('Mismatch between specified ZEST eye (%i) and the eye in the prior normative data (%i)', eye, prior.eye)
            end

            % #####################################################################
            % # 'wave' patterns
            % # Each location derives its start value from the average of all of the
            % # immediate 9 neighbours that are lower than it.
            % # Numbers should start at 1 and increase, not skipping any.
            % ####################################################################
            
            if isempty(obj.growthPattern)
                % default right eye growth pattern
                obj.growthPattern = [
                    NaN, NaN, NaN,  3,  3,  3,  3, NaN, NaN, NaN
                    NaN, NaN,  2,   2,  2,  2,  2,  2,  NaN, NaN
                    NaN,  3,   2,   1,  2,  2,  1,  2,   3,  NaN
                    4,    3,   2,   2,  2,  2,  2, NaN,  3,  NaN
                    4,    3,   2,   2,  2,  2,  2, NaN,  3,  NaN
                    NaN,  3,   2,   1,  2,  2,  1,  2,   3,  NaN
                    NaN, NaN,  2,   2,  2,  2,  2,  2,  NaN, NaN
                    NaN, NaN, NaN,  3,  3,  3,  3, NaN, NaN, NaN
                    ];
            end
        
            % flip growth pattern if left eye specified
            if (eye == 0) % left
                obj.growthPattern = fliplr(obj.growthPattern);
            elseif (eye == 1) % right
                % no action required
            else
                error('Eye code not recognized: %i\nSupport eye codes are 0 (left eye) and 1 (right eye)', eye);
            end

            % locations, in degrees visual angle
            if isempty(obj.locations_deg)
                % default locations pattern (eye invariant)
                obj.locations_deg  = cat(3, ones(8,1) * (-27:6:27), (21:-6:-21)' * ones(1,10));
                % obj.locations_deg(:,:,1) =
                %    -27   -21   -15    -9    -3     3     9    15    21    27
                %    -27   -21   -15    -9    -3     3     9    15    21    27
                %    -27   -21   -15    -9    -3     3     9    15    21    27
                %    -27   -21   -15    -9    -3     3     9    15    21    27
                %    -27   -21   -15    -9    -3     3     9    15    21    27
                %    -27   -21   -15    -9    -3     3     9    15    21    27
                %    -27   -21   -15    -9    -3     3     9    15    21    27
                %    -27   -21   -15    -9    -3     3     9    15    21    27
                %
                % obj.locations_deg(:,:,2) =
                %    
                %     21    21    21    21    21    21    21    21    21    21
                %     15    15    15    15    15    15    15    15    15    15
                %      9     9     9     9     9     9     9     9     9     9
                %      3     3     3     3     3     3     3     3     3     3
                %     -3    -3    -3    -3    -3    -3    -3    -3    -3    -3
                %     -9    -9    -9    -9    -9    -9    -9    -9    -9    -9
                %    -15   -15   -15   -15   -15   -15   -15   -15   -15   -15
                %    -21   -21   -21   -21   -21   -21   -21   -21   -21   -21
            end
                 
            
            
            % #####################################################################
            % # set priors for first wave
            % ####################################################################

%             % make starting guesses for the "1" locations,  based on prior
%             % normative data
%             obj.currentThresholds = nan(size(obj.growthPattern));
%             [i,j] = find(obj.growthPattern==1);
%             for ii = 1:length(i)
%                 x_deg = obj.locations_deg(i(ii), j(ii), 1);
%                 y_deg = obj.locations_deg(i(ii), j(ii), 2);
%                 DLS_dB = prior.getThreshold(x_deg, y_deg);% get Differential Light Sensitivity, in dB
%                 obj.currentThresholds(i(ii), j(ii)) = DLS_dB;
%             end

            % get priors
            obj.priorThresholds = nan(size(obj.growthPattern));
            for i = 1:size(obj.growthPattern,1)
                for j = 1:size(obj.growthPattern,2)
                    x_deg = obj.locations_deg(i, j, 1);
                    y_deg = obj.locations_deg(i, j, 2);
                    DLS_dB = prior.getThreshold(x_deg, y_deg); % get Differential Light Sensitivity, in dB
                    obj.priorThresholds(i, j) = DLS_dB;
                end
            end
            % flip priorThresholds if left eye specified
            if (eye == 0) % left
                obj.priorThresholds = fliplr(obj.priorThresholds);
            end
            obj.priorThresholds(isnan(obj.growthPattern)) = NaN; % blank out untested points
            
            obj.thresholds = nan(size(obj.growthPattern));
            obj.currentThresholds = nan(size(obj.growthPattern));
            
            % make starting guesses for the "1" locations,  based on prior
            % normative data
            idx = obj.growthPattern==1;
            obj.currentThresholds(idx) = obj.priorThresholds(idx);
            % obj.currentThresholds = [
            %     NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN
            %     NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN
            %     NaN, NaN, NaN, p11, NaN, NaN, p12, NaN, NaN, NaN
            %     NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN
            %     NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN
            %     NaN, NaN, NaN, p21, NaN, NaN, p22, NaN, NaN, NaN
            %     NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN
            %     NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN
            % ];

            % initialise answers
            obj.nPresentations 	= nan(size(obj.currentThresholds));
            obj.currentWave    	= 1;
            
            % create a 'state' object at each testable location on the
            % grid. Note that each of these will need to be explicitly
            % .initialise()'d with a starting guess before they can be used
            obj.states = cell(size(obj.currentThresholds));
            for i = 1:size(obj.growthPattern,1)
                for j = 1:size(obj.growthPattern,2)
                    if ~isnan(obj.growthPattern(i,j))
                        obj.states{i,j} = ZestState(i, j, domain, 'stdev', 1.5);
                    end
                end
            end
            
            % fill the 'currentStates' buffer with all the states
            % corresponding to wave 1
            obj.currentStates = [obj.states{obj.growthPattern==1}];
            
            % create a visual plot, if requsted by user
            if doPlot
                obj.plotObj = ZestPlot(obj.locations_deg, ~isnan(obj.growthPattern));
            end
        end
        
        %% == METHODS =================================================

        function [x_deg, y_deg, targDLum_dB, i, j] = getTarget(obj)
            % get state
            state = obj.getState();
            % derive test parameters
            i = state.rowId;
            j = state.colId;
            x_deg = obj.locations_deg(i, j, 1);
            y_deg = obj.locations_deg(i, j, 2);
            targDLum_dB = state.getCurrentStimLvl('mean');
        end
        
        function T = update(obj, x_deg, y_deg, presentedStimLvl_dB, stimWasSeen, responseTime_ms)
            % get state
            idx = obj.locations_deg(:,:,1)==x_deg & obj.locations_deg(:,:,2)==y_deg;
            state = obj.states{idx};
            
            % update this state
            T = state.update(presentedStimLvl_dB, stimWasSeen, responseTime_ms);
            
            % update states list (if this state is finished)
            if state.isFinished()
                % store threshold estimate
                obj.currentThresholds(state.rowId, state.colId) = state.getFinalThresholdEst(); % specify method?????
                obj.nPresentations(state.rowId, state.colId) = state.nPresentations;
                obj.thresholds(state.rowId, state.colId) = obj.currentThresholds(state.rowId, state.colId);
                
                % remove this state from state list
                obj.currentStates(obj.currentStates==state) = [];
            
                % if state list now depleted...
                if isempty(obj.currentStates)
                    %...increment wave counter...
                    obj.currentWave = obj.currentWave + 1;
                    
                    %...& if wave still within limits, grab some new states
                    if obj.currentWave <= max(obj.growthPattern(:))
                        obj.currentStates = [obj.states{obj.growthPattern==obj.currentWave}];
                    end
                end
            end
            
            % update any graphics
            if ~isempty(obj.plotObj)
                obj.plotObj.update(obj.thresholds);
            end
        end
        
        function isFin = isFinished(obj)
            % return true iff no more states left unfinished, and we have
            % reached the last wave
            if isempty(obj.currentStates) && (obj.currentWave >= max(obj.growthPattern(:)))
                isFin = true;
            else
                isFin = false;
            end
        end

    end
        
        
    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
  
    methods (Access = private)
        
        function dB = makeGuess(obj, rw, cl)
       	% use available info to guess the observer's threshold for a given
        % location. After the first wave, this is computed by averaging all
        % immediate 9 neighbours that have num less than "wave"
            % ####################################################################
            % # INPUTS
            % #   rw   - row of location
            % #   cl   - column of location
            % #
            % # RETURNS: start guess for location (rw, cl) which is average of
            % #          neighbours that are less than "wave" in "gp"
            % ####################################################################

            % check valid
            if obj.growthPattern(rw, cl) ~= obj.currentWave
                error('Attempting to select a state with a wave number (%i) different from the current wave number (%i)', obj.growthPattern(rw, cl), obj.currentWave); 
            end
                  
            % in wave 1, simply use the prior as the starting guess
            if (obj.currentWave == 1)
                dB = obj.currentThresholds(rw, cl);
                return;
            end
            
            % get values
            iidx = max(rw-1,1):min(rw+1,size(obj.growthPattern,1));
            jidx = max(cl-1,1):min(cl+1,size(obj.growthPattern,2));
            vals = obj.currentThresholds(iidx, jidx);

            % find values from lower wave (and check not nan - defensive
            % check, since shouldn't be possible anyway)
            idx = obj.growthPattern(iidx, jidx) < obj.currentWave ...
                & ~isnan(vals);
        
            % defensive check that at least 1 value found
            if ~any(idx)
                disp(obj.growthPattern)
                disp(obj.currentThresholds)
                obj.growthPattern(iidx, jidx)
                error('Could not find neighbour for {%i, %i}', rw, cl)
            end
            
            % compute mean of value(s)
            tmp = vals(idx);
            dB = mean(tmp(:));
            
            % PJ: NEW
            % Also, use generic prior information to further inform
            % starting guess
            wPriorGuess = 1/obj.currentWave; % amount of weight given to prior evidence (weights sum to 1. 0==total reliance on current empirical data. 1=total reliance on prior normative data)
            dB = (1-wPriorGuess)*dB + wPriorGuess*obj.priorThresholds(rw, cl);
            
fprintf('tmp: initialising at level: %1.2f\n', dB);            
        end
        
        function state = getState(obj)
            % Get a state object directly (should not be required - use
            % getTarget() instead).
            
            % defensive
            if obj.isFinished()
                error('Cannot select a state - Zest algorithm has finished');
            end
            
            % pick a random state from the list
            idx = randi(length(obj.currentStates));
            state = obj.currentStates(idx);
            
            % initialise state, if necessary (i.e., if a new state, not
            % previously tested)
            if ~state.isInitialised
                startingGuess = obj.makeGuess(state.rowId, state.colId);
                state.initialise(startingGuess)
            elseif state.isFinished() % defensive
                error('A finished state was selected??');
            end
        end
    end
    
    
   	%% ====================================================================
    %  -----STATIC METHODS-----
    %$ ====================================================================
  
    % little helper functions
    methods (Static, Access = public)
        
        % tests
        function [] = runTests()
            import visfield.zest.*
            
            % Try running a uniform grid ----------------------------------
            % initialise grid
            prior = ThresholdPriors(0, 10000/pi, false);
            Z = Zest(0, prior, 0:30);
            % run loop
            while ~Z.isFinished()
                % pick a state
                [x_deg, y_deg, targDLum_dB] = Z.getTarget();
                fprintf('wave=%i, {%i, %i}\n', Z.currentWave, x_deg, y_deg);
                % test the point
                anscorrect = targDLum_dB < 25; % based on a uniform threshold
                % update the state, given observer's response
                Z.update(x_deg, y_deg, targDLum_dB, anscorrect, 400);
            end
            % report summary
            Z.thresholds
            fprintf('Total n stimulus presentations: %i\n', sum(Z.nPresentations(~isnan(Z.nPresentations))));
            
            % Try running a non-uniform grid ------------------------------
            % initialise grid
            prior = ThresholdPriors(1, 155, false);
            Z = Zest(1, prior, 0:30);
            % initialise observer parameters
            trueThresh = [
                NaN, NaN, NaN,  15,  15,  12,  9,  NaN,  NaN,  NaN
                NaN, NaN,  15,  14,  15,  15,  14,  13,  NaN,  NaN
                NaN,  14,  17,  20,  18,  20,  20,  17,   12,  NaN
                10,   12,  18,  20,  19,  20,  19, NaN,   12,  NaN
                11,   16,  18,  18,  17,  20,  17, NaN,   11,  NaN
                NaN,  14,  17,  20,  18,  20,  20,  15,   12,  NaN
                NaN, NaN,  15,  16,  14,  15,  17,  13,  NaN,  NaN
                NaN, NaN, NaN,  9,   11,  9,   7,  NaN,  NaN,  NaN
           	];
            % run loop
            while ~Z.isFinished()
               	% pick a state
                [x_deg, y_deg, targDLum_dB,  i, j] = Z.getTarget();
                fprintf('wave=%i, {%i, %i}\n', Z.currentWave, x_deg, y_deg);
                % defensive check
                [ii,jj] = find(Z.locations_deg(:,:,1)==x_deg & Z.locations_deg(:,:,2)==y_deg);
                if (ii~=i) || (jj~=j)
                    error('row/column validation failed?? (i=%i, ii=%i;  j=%i, jj=%i)',i,ii,j,jj);
                end
                % test the point
                anscorrect = targDLum_dB < trueThresh(i, j); % based on above matrix
                % update the state, given observer's response
                Z.update(x_deg, y_deg, targDLum_dB, anscorrect, 400);
            end
            % report summary
            fprintf('\nTrue Thresholds:\n');
            disp(trueThresh)
            fprintf('Estimated Thresholds:\n');
            disp(Z.thresholds)
            fprintf('Total n stimulus presentations: %i\n', sum(Z.nPresentations(~isnan(Z.nPresentations))));
            
            % Try running a non-uniform grid with internal variability ----
            % initialise grid
            prior = ThresholdPriors(1, 155, false);
            Z = Zest(1, prior, 0:30);
            % initialise observer parameters
            trueThresh = [
                NaN, NaN, NaN,  15,  15,  12,  9,  NaN,  NaN,  NaN
                NaN, NaN,  15,  14,  15,  15,  14,  13,  NaN,  NaN
                NaN,  14,  17,  20,  18,  20,  20,  17,   12,  NaN
                10,   12,  18,  20,  19,  20,  19, NaN,   12,  NaN
                11,   16,  18,  18,  17,  20,  17, NaN,   11,  NaN
                NaN,  14,  17,  20,  18,  20,  20,  15,   12,  NaN
                NaN, NaN,  15,  16,  14,  15,  17,  13,  NaN,  NaN
                NaN, NaN, NaN,  9,   11,  9,   7,  NaN,  NaN,  NaN
           	];
            inoise = 3; % std/slope of psychometric function, in dB
            % run loop
            while ~Z.isFinished()
               	% pick a state
                [x_deg, y_deg, targDLum_dB, i, j] = Z.getTarget();
                fprintf('wave=%i, {%i, %i}\n', Z.currentWave, x_deg, y_deg);
                % test the point
                anscorrect = (targDLum_dB+randn()*inoise) < trueThresh(i, j); % based on above matrix
                % update the state, given observer's response
                Z.update(x_deg, y_deg, targDLum_dB, anscorrect, 400);
            end
            % report summary
            fprintf('\nTrue Thresholds:\n');
            disp(trueThresh)
            fprintf('Estimated Thresholds:\n');
            disp(Z.thresholds)
            fprintf('Total n stimulus presentations: %i\n', sum(Z.nPresentations(~isnan(Z.nPresentations))));
            
            % all done
            fprintf('\n\nAll checks ok\n');
        end
    end
  
end