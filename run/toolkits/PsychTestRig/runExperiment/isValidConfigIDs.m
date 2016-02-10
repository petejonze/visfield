function isValid=isValidConfigIDs(expID, cfgIDs)
%ISVALIDCONFIGIDS description.
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
    p.addRequired('cfgID', @iscell);
    p.FunctionName = 'ISVALIDCONFIGIDS';
    p.parse(expID, cfgIDs); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    % Initialise local variables
    isValid=true;   
    
    
    % Run
    for i=1:length(cfgIDs)
        if ~isValidConfigID(expID,cfgIDs{i})
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

% % % % 
% % % %     
% % % %   %     cfgID=strcat(cfgID,{'.config.txt'}); %append file extention (in case user forgot to specifiy)
% % % % %     cfgID=regexprep(cfgID,'.config.txt.config.txt\>','.config.txt'); %remove file extention to strings that already had them  
% % % %     
% % % %     
% % % %     warning('wrote me!')
% % % %     isValid=true;
% % % %     
% % % %     
% % % %     
% % % % %checks configs are valid (& tweak if necessary)
% % % % configs=strcat(configs,{'.config.txt'}); %append file extention (in case user forgot to specifiy)
% % % % configs=regexprep(configs,'.config.txt.config.txt\>','.config.txt'); %remove file extentions to strings that already had them
% % % % possibleConfigs=dir([configDir filesep '*.config.txt']); %retrieve the available config files
% % % % 
% % % % check=ismember(configs,{possibleConfigs.name}); %check that all the specified configs exist
% % % % if (~all(check)) 
% % % % failures=configs(check==0);
% % % % error(['/*****The following config file(s) not found: ' strjoin(', ',failures{:}) ' (in: ' configDir ')*****/'])
% % % % end
% % % % c=configs;