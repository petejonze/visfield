function isPresent=isDataLogPresent(dataDir,expID)
%ISDATALOGPRESENT description.
%
% desc
%
% Example: none
%
% See also startDataSession writeData finishDataSession

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('dataDir', @ischar);
    p.addRequired('expID', @ischar);
    p.FunctionName = 'OPENDATALOG';
    p.parse(dataDir,expID);
    %----------------------------------------------------------------------

    %check that we are good to go
    %<blank>
    
    %initialise local variables
    %<blank>
    
    %check if file exists
    if exist([dataDir filesep expID '-dataLog.txt'],'file')
        isPresent=true;
    else
        isPresent=false;
    end

	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>