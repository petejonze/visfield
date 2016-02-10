function stopDataGatheringPeriod()
%STOPDATAGATHERINGPERIOD description.
%
% desc
%
% Example: none
%
% See also
%Summary statistics??????????????????

    %----------------------------------------------------------------------
    % Parse & validate all input args
    %<none>
    %----------------------------------------------------------------------
    
	%close data log
	closeDataLog();

	%clear global variables
	clear global OUTPUT_FILE_ID EXP_ID PART_ID OUTPUT_PART_DATADIR OUTPUT_MASTER_DATADIR SESS_ID CONFIG BLOCK_NUM;
    
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>