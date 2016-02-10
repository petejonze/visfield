function iterateSessionNum()
%ITERATESESSIONNUM description.
%
% desc
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    % Parse & validate all input args
    % <none>
    %----------------------------------------------------------------------
    global SESS_ID BLOCK_NUM; %to set
    %----------------------------------------------------------------------

    %check that we are good to go
    if isempty(SESS_ID)
        error('PsychTestRig:iterateSession:noSessionIDFound','No previous session ID found. Make sure that startDataGatheringPeriod was called prior to this script')  
    end
    
    % increment
    SESS_ID = sessID + 1;
   	BLOCK_NUM = 1;
     
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>