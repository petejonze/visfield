function fn = newBlock()
%NEWBLOCK description.
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
    global CONFIG;      %to get
    %----------------------------------------------------------------------

    %check that we are good to go
    %<todo>
    
    %initialise local variables
    cfg=CONFIG;
    
    %go!
    endCurrentDataFile();       % 1
    iterateBlockNum();          % 2   
    fn = beginNewDataFile(cfg);	% 3
    writeNote('Block number iterated manually by experiment script - i.e. using "newBlock()"');
 
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>