function isValid=isValidConfigID(expID, cfgID)
%ISVALIDCONFIGID description.
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
    p.addRequired('expID', @ischar);
    p.addRequired('cfgID', @ischar);
    p.FunctionName = 'ISVALIDCONFIGID';
    p.parse(expID, cfgID); % Parse & validate all input args
    %----------------------------------------------------------------------
   

    % Initialise local variables
    expDir=[getPrefVal('homeDir') filesep expID];
    cfgID=[cfgID '.expConfig.xml']; %append file extention (in case user forgot to specifiy)
    cfgID=regexprep(cfgID,'.expConfig.xml.expConfig.xml\>','.expConfig.xml'); %remove file extention strings if already had it
    cfgID=regexprep(cfgID,'.expConfig.expConfig.xml\>','.expConfig.xml'); % now '.expConfig' is also optional
    cfgID=[expDir filesep 'run' filesep 'configs' filesep cfgID];
    
    % Check that config file is present in experiment directory
  	if ~exist(cfgID,'file')
        msg=escape(['Config file not found: ' cfgID]);
        warning('PsychTestRig:invalidCfgID',msg);
        isValid = false;
    else
        isValid=true;
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