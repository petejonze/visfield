function importSetup(varargin)
%IMPORTSETUP shortdescr.
%
% Description
%
% Example: none
%
% See also exportSetup, checkSetup
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addOptional('configFileName', '', @(x)exist(x,'file')>0 ); %check any specified file is visible
    p.FunctionName = 'IMPORTSETUP';
    p.parse(varargin{:});
    configFileName = p.Results.configFileName;
    %----------------------------------------------------------------------
    
    %get import file (if none specified)
    if isempty(configFileName)
        [fileName, filePath] = uigetfile('*.xml', 'Pick an xml config file');
        configFileName = [filePath fileName];
    end
    
    %load data
    cfgData=xml_read_compatabilityVersion(configFileName);

    %check data
    cloutput('\nChecking new setup info...')
    if ~checkSetup(cfgData,'indent',4)
        error('Setup info invalid. See above for breakdown details.')
    end
    cloutput('...success!\n')
    
    %remove any unnecessary fields ('chaf') from the input file 
    cfgData = pruneCfgData(cfgData);
    
    %add blank stubs for any optional fields that are missing
    cfgData = mergeStructs(cfgData,getBlankSetup());
    
    %clear any existing setup. Prompt for confirmation if necessary 
    clearSetup();

    %set data
    setPrefVals(fieldnames(cfgData),struct2cell(cfgData));

    %ouput new config details
    cloutput('Setup complete!\nType "PsychTestRig -viewSetup" to view the new setup configuration.')

%     %Check that we are good to go
%     ensurePsychTestRigSetup();
%     
%     %construct filename
%     fileName = 'config.xml';
%     
%     %get output dir
%     outputDir = uigetdir(cd,'Output Dir');
%     filePath = [outputDir filesep fileName];
%     
%     if exist(filePath,'file')
%         if ~getBooleanInput(['File "' fileName '" already exists. Overwrite? (y/n) '])
%             error('Script terminated');
%         end
%     end
%     
%     %ouput configurable preferences to xml
%     xml_write(filePath, getpref('PsychTestRig_prefs'));
%   
%     %ouput contents of file to console
%     type(filePath)
    
end