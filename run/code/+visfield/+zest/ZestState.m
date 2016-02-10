classdef ZestState < handle
	% ########.
    %
    % Public ZestState Methods:
    %   none (all access via Zest.m)
    %
  	% Public Static Methods:
    %   * runTests  	- Run basic test-suite to ensure functionality.
    %
    % See Also:
    %   Zest.m
    %
    % Example:
    %   none
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

    properties (GetAccess = public, SetAccess = private)
        isInitialised = false;

        % mandatory user-specified parameters
        domain	% List of dB values over which pdf is kept.Note min(domain) should be <= 0 for bimodal pdf
        rowId  	% i index, in testing grid
        colId  	% j index, in testing grid
        
        % optional user-specifiable parameters
        stopType            = 'stdev'   % 'npoints' | 'stdev' | 'entropy'
        stopValue           = 1.5       % Value for num prs (N), stdev (S) of Entropy (H)
       	minStimulus         = []        % Lowest value to present (defaults to minimum)
      	maxStimulus         = []        % Highest value to present (defaults to maximum)
       	minNotSeenLimit     = 2         % Will terminate if minLimit value not seen this many times
       	maxSeenLimit        = 2         % Will terminate if maxLimit value seen this many times
       	maxPresentations    = 100       % Maximum number of presentations
     	stimChoice          = 'mean'    % 'mean', 'median', 'mode'
        
        % computed variables
        likelihood          % matrix where likelihood[s,t] is likelihood of seeing s given t is true thresh (Pr(s|t), where s and t are indexs into domain - N.B. in columns
        pdf                 % prior probability distribution over domain.
        
        % measured variables
        currSeenLimit       = 0  	% number of times maxStimulus seen
        currNotSeenLimit    = 0     % number of times minStimulus not seen
        nPresentations      = 0     % number of presentations so far
        stimLvls_dB         = []  	% vector of stims shown
        responses_wasSeen 	= []	% vector of responses (1 seen, 0 not)
        responseTimes_ms    = []    % vector of response times
    end

    
 	%% ====================================================================
    %  -----PUBLIC METHODS (but only generally be accessed from Zest.m)----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = ZestState(rowId, colId, domain, stopType, stopValue, minStimulus, maxStimulus, minNotSeenLimit, maxSeenLimit, maxPresentations, stimChoice)
            
            % parse inputs
            obj.rowId  = rowId;
            obj.colId  = colId;
            obj.domain = domain;
            if nargin >= 4 && ~isempty(stopType),           obj.stopType = lower(stopType);           	end
            if nargin >= 5 && ~isempty(stopValue),          obj.stopValue = stopValue;                  end
            if nargin >= 6 && ~isempty(minStimulus),    	obj.minStimulus = minStimulus;              end
            if nargin >= 7 && ~isempty(maxStimulus),       	obj.maxStimulus = maxStimulus;              end
            if nargin >= 8 && ~isempty(minNotSeenLimit),    obj.minNotSeenLimit = minNotSeenLimit;      end
            if nargin >= 9 && ~isempty(maxSeenLimit),       obj.maxSeenLimit = maxSeenLimit;            end
            if nargin >= 10&& ~isempty(maxPresentations),   obj.maxPresentations = maxPresentations;    end
            if nargin >= 11&& ~isempty(stimChoice),         obj.stimChoice = stimChoice;                end
            
            % ensure that domain and prior are column vectors
            if isrow(obj.domain)
                obj.domain = obj.domain';
            end
            
            % insert defaults where required
            if isempty(obj.minStimulus)
                obj.minStimulus = obj.domain(1);
            end
            if isempty(obj.maxStimulus)
                obj.maxStimulus = obj.domain(end);
            end
            
            % validate params
            if ~ismember(obj.stopType, {'npoints', 'stdev', 'entropy'})
                error('ZestState:Constructor:InvalidInput', 'stopType (%s) must be one of "S", "N", or "H"', obj.stopType);
            end
            if ~ismember(obj.minStimulus, obj.domain)
                error('ZestState:Constructor:InvalidInput', 'minStimulus (%1.2f) must be included in the specified domain', obj.minStimulus);
            end
            if ~ismember(obj.maxStimulus, obj.domain)
                error('ZestState:Constructor:InvalidInput', 'maxStimulus (%1.2f) must be included in the specified domain', obj.maxStimulus);
            end
            if obj.minStimulus > obj.maxStimulus
                error('ZestState:Constructor:InvalidInput', 'specified maxStimulus (%1.2f) must be smaller than specified minStimulus (%1.2f)', obj.maxStimulus, obj.minStimulus);
            end
            
            % compute likelihood function
            n = length(obj.domain);
            obj.likelihood = nan(n, n);
            for i = 1:n
                SIGMA = 1;
SIGMA = 1.5;                    
SIGMA = 1.25;                
                obj.likelihood(:,i) = 0.03 + (1-0.03-0.03)*(1-normcdf(obj.domain, obj.domain(i), SIGMA))';
            end
            % sapply(domain, function(tt) { 0.03 + (1-0.03-0.03)*(1-pnorm(domain, tt, 1)) }),
        end
        
        %% == METHODS =================================================
        
        function [] = initialise(obj, startingGuess)
           	% compute prior pdf using inputted guess
            obj.pdf = obj.makePriorPDF(startingGuess);

            % validate (defensive)
            if abs(sum(obj.pdf)-1) > 0.000000000001
                error('ZestState:initialise:InternalError', 'It appears that ZestState.makePriorPDF did not return a well formed PDF prior??');
            end
            
            % set initialised to true (can start calling 'step' from here
            % on in)
            obj.isInitialised = true;
        end
        
        function stim_dB = getCurrentStimLvl(obj, stimChoice, ensureWithinRange)
            % ################################################################################
            % # Get current stim value
            % # Note
            % #   1) stims are rounded to nearest domain entry
            % ################################################################################
            
            % if no method of stimulus selection specified, resort to
            % stored default
            if nargin < 2 || isempty(stimChoice)
                stimChoice = obj.stimChoice;
            end
            if nargin < 3 || isempty(ensureWithinRange)
                ensureWithinRange = true;
            end
            
            % ensure initialised
            if ~obj.isInitialised
                error('State must be initialised used obj.initialise() before it can be used')
            end
            
            % get domain index
            if strcmpi(stimChoice, 'mean')
                [~,stimIndex] = min(abs(obj.domain - sum(obj.pdf .* obj.domain)));
            elseif strcmpi(stimChoice, 'mode')
                [~,stimIndex] = max(obj.pdf);
            elseif strcmpi(stimChoice, 'median')
                [~,stimIndex] = min(abs(cumsum(obj.pdf) - 0.5));
            else
                error('ZEST:getCurrentStim:unknownInput', 'stimChoice "%s" not recognised.', stimChoice)
            end
            
            % get stimulus value
            stim_dB = obj.domain(stimIndex);
            
            % ensure value within valid range [minStimulus,maxStimulus]
            if ensureWithinRange
                stim_dB = max(stim_dB, obj.minStimulus);
                stim_dB = min(stim_dB, obj.maxStimulus);
            end
        end
 
        function isFin = isFinished(obj)
            % ################################################################################
            % # Return TRUE if ZEST should stop, FALSE otherwise
            % #
            % # Input parameters
            % #   State list as returned by ZEST.start/step
            % # Returns
            % #   TRUE or FALSE
            % ################################################################################
            
            keepGoing = (obj.nPresentations < obj.maxPresentations)   && ...
                        (obj.currNotSeenLimit < obj.minNotSeenLimit)    && ...
                        (obj.currSeenLimit    < obj.maxSeenLimit)       && ...
                        ( ...
                            (strcmpi(obj.stopType,'stdev') && (obj.stdev(obj) > obj.stopValue))      ...
                            || (strcmpi(obj.stopType,'entropy') && (obj.entropy(obj) > obj.stopValue)) ...
                            || (strcmpi(obj.stopType,'npoints') && (obj.nPresentations < obj.stopValue)) ...
                        );
            
            isFin = ~keepGoing;
        end
        
        function threshEst_dB = getFinalThresholdEst(obj, stimChoice)
            % ################################################################################
            % # Given a state, return an estimate of threshold
            % #
            % # Input parameters
            % #   State list as returned by ZEST.start/step
            % # Returns
            % #   Mean   of pdf if state$stimChoice == "mean"
            % #   Mode   of pdf if state$stimChoice == "mode"
            % #   Median of pdf if state$stimChoice == "median"
            % ################################################################################
            
            if nargin < 2
                stimChoice = [];
            end
            
            % get stimulus/threshold estimate value
            threshEst_dB = obj.getCurrentStimLvl(stimChoice, false);
        end
    
        function finalThresh = update(obj, presentedStimLvl_dB, stimWasSeen, responseTime_ms)
        
            % ################################################################################
            % # Update state given response.
            % ################################################################################
             
            % validate
            switch presentedStimLvl_dB
                case obj.getCurrentStimLvl('mean')
                    [~,stimIndex] = min(abs(obj.domain - sum(obj.pdf .* obj.domain)));
                case obj.getCurrentStimLvl('mode')
                    [~,stimIndex] = max(obj.pdf);
                case obj.getCurrentStimLvl('median')
                    [~,stimIndex] = min(abs(cumsum(obj.pdf) - 0.5));
                otherwise
                    error('presented stimulus level (%1.2f) does not appear to correspond to the mean, mode, or median strategy?', presentedStimLvl_dB);
            end
            
            % store trial (just gone) record
            obj.stimLvls_dB(end+1)      = presentedStimLvl_dB;
            obj.responses_wasSeen(end+1)= stimWasSeen;
            obj.responseTimes_ms(end+1)	= responseTime_ms;
            obj.nPresentations        = obj.nPresentations + 1;

            if stimWasSeen
                if (presentedStimLvl_dB == obj.maxStimulus)
                    obj.currSeenLimit = obj.currSeenLimit + 1;
                end
                obj.pdf = obj.pdf .* obj.likelihood(stimIndex, :)';
            else
                if (presentedStimLvl_dB == obj.minStimulus)
                    obj.currNotSeenLimit = obj.currNotSeenLimit + 1;
                end
                obj.pdf = obj.pdf .* (1 - obj.likelihood(stimIndex, :)');
            end
            
            % renormalise PDF so that it sums to 1
            obj.pdf = obj.pdf/sum(obj.pdf);
            
            % for convenience, automatically return final threshold
            % estimate (or NaN, if not yet finished)
            if obj.isFinished()
                finalThresh = obj.getFinalThresholdEst();
            else
                finalThresh = NaN;
            end
            
        end
        
    end

        
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
  
    methods (Access = private)
        
        % Use available info to guess the observer's threshold for a given
        % location.
        % bimodal prior, constructed as in:
        %   Turpin et al  IOVS 44(11), November 2003. Pages 4787-4795.
        function priorPdf = makePriorPDF(obj, startingGuess, weightNormal, pdfFloor)
            if nargin < 3 || isempty(weightNormal)
                weightNormal = 4;
            end
            if nargin < 4 || isempty(pdfFloor)
                pdfFloor = 0.001;
            end

            glaucomaPDF = repmat(0.001, [length(obj.domain) 1]);
            glaucomaPDF(1:(6+abs(obj.domain(1)))) = [repmat(0.001, [1 abs(obj.domain(1))]),0.2, 0.3, 0.2, 0.15,0.1, 0.02];
          
            normalModePoint = round(startingGuess);
            tmp = [repmat(0.001, [1 50]), 0.009, 0.03, 0.05, 0.1, 0.2, 0.3, 0.2, 0.05, 0.025, 0.01, repmat(0.001,[1 50])];
            [~,mode] = max(tmp);
            healthyPDF = tmp((mode-normalModePoint+obj.domain(1)):(mode-normalModePoint+obj.domain(end)))';
            
            biModalPDF = healthyPDF * weightNormal + glaucomaPDF;
            biModalPDF(biModalPDF < pdfFloor) = pdfFloor;
            priorPdf = biModalPDF./sum(biModalPDF); % make into an actual PDF (sum to 1)
        end
    end
    
    
   	%% ====================================================================
    %  -----STATIC METHODS (private)-----
    %$ ====================================================================
  
    % little helper functions
    methods (Static, Access = private)
        function sd = stdev(state)
            sd = sqrt(sum(state.pdf .* state.domain .* state.domain) - sum(state.pdf .* state.domain)^2);
        end
        
        function e = entropy(state)
            z = state.pdf>0;
            e = -sum(state.pdf(z) .* log2(state.pdf(z)));
        end
    end
    
    
   	%% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
      
    % little helper functions
    methods (Static, Access = public)

        function [] = runTests()
            import visfield.zest.*
            
            % create example state object
            zs = ZestState(1, 1, -5:30, 'entropy', 1.5);
            
            % check prior computed correct (given above parameters)
            startingGuess = 25;
            weightNormal = 4;
            priorPdf = zs.makePriorPDF(startingGuess, weightNormal);
            if any((priorPdf(end-3:end) - [0.0402 0.0202 0.0082 0.001]') > 0.000001)
                error('wrong prior values returned?');
            end
            
            % initialise
            zs.initialise(25);
            
            % check: getCurrentStimLvl
            if zs.getCurrentStimLvl('mean') ~= 20
                error('wrong level??');
            end
            if zs.getCurrentStimLvl('mode') ~= 25
                error('wrong level??');
            end
            if zs.getCurrentStimLvl('median') ~= 24
                error('wrong level??');
            end
            
            % check: isFinished
            if zs.isFinished()
                error('should not be finished??');
            end
            
            % check: update(), getCurrentStimLvl()
            zs.update(zs.getCurrentStimLvl('mean'), true, 400)
            if zs.getCurrentStimLvl('mean') ~= 25
                error('wrong level??');
            end
            if zs.getCurrentStimLvl('mode') ~= 25
                error('wrong level??');
            end
            if zs.getCurrentStimLvl('median') ~= 24
                error('wrong level??');
            end
            % ...and another
            zs.update(zs.getCurrentStimLvl('mean'), true, 400)
            if zs.getCurrentStimLvl('mean') ~= 26
                error('wrong level??');
            end
            if zs.getCurrentStimLvl('mode') ~= 26
                error('wrong level??');
            end
            if zs.getCurrentStimLvl('median') ~= 25
                error('wrong level??');
            end
            
            % check: isFinished
            zs = ZestState(1, 1, -5:30, 'stdev', 1.5);
            zs.initialise(25);
            for i = 1:10
                fprintf('Trial %2i: isFin==%i, Presenting==%i & updating values...', i, zs.isFinished(), zs.getCurrentStimLvl('mean'));
                zs.update(zs.getCurrentStimLvl('mean'), true, 400);
                fprintf(' (now: stdev==%1.2f, entropy==%1.2f)\n', ZestState.stdev(zs), ZestState.entropy(zs));
            end
            fprintf('nPresentations: %2i  (max = %i)\n', zs.nPresentations, zs.maxPresentations)
            fprintf('currNotSeenLimit: %2i  (max = %i)\n', zs.currNotSeenLimit, zs.minNotSeenLimit)
            fprintf('   currSeenLimit: %2i  (max = %i)\n', zs.currSeenLimit, zs.maxSeenLimit)
            fprintf('        stopType: %s\n', zs.stopType);

            % all done
            fprintf('\n\nAll checks ok\n');
        end
    end
  
end