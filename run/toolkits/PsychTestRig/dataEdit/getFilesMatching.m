function [fullFilePaths]=getFilesMatching(expID,varargin)
%EXTRACTDATA short desc.
%
% Description.
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         getFilesMatching('exp1ver8','partID',{'12','13'},'blockNum',{'1','2'},'sortOrder','ascend')
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	01/04/10
% @Last Update:     01/04/10
%
% @Todo:            <blank>


    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addParamValue('partID', [], @(x)ischar(x) || iscellstr(x));
    p.addParamValue('sessID', '.+', @(x)ischar(x) || iscellstr(x));
    p.addParamValue('blockNum', '.+', @(x)ischar(x) || iscellstr(x));
    p.addParamValue('sortBy', 'date', @(x)any(strcmp(x,{'date','name'})));
    p.addParamValue('sortOrder', 'ascend', @(x)any(strcmp(x,{'ascend','descend'})));
    p.FunctionName = 'EXTRACTDATA';
    p.parse(expID,varargin{:}); % Parse & validate all input args
    %----------------------------------------------------------------------
    partIDs=p.Results.partID;
    if ischar(partIDs); partIDs={partIDs}; end
    
    sessID=p.Results.sessID;
    if iscellstr(sessID); sessID=strjoin('|',sessID{:}); end
    
    blockNum=p.Results.blockNum;
    if iscellstr(blockNum); blockNum=strjoin('|',blockNum{:}); end
    
    sortBy=p.Results.sortBy;
    sortOrder=p.Results.sortOrder;
    %----------------------------------------------------------------------
    
    %%%%%%%%%
    %%% 0 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % initialise local variables 
	homeDir=getPrefVal('homeDir');
    expHomeDir=[homeDir filesep expID];
    dataDir=[expHomeDir filesep 'data'];
    partDataDirs=getDirs(dataDir,true);
    fullFilePaths = {};
    
    % check that good to go
    if isempty(partIDs{1})
        %get all participant data dirs
        validIndex=regexp(partDataDirs,'^\d+$','once');
        validIndex=~cellfun(@isempty,validIndex);
        partIDs = partDataDirs(validIndex==1);
        if isempty(partIDs)
            error('getFilesMatching:intialisation:noPartDataDirs',['No participant data directories specified, and none found in "' escape(dataDir) '"'])  
        end
    else
        %check that specified participant data subdirectory(s) exist
        dirsMissing = false;
        for i=1:length(partIDs)
            partID = partIDs{i};
            if (~ismember(partID,partDataDirs)) 
                dirsMissing = true;
                warning('getFilesMatching:intialisation:cannotFindPartDataDir',['No data directory found for participant "' partID '" in "' escape(dataDir) '"'])        
            end
        end
        if dirsMissing
            error('getFilesMatching:intialisation:mssingPartDataDirs','Not all specified participant data directories could be located. See above for details.')  
        end
    end
    

  	%%%%%%%%%
    %%% 1 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Run %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % get file names
	for i=1:length(partIDs)
            
        partID = partIDs{i};
        partDataDir = [dataDir filesep partID];

        % Get list of file to extract data from
        filePattern = [partDataDir filesep expID '-' partID '*.csv'];
        fileList = dir(filePattern);
        fileList = fileList(not([fileList.isdir])); %weed out any oddly named directories that might have crept in

        
        % Sort list
        if strcmp(sortBy,'date')
            [fileIndex,fileIndex] = sort([fileList.datenum],sortOrder);
        elseif strcmp(sortBy,'name')
            [fileIndex,fileIndex] = sort_nat({fileList.name},sortOrder);
        else
            error('getFilesMatching:fileSort:unrecognisedSortType',['Sort option "' sortBy '" not recognised. Valid parameters are: "ascend", "descend"'])  
        end
        
        
        % Filter
        numOfFiles = length(fileList);
        pattern = [expID '-' partID '-(' sessID ')-(' blockNum ')-.+\.csv'];
        for x=1:numOfFiles
            fn = fileList(fileIndex(x)).name;
            if regexp(fn,pattern);
                fullFn = [partDataDir filesep fn];
                fullFilePaths{end+1} = fullFn;
            end
        end
        
	end
        
end