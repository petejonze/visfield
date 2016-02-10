function [thresh,reversalVals,idx] = getThreshFromFile2(fns, fieldname, nReversalsToUse)
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

    %% run
    [s,pid,sid,bids]=extractFiles2Struct(fns);

    nBlocks = length(bids);

    thresh = nan(nBlocks, 1);
    reversalVals = cell(nBlocks, 1);
    idx = cell(nBlocks, 1);
    
    for bid = bids
        % get data
        dat = s.part(pid).sess(sid).block(bid).raw.struct;
        %
        DV = dat.(fieldname);
        if isfield(dat, 'isReversal')
            isReversal = dat.isReversal;
        else
            isReversal = [];
        end

        % after ss_process_summariseTrack
        [thresh(bid),reversalVals{bid},idx{bid}] = getTrackThresh(DV, nReversalsToUse, [], isReversal);
    end

end