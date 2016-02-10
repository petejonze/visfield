function calib=calib_combine(calib1,calib2,varargin)
%CALIB_COMBINE combines to calibrations.
%
%   the only difference the order makes is that the creation date will be
%   taken from the first specified calib (calib1)
%
% @Requires the following toolkits:
%               calibration [mine]
%   
% @Parameters:  
%
%       calib1          Struct or Char.     A calibration structure, as generated using
%                                           myCalibration2.m
%       calib2          Struct or Char.     A calibration structure, as generated using
%                                           myCalibration2.m
%       [newFileName]   Char.
%       [verbose]       Logical.           	If true then displays contents before and
%                                           after the merge (default=FALSE)
% 
% @Returns:  
%
%    	calib           Struct.             A calibration structure, as generated using
%                                           myCalibration2.m
%
%
% @Example:         mergedCalib=calib_combine(calib1,calib3b);
%                   myCalib=calib_combine('C:Calibrations/yesterday.mat','C:Calibrations/today.mat',true)
%
% @See also:        myCalibration2.m
%                   myPlotCalib.m
% 
% @Author:          Pete R Jones
%
% @Creation Date:	06/08/10
% @Last Update:     06/08/10
%
% @Todo:            Everything!
%



    % init
    if ischar(calib1)
        calib1=calib_load(calib1);
    end
    if ischar(calib2)
        % load & check same audio device
        calib2=calib_load(calib2,calib1.audioDevice.name,calib1.audioDevice.id);
    end
    if nargin > 2
        newFileName = varargin{1};
        if isempty(newFileName)
            fprintf('Empty filename detected.\nOutput calibration will not be saved\n');
        end
    end
    
    % check device name
    expectedDeviceName = strtrim(calib1.audioDevice.name); %trim to make sure no leading/trailing white spaces (Defensive)
    detectedDeviceName = strtrim(calib2.audioDevice.name);
    if ~strcmpi(expectedDeviceName,detectedDeviceName)
        error('loadCalibration:deviceNameMismatch','The specified audio device ("%s") does not match the name of the device in the second calibration file ("%s")',expectedDeviceName,detectedDeviceName);
    end
    % check device id
    expectedDeviceID = calib1.audioDevice.id;;
    detectedDeviceID = calib2.audioDevice.id;
    if expectedDeviceID ~= detectedDeviceID
        error('loadCalibration:deviceIDMismatch','The specified audio device ID (%i) does not match the ID of the device in the second calibration file (%i)',expectedDeviceID,detectedDeviceID);
    end

    
    %merge
    calib = calib1; %use calib1 as the base
    % get all the channels
    calib1_chanIndices = [calib1.channels(:).id];
    calib2_chanIndices = [calib2.channels(:).id];
    
    % any channels in calib2 that are complete new (i.e. arent in calib1 at
    % all) can be added directly
    newChanIndices = ~ismember(calib2_chanIndices,calib1_chanIndices);
    newChans = calib2.channels(newChanIndices);
    calib.channels = [calib.channels newChans];
    
    % the channels that are in both will have to be stepped through
    % and their frequency components combined individually
    sharedChanIndices = ismember(calib2_chanIndices,calib1_chanIndices);
    sharedChans = calib2.channels(sharedChanIndices);
    for i=1:length(sharedChans)
        calib2_channel = sharedChans(i);
        calib1_chanIndex = calib_getChanIndex(calib1,calib2_channel.id);
        calib1_channel = calib1.channels(calib1_chanIndex);
        
        % okay, now we have the 2 channels, lets do much the same thing,
        % going through and coparising frequencies. This step could be
        % obviated if we made all of this into one neat recursive
        % algorithm.
        % get
        calib1_freqs = [];
        try
            calib1_freqs = [calib1_channel.freqs(:).val];
        end
        calib2_freqs = [];
        try
        calib2_freqs = [calib2_channel.freqs(:).val];
        end
        % check
        if any(ismember(calib2_freqs,calib1_freqs))
            
            warning('mergeWarn:sharedFrequencies','These structures  both contain entries for the same frequencies in the same channel!') 
            if ~getLogicalInput('Continue? [Warning, this will cause any existing fits to be removed] [y/n] :')
                error('mergeWarn:quit','\n\nOperation terminated by user\nThankyou come again\n\n');
            end
        end
        % add
        for j=1:length(calib2_freqs)
           	% add to calib
            if isempty(fieldnames(calib1_channel.freqs))
                % if freq is empty then we just want to replace the empty
                % entry with the (potentially) non-empty entry
                calib.channels(calib1_chanIndex).freqs = calib2_channel.freqs(i);
            else
                % new merge feature (raw values only)
                freq = calib2_channel.freqs(i).val;
                if any(ismember(freq, calib1_freqs))
                    % get idx
                    calib1_freqIndex = find(freq==calib1_freqs);
                    % concatenate values
                    rms = [calib.channels(calib1_chanIndex).freqs(calib1_freqIndex).raw.rms calib2_channel.freqs(i).raw.rms];
                    db = [calib.channels(calib1_chanIndex).freqs(calib1_freqIndex).raw.db calib2_channel.freqs(i).raw.db];
                    % sort
                    [rms,idx]=sort(rms,'ascend');
                    db = db(idx);
                    % merge
                    calib.channels(calib1_chanIndex).freqs(calib1_freqIndex).raw.rms = rms;
                    calib.channels(calib1_chanIndex).freqs(calib1_freqIndex).raw.db = db;
                    % clear fit, since will no longer match raw data
                    calib.channels(calib1_chanIndex).freqs(calib1_freqIndex).fit = []
                    % print msg to user
                    fprintf('Channel %i Frequency %1.3f raw data have been merged. Any existing fit(s) have been cleared and will need to be reimplemented manually\n',calib1_channel.id,calib1_channel.freqs(i).val);
                else  
                    % else append new entry to the end of the existing ones
                    calib.channels(calib1_chanIndex).freqs(end+1) = calib2_channel.freqs(i);
                end
            end
        end
        
        % now we combine whitenoises
        calib1_whitenoise = calib1_channel.whitenoise;
        calib2_whitenoise = calib2_channel.whitenoise;
        % check
        if ~isempty(fieldnames(calib1_whitenoise)) && ~isempty(fieldnames(calib2_whitenoise)) %entries in both
            error('failedMerge:sharedFrequencies','Sorry, this script does not yet support merging structures that both contain white noise entries for the same channel!') 
        end
        % if it is calib2 that contains the non-empty var then add it, else
        % nothing needs doing
        if ~isempty(fieldnames(calib2_whitenoise))
            calib.channels(calib1_chanIndex).whitenoise = calib2_channel.whitenoise;  
        end 
    end
    
    % prepare to save file
    if ~exist('newFileName','var')
        newFileName = getStringInput('Enter file name : ',false);
        affix = ['_' regexprep(datestr(now(),20),'/','-')];
        fileNameAppended = [newFileName affix];
        appendDate = getLogicalInput(['Append today''s date? [' fileNameAppended ']  (y/n): ']);
        if appendDate
            newFileName = fileNameAppended;
        end
    end
    if ~isempty(newFileName)
        if length(newFileName) <= 4 || ~strcmpi(newFileName(end-3:end),'.mat')
            newFileName = [newFileName '.mat'];
        end
        % check doesn't already exist
        if exist(newFileName,'file')
            overwrite = getLogicalInput([newFileName ' already exists. Overwrite?  (y/n): ']);
            if ~overwrite
                ME = MException('myCalibration:InvalidInput', 'Specified output file already exists and overwrite==false');
                throw(ME);
            end
        end
    end
    
    % update meta info
    calib.metaInfo.SLM_settings = [calib.metaInfo.SLM_settings '; ' calib2.metaInfo.SLM_settings];
    calib.metaInfo.fileName = newFileName;
    calib.metaInfo.derivedFrom = [calib1.metaInfo.fileName '; ' calib2.metaInfo.fileName];
    calib.metaInfo.lastUpdate = datestr(now(),0);
    
    % save file
    if ~isempty(newFileName)
        save(newFileName,'calib');
    end
    
    % display if so requested
    if nargin>3 && varargin{2}
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
      	fprintf('%%%%%% 1. INPUT ONE\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n') 
        fprintf('\n\n');
        dispStruct4(calib1)
     	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
      	fprintf('%%%%%% 2. INPUT TWO\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n') 
        fprintf('\n\n');
        dispStruct4(calib2)
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
      	fprintf('%%%%%% 3. OUTPUT\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n') 
        fprintf('\n\n');
        dispStruct4(calib)
        calib_plot(calib,true,true,false)
    end
    
end