classdef AdaptiveTrack < handle
%#####
%
%   Adapted from ss_draft2_staircase_v4 [OOP]
%
%   Implements a simple Transformed Levitt Staircase (Levitt, 1971). To
%   crudely mimic OOP style encapsulation, we shall use 'persistant'
%   variables to store data, so that the main experiment loop doesn't have
%   to provide anything except the initialisation parameters (which could
%   be optional, but for safety and ease we will make them compulsary here,
%   since if you don't know what parameters you want then you arguably
%   shouldn't be running the experiment in the first place), and ongoing
%   performance info (was the last trial right/wrong). Optionally this code
%   can also output a figure at an ongoing basis, or upon demand. To allow
%   for the latter performance data is saved on an ongoing basis also, and
%   can be queried directly.
%
%   This function could be extended as follows:
%       > providing alternate stopping criteria (e.g. nReversals, nTrials)
%       > by allowing for interleaved tracks
%       > by including 'gain' factors (for variable step sizes)
%       > by making the leadin phase optional
%
%   n.b.
%   for a more complicated staircase a toolbox has been developed, but
%   looked a bit messy and/or OTT for this project. Details here:
%   http://arthur.is.verweg.com/projects/staircase/
%
%   n.b.
%   3down-1up targets: 79.4% correct
%   2down-1up targets: 70.7% correct
%
% @Requires the following toolkits: <none>
%   
% @Constructor Parameters:              
%
%     	initialVal              Real.       #####
%                                           e.g.
%       [stepAbsolute]          Logical.  	if a false then relative
%                                           e.g.
%       [stepValRelativeToStd]	Logical.  	#####
%                                           e.g.
%   	leadIn_nUp              Integer.    #####
%                                           e.g.
%       leadIn_nDown            Integer.    #####
%                                           e.g.
%       leadIn_stepSize      	Real.       #####
%                                           e.g.
%       leadIn_nReversalsLim	Integer.    #####
%                                           e.g.
%       [leadIn_finalDirection]	Integer.    #####
%                                           e.g.
%       main_nUp                Integer.    #####
%                                           e.g.
%       main_nDown            	Integer.    #####
%                                           e.g.
%       main_stepSize         	Real.       #####
%                                           e.g.
%       main_nReversalsLim    	Integer.    #####
%                                           e.g.
%       nReversals_analysis 	Integer.    #####
%                                           e.g.
%       maxN                    Integer.    #####
%                                           e.g.
%       minVal               	Real.       #####
%                                           e.g.
%       maxVal                	Real.       #####
%                                           e.g.
%       verbosity               Integer.    #####
%                                           e.g.
%
%
% @Example:         aT = AdaptiveTrack(AdaptiveTrack.getDummyParams())
%                   aT.Update(true);
%
% @See also:        ss_draft2_main3
%
% @Earliest compatible Matlab version:	v2008
%
% @Author:          Pete R Jones
%
% @Creation Date:	05/07/10
% @Last Update:     29/11/11
%
% @Current Verion:  2.0.0
% @Version History: v1.0.0	24/02/2011    Initial build.
%                   v2.0.0	29/11/2011    Added relative deltas (e.g. for freq discrim).
%
% @Todo:            ?
%
% Update from v2: should not be a reversal if get one or two right (i.e. using a 3-down), but
% then get one wrong
%
properties (GetAccess = 'public', SetAccess = 'private')
    figHandles
end

    properties (GetAccess = 'private', SetAccess = 'private')
        % user specified parameters
        standard
     	initialStepVal
        stepVal
        stepValIsAbs % if false then dynamic/multiplicative
        %
        leadIn_nUp
        leadIn_nDown
        leadIn_stepSize
        leadIn_nReversalsLim
        leadIn_finalDirection
    	main_nUp
        main_nDown
        main_stepSize
        main_nReversalsLim
        nReversals_analysis	%(in contrast with MLE) typically we discard the early trials and base the final estimates on the last few (hopefully stable) values. For hbalance this must be an even number. Two and four are common, though many more (e.g. 16) are used in some literatures.
      	maxN
        minVal
        maxVal
        reachedLim
        targetValue
        trackFinished
     	verbosity
        % 
%         figHandles
        % Cell. A vector which expands on each loop. Perhaps not ideal coding
        % practice, but the performance hit is insigificant.
        inLeadInPhaseHistory
        performanceHistory
        targetValueHistory
        reversalHistory
        % Since we are storing the complete set of results we could work all the
        % following out from scratch each time. However, these helper variables
        % (which are updated on an ongoing basis) just make the logic a bit easier
        % to follow
        nWrongInARow
        nRightInARow
        nReversals
        directionsHistory
        lastLeadInTrial
        %
        nUp
        nDown
        stepSize
        nReversalsLim
        inLeadInPhase
        prevReversalDirection
        firstNonZeroDirection
    end

    methods (Access = 'public')
        %Constructor
        function obj=AdaptiveTrack(params) 
            % set specified parameter values
            obj.standard                    = params.standard;
            obj.initialStepVal              = params.initialDifference;
            obj.stepValIsAbs                = params.stepValIsAbs;
            %
            obj.leadIn_nUp                  = params.leadIn_nUp;
            obj.leadIn_nDown                = params.leadIn_nDown;
            obj.leadIn_stepSize           	= params.leadIn_stepSize;
            obj.leadIn_nReversalsLim        = params.leadIn_nReversalsLim;
            obj.leadIn_finalDirection       = params.leadIn_finalDirection; % i.e. 1==was getting them right, but now wrong. -1==was getting them wrong, but now right. Probably want to avoid -1, since this is consistent with an initial lack of concentration 
            obj.main_nUp                    = params.main_nUp;
            obj.main_nDown                  = params.main_nDown;
            obj.main_stepSize               = params.main_stepSize;
            obj.main_nReversalsLim          = params.main_nReversalsLim;
            obj.nReversals_analysis         = params.nReversals_analysis;
            obj.maxN                        = params.maxN;
            obj.minVal                      = params.minVal;
            obj.maxVal                      = params.maxVal;
            obj.verbosity                   = params.verbosity;
            
            % init
            obj.reachedLim                  = false;
            obj.setCurrentParams(obj.leadIn_nUp, obj.leadIn_nDown, obj.leadIn_stepSize, obj.leadIn_nReversalsLim); %wonder if there is a better way to do this?
            obj.inLeadInPhase               = true;
            obj.trackFinished               = false;
            obj.stepVal                     = obj.initialStepVal;
            obj.targetValue                 = obj.standard + obj.initialStepVal; % initial target
            obj.inLeadInPhaseHistory        = []; % for performing analysis
            obj.performanceHistory          = [];
            obj.targetValueHistory          = obj.targetValue;
            obj.reversalHistory             = [];
            obj.directionsHistory           = [];
            obj.prevReversalDirection       = 99; % arbitrary value 
            obj.firstNonZeroDirection       = [];
            if obj.verbosity > 1
               obj.figHandles = AdaptiveTrack.createPlot(obj.maxN, obj.targetValue, obj.minVal, obj.maxVal);
            end
        end
        
        function obj = delete(obj)
            if ~isempty(obj.figHandles.hFig) && ishandle(obj.figHandles.hFig)
                delete(obj.figHandles.hFig);
            end
            obj.figHandles.hFig = [];
            clear obj;
        end
        
        function est=getThresholdEstimate(obj)
            % extract key data
            reversalIndex = [obj.reversalHistory] & (1-[obj.inLeadInPhaseHistory]); % get indices for all the cases of reversals, exclude any that may have happened during a lead-in stage
            reversalVals = obj.targetValueHistory(reversalIndex==1); % grab the stimulus vals at the test reversals
            nReversals = length(reversalVals);
            
            % get number of reversals to analyse
            nReversalsAnalysis = obj.nReversals_analysis;
            if nReversalsAnalysis == -1 %just return the most available
               	nReversalsAnalysis = nReversals - mod(nReversals,2); % get largest even number
            end
            
            % calc threshold (return NaN if analysis fails)
            if nReversals >= nReversalsAnalysis && nReversalsAnalysis > 0
                reversalVals = reversalVals(end-(nReversalsAnalysis-1):end); % grab the specified number of reversals
                est = mean(reversalVals);
            else
                est = NaN; % could probably think of something a little more graceful than this, but screw it it'll do for now
            end
        end
        
        % Update with new results
        function obj=Update(obj,wasCorrect)
            
            % ensure limit hasn't been reached
            if obj.trackFinished
                warning('StaircaseUpdate:LimitReacged', 'Cannot update, limit reached. Will return null');
                obj = [];
                return
            end
            
            % ######
            nTrials = length(obj.directionsHistory)+1;
            if obj.verbosity > 0; fprintf('   %i',nTrials); end
                        
            % update performance history
            obj.performanceHistory(end+1)=wasCorrect;
            obj.reversalHistory(end+1) = 0; %assume for now that not a reversal - will overwrite later if necessary
            obj.inLeadInPhaseHistory(end+1) = obj.inLeadInPhase;
            
            % update position in value space
            delta = 0;
            if wasCorrect
                obj.nRightInARow = obj.nRightInARow + 1;
                obj.nWrongInARow = 0;
                if obj.nRightInARow >= obj.nDown
                    if obj.verbosity > 0; fprintf('... moving down  (getting harder)'); end
                    delta = -1;
                    % reset count
                    obj.nRightInARow = 0;
                end
            else
                obj.nWrongInARow = obj.nWrongInARow + 1;
                obj.nRightInARow = 0;
                if obj.nWrongInARow >= obj.nUp
                    if obj.verbosity > 0; fprintf(' ... moving up  (getting easier)'); end
                    delta = +1;
                 	% reset count
                    obj.nWrongInARow = 0;
                end
            end
            obj.directionsHistory(end+1) = delta;
            if obj.verbosity > 0; fprintf('\n'); end
            
            if delta ~= 0 && isempty(obj.firstNonZeroDirection)
                if obj.verbosity > 0; fprintf('setting initial direction to: %i\n',delta); end
                obj.firstNonZeroDirection = delta;
                obj.prevReversalDirection = delta; % suppress the first non-zero direction from being counted as a reversal.
            end
                
            % check for reversals and whether any criteria have thus been met
            if nTrials == obj.maxN
                obj.trackFinished = true;
                obj.reachedLim = true;
                if obj.verbosity > 1
                    figure(obj.figHandles.hFig)
                    text(max(1,nTrials-10),obj.targetValue,'/*** REACHED LIMIT ***/')
                end
            elseif nTrials > 1
 
                % elseif obj.directionsHistory(end) ~= 0 && obj.directionsHistory(end) ~= obj.directionsHistory(end-1)
                    % no, this isn't good enough. If nUp or nDown are
                    % greater than 1 then can go up/down, *then* steady,
                    % *then* up/down again, without a reversal having taken
                    % place. INSTEAD:
                if delta ~= 0 ... %check if was a reversal
               	&& delta ~= obj.directionsHistory(end-1) ...
                && delta ~= obj.prevReversalDirection
                    obj.reversalHistory(end) = 1;
                    obj.prevReversalDirection = delta;
                    if obj.verbosity > 0; fprintf('reversal @ %i\n', nTrials); end
                    obj.nReversals = obj.nReversals + 1;
                    if obj.nReversals >= obj.nReversalsLim %i.e. can exceed the limit if a final direction is specified
                        if obj.inLeadInPhase
                            if isempty(obj.leadIn_finalDirection) || obj.leadIn_finalDirection == obj.directionsHistory(end)
                                obj=obj.setCurrentParams(obj.main_nUp, obj.main_nDown, obj.main_stepSize, obj.main_nReversalsLim);
                                obj.inLeadInPhase = false;
                                obj.lastLeadInTrial = nTrials;
                                if obj.verbosity > 0; disp('Finished lead in. Switching to main..'); end
                            end
                        else
                            disp('/*** COMPLETE ***/')
                            obj.trackFinished = true;
                            if obj.verbosity > 1
                                figure(obj.figHandles.hFig)
                                text(nTrials+1,obj.targetValue,'/*** COMPLETE ***/')
                            end
                        end
                    end
                end
            end
            
            % PLOT     
            if obj.verbosity > 1
                lastTrialN = length(obj.performanceHistory);
                trialNums = 1:lastTrialN;
                set(obj.figHandles.hPerf,'XData',trialNums,'YData',obj.targetValueHistory);
                set(obj.figHandles.hRight,'XData',trialNums(obj.performanceHistory==1),'YData',obj.targetValueHistory(obj.performanceHistory==1));
                set(obj.figHandles.hWrong,'XData',trialNums(obj.performanceHistory==0),'YData',obj.targetValueHistory(obj.performanceHistory==0));
                
                vlineX = []; vlineC = {}; vlineL = {};
                prevReversalDirection = 0;
                firstNonZeroDirection = [];
                for i=1:length(obj.directionsHistory)
                    delta = obj.directionsHistory(i);
                    if delta ~= 0 && isempty(firstNonZeroDirection)
                     	firstNonZeroDirection = delta;
                    	prevReversalDirection = delta; % suppress the first non-zero direction from being counted as a reversal.
                    end 
                    if  i > 1 ...
                  	&& delta ~= 0 ...
                    && delta ~= obj.directionsHistory(i-1) ...
                  	&& delta ~= prevReversalDirection
                        prevReversalDirection = delta;
                        colorVal = 'k';
                        if isempty(obj.lastLeadInTrial) || i <= obj.lastLeadInTrial
                            colorVal = ':k';
                        end
                        vlineX(end+1) = i;  %#ok
                        vlineC{end+1} = colorVal;  %#ok
                        vlineL{end+1} = '';  %#ok
                    end
                end
                if ~isempty(vlineX)
                    if length(vlineX) > 1
                        obj.figHandles.hVlines = vline(vlineX,vlineC,vlineL);
                    else
                        obj.figHandles.hVlines = vline(vlineX(:),vlineC{:},vlineL{:});
                    end
                end
            end
            
            % Update stepVal value
            % calc the step
            if obj.stepValIsAbs
                obj.stepVal = obj.stepVal + delta*obj.stepSize;
            else
                stepFactor = obj.stepSize; %e.g. 2 [50 -> 25]
                if delta < 0
                    stepFactor = 1/stepFactor; % e.g. 0.5 [50 -> 100]
                end
                if delta ~= 0
                    obj.stepVal = obj.stepVal / stepFactor;
                end
            end
            if delta ~= 0
                obj.targetValue = obj.standard + obj.stepVal;
            end

            % make sure that within limits
            obj.targetValue = min(obj.targetValue,obj.maxVal); % not too big
            obj.targetValue = max(obj.targetValue,obj.minVal); % not too small
            % update history
            obj.targetValueHistory(end+1)=obj.targetValue;
            
            % Plot next target value [cross]     (this could be amalgameted with above if the update
            % was moved to be prior. But then would have to remember to
            % remove the last history value from the plot
            if obj.verbosity > 1
                set(obj.figHandles.hNextTarget,'XData',length(obj.targetValueHistory),'YData',obj.targetValue);
                drawnow();
            end
        end
        
        % get 
        function isFin=isFinished(obj)
            isFin = obj.trackFinished;
        end
        
        % get 
    	function reachedLim=reachedLimit(obj)
            reachedLim = obj.reachedLim;
        end

        % get 
    	function inLeadInPhase=isInLeadInPhase(obj)
            inLeadInPhase = obj.inLeadInPhase;
        end
        
        % get 
     	function wasReverse=wasAReversal(obj) % assume want to know about the most recent, could expand to be any.
            if obj.reversalHistory(end) %0 or 1
                wasReverse = true;
            else
                wasReverse = false;
            end
        end       
        
        
        function stepSize=getStepSize(obj)
            stepSize = obj.stepSize;
        end
        % get Dependent Variable values
        function targVal=getTargetValue(obj)
            targVal = obj.targetValue;
        end
        
        function [x,y,z]=getHistory(obj)
            x = [obj.targetValueHistory(1:(end-1))...
                ;obj.inLeadInPhaseHistory...
                ;obj.reversalHistory...
                ];
            
            idx = obj.inLeadInPhaseHistory == 0 & obj.reversalHistory == 1;
            if mod(sum(idx),2) ~= 0
                idx(find(idx,1)) = 0; % discard first [to ensure an even number]
            end
            y = obj.targetValueHistory(idx) - obj.standard;
            
            z = mean(y);
        end 
        
        function [] = goBack(obj, nSteps)
            if nargin < 2 || isempty(nSteps)
                nSteps = 1;
            end
            
            ####
        end
    end % end public methods
    
    methods(Static)
        function figHandles = createPlot(maxN,initialVal,minVal,maxVal)
            figHandles.hFig=figure(length(findobj('Type','figure'))+1);
            set(figHandles.hFig, 'Position', [300 100 600 800]); % [x y width height]
            hold on
            figHandles.hPerf = plot(-1,-1);
            figHandles.hRight = plot(-1,-1 ...
                ,'o' ...
                ,'LineWidth',2 ...
                ,'MarkerFaceColor','g' ...
                ,'MarkerEdgeColor','k' ...
                ,'MarkerSize',10);
            figHandles.hWrong = plot(-1,-1 ...
                ,'o' ...
                ,'LineWidth',2 ...
                ,'MarkerFaceColor','r' ...
                ,'MarkerEdgeColor','k' ...
                ,'MarkerSize',10);
            figHandles.hNextTarget = plot(1,initialVal ...
                ,'x' ...
                ,'MarkerEdgeColor','k' ...
                ,'MarkerSize',10);
            hold off
            xlim([1 maxN]);
            ylim([minVal, maxVal]);
            xlabel('Trial Number','FontSize',16);
            ylabel('Stimulus Value','FontSize',16);
            set(figHandles.hFig,'Name','Adaptive Track','NumberTitle','off'); % set window title
            % 	set(figHandles.hFig, 'color', 'white'); % sets the background color to white
            %  	no - actually looks clearer(/less overbearing) in gray
        end
        
        % useful when debugging
        function params = getDummyParams()
            params = [];
            params.standard = 66;
            params.initialDifference = 0;
            params.stepValIsAbs = 1;
            params.maxN = 5;
            params.minVal = 0;
            params.maxVal = 80;
            params.leadIn_nUp = 1;
            params.leadIn_nDown = 1;
            params.leadIn_stepSize = 6;
            params.leadIn_nReversalsLim = 1;
            params.leadIn_finalDirection = 1;
            params.main_nUp = 1;
            params.main_nDown = 2;
            params.main_stepSize = 3;
            params.main_nReversalsLim = 4;
            params.nReversals_analysis = 4;
            params.verbosity = 2;
        end
    end
    methods(Access = 'private')
     	function obj=setCurrentParams(obj,nUp,nDown,stepSize,nReversalsLim)
          	obj.nUp=nUp;
            obj.nDown=nDown;
            obj.stepSize=stepSize;
            obj.nReversalsLim=nReversalsLim;
            %
           	obj.nWrongInARow = 0;
            obj.nRightInARow = 0;
        	obj.nReversals = 0;
        end
    end
end