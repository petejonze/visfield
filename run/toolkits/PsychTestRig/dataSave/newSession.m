function newSession()
%NEWSESSION description.
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
    endCurrentDataFile();   % 1
    iterateSessionNum();    % 2
    beginNewDataFile(cfg); 	% 3
    writeNote('Session number iterated manually by experiment script - i.e. using "newSession()"');
 
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>