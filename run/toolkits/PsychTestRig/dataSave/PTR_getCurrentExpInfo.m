function [expID, partID, sessID, blockID, expHomeDir]=PTR_getCurrentExpInfo()
%PTR_GETCURRENTEXPINFO description.
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
    global DATAGATHERING_BEGUN EXP_ID PART_ID SESS_ID BLOCK_NUM EXP_HOMEDIR;
    %----------------------------------------------------------------------

    %check that we are good to go
    if isempty(DATAGATHERING_BEGUN) || ~DATAGATHERING_BEGUN
        error('PsychTestRig:beginNewDataFile:inactiveDataGatheringPeriod','Data gathering period is not active. You must call startDataGatheringPeriod before this script will work!')  
    end
    
    %initialise local variables   
    expID = EXP_ID;
    partID = PART_ID;
    sessID = SESS_ID;
    blockID = BLOCK_NUM;
    expHomeDir = EXP_HOMEDIR;
    
    %run
    return
    
end