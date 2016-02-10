function blockNum = getBlockNum()
%ITERATEBLOCKNUM description.
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
    global BLOCK_NUM;
    %----------------------------------------------------------------------

    %check that we are good to go
    if isempty(BLOCK_NUM)
        error('PsychTestRig:iterateSession:noSessionIDFound','No previous Block ID found. Make sure that startDataGatheringPeriod was called prior to this script')  
    end
    
    %initialise local variables
    blockNum = BLOCK_NUM;

    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>