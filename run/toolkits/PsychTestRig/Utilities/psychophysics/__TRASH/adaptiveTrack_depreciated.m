classdef adaptiveTrack
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
% @Example:         s=adaptiveTrack(60,  1,1,10,1,1,  1,3,4,4,  4,30,10,80,  true);
%                   s=s.Update(true);
%                   
%                   Frequency discrimination:
%                   s=adaptiveTrack(60,  1,1,10,1,1,  1,3,4,4,  4,30,10,80, true)
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
    properties
        %<none>
    end
    properties (Constant)
        %<none>
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
        figHandles
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
    properties (Dependent)
        %<none>
    end
    methods
        %Constructor
        function obj=adaptiveTrack(...
                            standard,initialDifference,stepValIsAbs,...
                            leadIn_nUp,leadIn_nDown,leadIn_stepSize,leadIn_nReversalsLim,leadIn_finalDirection,...
                           	main_nUp,main_nDown,main_stepSize,main_nReversalsLim,...
                          	nReversals_analysis,maxN,minVal,maxVal,...
                         	verbosity...
                            ) 
            % set specified parameter values
            obj.standard=standard;
            obj.initialStepVal=initialDifference;
            obj.stepValIsAbs=stepValIsAbs;
            %
            obj.leadIn_nUp=leadIn_nUp;
            obj.leadIn_nDown=leadIn_nDown;
            obj.leadIn_stepSize=leadIn_stepSize;
            obj.leadIn_nReversalsLim=leadIn_nReversalsLim;
            obj.leadIn_finalDirection = leadIn_finalDirection; % i.e. 1==was getting them right, but now wrong. -1==was getting them wrong, but now right. Probably want to avoid -1, since this is consistent with an initial lack of concentration 
            obj.main_nUp=main_nUp;
            obj.main_nDown=main_nDown;
            obj.main_stepSize=main_stepSize;
            obj.main_nReversalsLim=main_nReversalsLim;
            obj.nReversals_analysis=nReversals_analysis;
            obj.maxN = maxN;
            obj.minVal = minVal;
            obj.maxVal = maxVal;
            obj.verbosity=verbosity;
            % init
            obj.reachedLim = false;
            obj = obj.setCurrentParams(leadIn_nUp,leadIn_nDown,leadIn_stepSize,leadIn_nReversalsLim); %wonder if there is a better way to do this?
            obj.inLeadInPhase = true;
            obj.trackFinished = false;
            obj.stepVal=initialDifference;
            obj.targetValue = standard + initialDifference; % initial target
            obj.inLeadInPhaseHistory = []; % for performing analysis
            obj.performanceHistory = [];
            obj.targetValueHistory = obj.targetValue;
            obj.reversalHistory = [];
            obj.directionsHistory = [];
            obj.prevReversalDirection = 99; % arbitrary value 
            obj.firstNonZeroDirection = [];
            if obj.verbosity > 1
               obj.figHandles = createPlot(maxN,obj.targetValue,minVal,maxVal);
            end
        end
        
        function HelloWorld(obj)
            disp(['step size == ' num2str(obj.stepSize)]);
            disp(['nReversals_analysis == ' num2str(obj.nReversals_analysis)]);
            disp(['inLeadInPhase == ' log2str(obj.inLeadInPhase)]);   
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
                    figure(obj.figHandles.hfig)
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
                                figure(obj.figHandles.hfig)
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
        
    end % end public methods
    methods (Static)
        %<none>
    end
    methods(Access = private)
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
 
%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
function figHandles=createPlot(maxN,initialVal,minVal,maxVal)
    figHandles.hfig=figure(length(findobj('Type','figure'))+1);
    set(figHandles.hfig, 'Position', [300 100 600 800]); % [x y width height]
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
    set(figHandles.hfig,'Name','Adaptive Track','NumberTitle','off'); % set window title
% 	set(figHandles.hfig, 'color', 'white'); % sets the background color to white
%  	no - actually looks clearer(/less overbearing) in gray
end