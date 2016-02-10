function filePath=exportSetup()
%EXPORTSETUP shortdescr.
%
% Description
%
% Example: none  - type(exportSetup) %ouput contents of file to console
%
% See also importSetup, checkSetup
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %Check that we have a full config to export
    ensurePsychTestRigSetup();
    
    %construct filename
    fileName = 'config.xml';
    
    %get output dir
    outputDir = uigetdir(cd,'Output Dir');
    if (~outputDir)
        error('Script terminated'); %ALT: return; %quit
    end
    filePath = [outputDir filesep fileName];
    
    %check for existing file, confirm overwrite if necessary
    if exist(filePath,'file')
        if ~getBooleanInput(['File "' fileName '" already exists. Overwrite? (y/n) '])
            error('Script terminated');
        end
    end
    
    %ouput configurable preferences to xml
    xml_write(filePath, getpref('PsychTestRig_prefs'));
    
end