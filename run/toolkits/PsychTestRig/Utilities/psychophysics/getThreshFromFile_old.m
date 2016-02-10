function [threshs, nReversals, s] = getThreshFromFile(fn, fieldname, nReversalsToUse, excludeFirstNReversals)
%PC_GETTHRESHS  extract threshold data from binary adaptive track data
%
%   <Further Info>
%
% @Requires the following toolkits:
%   my PsychTestRig toolbox
%   PsychToolBox
%   
% @Parameters:              
%
%     	pid     Int 	#####
%                      ####
%
% @Returns:  
%
%     	thresh     Int 	#####
%                      ####
%
% @Usage:           pC_getThreshs(pid)
% @Example:         pC_getThreshs(3)
%
% @Requires:        PsychToolBox
%                   PsychTestRig (v0.5)
%   
% @See also:        <none>
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	27/11/2011
% @Last Update:     27/11/2011
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	27/11/2011    Initial build.
%
% @Todo:            Lots!

    %% init
    if nargin < 3 || isempty(nReversalsToUse)
        nReversalsToUse = inf;
    end

    if nargin < 4 || isempty(excludeFirstNReversals)
        excludeFirstNReversals = 0;
    end

    %% run
    [s,pid,sid,bids]=extractFiles2Struct(fn);

    nBlocks = length(bids);
    threshs = nan(nBlocks, 1);
    nReversals = nan(nBlocks, 1);

    for bid = bids
        bid
        % get data
        dat = s.part(pid).sess(sid).block(bid).raw.struct;
        %
        DV = dat.(fieldname);
        isReversal = dat.isReversal;
        wasInLeadInStage = dat.wasInLeadInStage;

        % after ss_process_summariseTrack
        [threshs(bid),nReversals(bid)] = lcl_getThresh(DV, isReversal, wasInLeadInStage, excludeFirstNReversals, nReversalsToUse);
    end
    
    % append means
    threshs = [threshs; mean(threshs,1)];
    nReversals = [nReversals; mean(nReversals,1)];
end

function [thresh,nReversals_preExclude] = lcl_getThresh(DV, isReversal, wasInLeadInStage, excludeFirstNReversals, nReversalsToUse)

        

        %
        %   INIT
        %
        % get indices for all the cases of reversals, excluding any that may
        % have happened during a lead-in stage
        reversalIndex = isReversal & (1-wasInLeadInStage);
        reversalVals = DV(reversalIndex==1); % pick out just the vals at the reversals
        nReversals_preExclude = length(reversalVals);
        reversalVals(1:excludeFirstNReversals) = []; % exclude first n vals of main track
        nReversals = length(reversalVals);
        
        % ensure an even number
        if mod(nReversals,2)== 1
            reversalVals(1) = [];
            nReversals = nReversals - 1;
        end
            
        if isinf(nReversalsToUse) % use all
            nReversalsToUse = nReversals;
        end
        
        % calc
        if nReversals < nReversalsToUse
            thresh = NaN;
        else
            thresh = mean(reversalVals(end-(nReversals-1):end));
        end


%         warning('pC_getThreshs:InsufficientReversals','Not enough reversals, reverting to last N trials');
%         %
%         %   LAST N
%         %
%         if length(DV) >= 4
%             thresh_lastFour = mean(DV(end-3:end));
%             thresh_lastMax = thresh_lastFour;
%         end
%         if length(DV) >= 8
%             thresh_lastEight = mean(DV(end-7:end));
%             thresh_lastMax = thresh_lastEight;
%         end
% 
%         thresh = thresh_lastMax;

end