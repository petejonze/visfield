function newBlock_B()
%NEWBLOCK_B description.
%
% to use with softAbort..
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
    beginNewDataFile(cfg); 	% 3
    writeNote('Block number iterated manually by experiment script - i.e. using "newBlock_B()"');
 
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>