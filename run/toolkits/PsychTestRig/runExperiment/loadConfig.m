function [cfgData,ok]=loadConfig(configFileName,cfgDir)
%GETEXPCONFIGDATA shortdescr.
%
% Description
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('configFileName', @ischar);
    p.addRequired('cfgDir', @ischar); 
    p.FunctionName = 'GETEXPCONFIGDATA';
    p.parse(configFileName,cfgDir);
    %----------------------------------------------------------------------
   
    %check good to go
    %<blank>
    
    %initialise local variables
    ok = 1;
    cfgFile = [cfgDir filesep configFileName];
    
    %go!
    if ~exist(cfgDir,'dir') %check specified dir is visible
        cloutput(['    PTR_Error: Directory not found: ' cfgDir '\n']);
        ok=0; return
    end
    
    if ~exist(cfgFile,'file') %check specified file is visible
        cloutput(['    PTR_Error: File not found: ' cfgFile '\n']);
     	ok=0; return 
    end
    
    %load data
    cfgData=xmlRead(cfgFile);

    %check data ('sytax'/format)
    if ~isfield(cfgData,'script')
        fprintf(['      PTR_Error: No script file specified in ' configFileName '\n'])
        ok=0; %but carry on going 
    end

    if ~isfield(cfgData,'ptrVersion')
        fprintf(['      PTR_Error: No ptrVersion specified in ' configFileName '\n'])
        ok=0; %but carry on going 
    end
    
    if ~isfield(cfgData,'params')
        fprintf(['      PTR_Warning: No parameters specified in ' configFileName '  (no variables will be passed to the experiment script)\n'])
    end
    
    if ~isfield(cfgData,'randSeedState')
        fprintf(['      PTR_Warning: No random seed specified in ' configFileName '  (a seed will be generated at random, details of which will be saved in the output file)\n'])
    else
        fprintf('      PTR_Warning: Random seed %1.3f specified in %s. Will use this.\n',cfgData.randSeedState,configFileName)
    end
    
    %Strip out 'COMMENT' fields of any nodes
    cfgData = local_stripComments(cfgData);
    
    %check for chaff
    topLevelFields_actual = fieldnames(cfgData);
    checks=ismember(topLevelFields_actual,{'script','ptrVersion','params','randSeedState'}); %flag up unrecognised (top level) fields
    unecessaryItems=topLevelFields_actual(~checks);
    if ~isempty(unecessaryItems)
        fprintf(['      PTR_Warning: The following fields in ' configFileName ' are not recognised as valid fields and will be ignored:\n'])
        for i=1:length(unecessaryItems)
            fprintf(['          |- ' '''' unecessaryItems{i} '''' '\n'])
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

function myStruct=local_stripComments(myStruct)
    %dispStruct(myStruct)
    if isfield(myStruct,'COMMENT')
        myStruct = rmfield(myStruct,'COMMENT');
    end 
    fns = fieldnames(myStruct); %recursion
    for i=1:length(fns)
        val = myStruct.(fns{i});
        if isstruct(val)
            if size(val) ~= [1 1]
                val = local_stripComments(val);
            else
                %warning('x:y','Comment stripping for multidimensional config structures is not yet supported')
            end
        end
     	myStruct.(fns{i}) = val;
    end
end