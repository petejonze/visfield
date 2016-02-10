function isValid=isValidConfig(cfg)
%ISVALIDCONFIG description.
%
% desc
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('cfg', @isstruct);
    p.FunctionName = 'ISVALIDCONFIG';
    p.parse(cfg); % Parse & validate all input args
    %----------------------------------------------------------------------
%warning('PsychTestRig:isValidConfig','in progress - 2/2/10 - finish me')   

    % Initialise local variables
    isValid=true;

    %check script exists using EXIST
    if ~exist(cfg.script,'file')
        fprintf(['      PTR_Error: The script file "' cfg.script '" specified in ' cfg.id ' cannot be found\n'])
        isValid=false; return;
    end
      
    % check ptr version
    if verLessThan('PsychTestRig',num2str(cfg.ptrVersion))
        fprintf(['      PTR_Error: The version of PsychTestRig specified in the config (%s) is greater\n'...
                 '      than the currently installed version of PTR (%s).\n\n'...
                 '      See ver(''PsychTestRig'') for more info.\n'],num2str(cfg.ptrVersion),getversion('PsychTestRig'));
        isValid=false; return;
    end
    if verGreaterThan('PsychTestRig',num2str(cfg.ptrVersion))
        fprintf(['\n      PTR_Check: The version of PsychTestRig specified in the config (%s) is less\n'...
                 '      than the currently installed version of PTR (%s). This could cause problems if any\n'...
                 '      of the core functions have been modified or depreciated in the meantime\n\n'],num2str(cfg.ptrVersion),getversion('PsychTestRig'));
        if ~getLogicalInput('continue (y/n)?');
            isValid=false; return;
        end
    end
       
       
    % check that script is valid
    try
        numParamsAccepted = nargin(cfg.script);
    catch %#ok
        fprintf(['      PTR_Error: The script file "' cfg.script '" specified in ' cfg.id ' appears to contain errors\nTry running nargin(SCIPRT_NAME)'])
        isValid=false; return;        
    end
    
    %given script check that have the right number of parameters specified using NARGIN(<script>)
    if isempty(cfg.params)
    	numParamsSpecified = 0;
    else
    	numParamsSpecified = length(fieldnames(cfg.params));
    end
    if numParamsSpecified+1 < numParamsAccepted %+1 because first parameter is the metaInfo
       	fprintf(['      PTR_Error: The number of parameters specified in ' cfg.id ' (' int2str(numParamsSpecified) ') is fewer than the number required by ' cfg.script ' (' int2str(numParamsAccepted) ')\n'])
        isValid=false;
    elseif numParamsSpecified > numParamsAccepted
        if numParamsAccepted < 0 %i.e. if script accepts varargin
            numRqd = abs(numParamsAccepted) - 1; % ignore varargin
            if numParamsSpecified+1 < numRqd %+1 because first parameter is the metaInfo
                fprintf(['      PTR_Error: The the number of parameters specified in ' cfg.id ' (' int2str(numParamsSpecified) ') is fewer than the number required by ' cfg.script ' (' int2str(numRqd) '+)\n'])
                isValid=false;
            end
        else
            fprintf(['      PTR_Error: The the number of parameters specified in ' cfg.id ' (' int2str(numParamsSpecified) ') is greater than the number accepted by ' cfg.script ' (' int2str(numParamsAccepted) ')\n'])
            isValid=false;
        end
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