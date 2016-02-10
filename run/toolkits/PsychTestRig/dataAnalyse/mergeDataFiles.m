function [outputFile]=mergeDataFiles(inputFiles,outputDir,outputFileName)
%MERGEDATAFILES short desc.
%
% Description.
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	07/06/10
% @Last Update:     07/06/10
%
% @Todo:            <blank>


    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('inputFiles', @iscellstr);
    p.addRequired('outputDir', @ischar);
    p.addRequired('outputFileName', @ischar);
    p.FunctionName = 'MERGEDATAFILES';
    p.parse(inputFiles,outputDir,outputFileName); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    %----------------------------------------------------------------------
    
    %%%%%%%%%
    %%% 0 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % check all the specified input files exist
    if ~all(cellfun(@(x)exist(x,'file'),inputFiles))
        invalidFilesIndex = cellfun(@(x)exist(x,'file')==0,inputFiles);
        invalidFiles = inputFiles(invalidFilesIndex);
        error('mergeDataFiles:invalidInputFiles',['The following input file(s) could not be found: ' escape(strjoin(', ',invalidFiles{:}))])
    end
    
    % check that the specified output dir exists
    if ~exist(outputDir,'dir')
        error('mergeDataFiles:mergeDataFiles',['The specified output directory could not be found: "' escape(outputDir)])
    end
    
    %%%%%%%%%
    %%% 1 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Load in all the data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    
    % Initialise local variables
    nDataFiles = length(inputFiles);
    
    DataSets = cell(1,nDataFiles);
    for i=1:nDataFiles
        data = csv2struct(inputFiles{i});
        DataSets{i} = data;
    end
        
    %%%%%%%%%
    %%% 2 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Merge data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    
    mergedDataSet = catStructs(DataSets);
    
    
    %%%%%%%%%
    %%% 3 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% convert to cell %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    
    
    % convert to cell
    data=struct2cell(mergedDataSet);
    dataCell = cat(1,data{:})';
    
    % append headers
    headers = fieldnames(mergedDataSet);
    dataCell = cat(1,headers',dataCell);

    nRowsOfData = size(dataCell,1); %including header

    nHeaders = length(headers);
    
    
    %%%%%%%%%
    %%% 4 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Output merged data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    
    % construct new file name
    fullFn = fullfile(outputDir,outputFileName);
    
    % create file
    outputFile=mkfile(fullFn);
    
    % output the data to the file
    newline=getNewline();
    try
        fid = fopen(outputFile,'w+');
        for i=1:nRowsOfData
            outputLine = strjoin(',',dataCell{i,:});
            fprintf(fid, '%s', outputLine);
            fwrite(fid, newline, 'char'); % terminate this line
        end
        fclose(fid);
    catch
        ME=lasterror;
        fclose(fid);
        delete(fullFn); %clean up
        myErr=  [   '/*****Failed to create new data file.*****/\n\n' ...
                    '   The following error message was produced:\n' ...
                    '      ' escape(ME.message) '\n\n' ...
                    '   It originated from:\n' ...
                    ['      ' regexprep(strtrim(escape(struct2String(ME.stack))),'\\\\n','\\n  ') '\n'] ... %regexprep to unescape any newline characters returned from struct2String
                    'Any traces of the data file were deleted\n' ...
                    '*****/' ...
                ];   
        error('extractData:outputDataToFile:FatalFail',myErr); %'rethrow-plus-some'      
    end
    

    %%%%%%%%%
    %%% 5 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Finish up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    disp(['Outputted ' num2str(nHeaders) ' fields for ' num2str(nRowsOfData-1) ' rows of data'])
    
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    
    %<none>
    
end
%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%

%<none>