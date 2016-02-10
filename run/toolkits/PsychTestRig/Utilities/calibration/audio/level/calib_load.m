function calib=calib_load(calib,varargin)
%CALIB_LOAD attempts to load a calibration file & performs validation    
%
%  	Loads in a calibration and performs validations contingent on user
%  	input. Validation errors will result in an error being thrown.
%
%   A calib is just a structure, saved using matlab's save() command. As
%  	such it could be loaded using load(), just as you would any other saved
%  	variable. The reason for using this wrapper is simple that it performs
%  	validations.
%
%   If the calib specified is a structure rather than a file then the
%   loading will not occur, but the validation will still proceed. An
%   alterantive use of this function is therefore to check specified values
%   against an already loaded calibration.
%
% @Parameters:             
%
%     	calib       Struct/Char    	Either calib structure or name of file to load (including relative or absolute path if not in current directory)
%                                e.g. './calibrations/calib-1234.mat'
%     	[devName]	Char        Expected device name
%                                e.g. 'C-Media USB Headphone Set'
%     	[devID]   	Int         Expected device ID
%                                e.g. 1
%     	[headID]   	Char        Expected headphone ID
%                                e.g. 'Sen-ME4'
%     	[outChan]	[Int]   	#####
%                                e.g.
%     	[isWNoise]	Logical   	#####
%                                e.g.
%     	[freqs]     [Real]   	#####
%                                e.g.
%     	[tolerance]	Real        #####
%                                e.g.
% @Returns:  
%
%    	calib       Struct      A calibration structure
%
%
% @Usage:           [calib]=calib_load(file,[devName],[devID],[headID],[outChan],[isWNoise],[freqs],[tolerance])   
% @Example:         deviceName = 'C-Media USB Headphone Set';
%                   calib=calib_load('new_right_pure_06-08-10.mat',deviceName);
%
% @Requires:        get1ofMInput
%   
% @See also:        #####
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	05/07/10
% @Last Update:     26/07/10
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	26/07/10    Initial build.
%                   v1.0.1	20/01/11    ######
%
% @Todo:            Lots!
%
%                	tolerance - may want to change this from hertz to %hertz
%               	change from matching exact frequencies to matching within a given
%                	tolerance - this will require a parallel update to the getRMS script to
%                   allow for nearest frequency responses


    % 1. load in data
    if isempty(calib)
        error('calib_load:load_error','No calib file specified.')
    end
    if ischar(calib)
        if ~exist(calib,'file')
            error('calib_load:load_error','The specified calibration file does not exist')
        end
        try 
            tmp = load(calib); %TMP HACK UNTIL I THINK OF A BETTER WAY
        catch ME    %#ok
            error('calib_load:load_error','The specified calibration file could not be loaded')
        end
        try 
            calib = tmp.calib;  
        catch ME 	%#ok
            error('calib_load:load_error','The specified calibration file does not appear to contain a valid Matlab data Structure')
        end
    end

    % 2. Evaluate data
    % check device name (if one specified)
    if nargin>1 && ~isempty(varargin{1})
        expectedDeviceName = strtrim(varargin{1}); %trim to make sure no leading/trailing white spaces (Defensive)
        detectedDeviceName = strtrim(calib.audioDevice.name);
      	if ~strcmpi(expectedDeviceName,detectedDeviceName) 
            error('loadCalibration:deviceNameMismatch','The specified audio device ("%s") does not match the name of the device in the calibration file ("%s")',expectedDeviceName,detectedDeviceName);
        end
    end
    % check device ID (if one specified)
    if nargin>2 && ~isempty(varargin{2})
        expectedDeviceID = varargin{2};
        detectedDeviceID = calib.audioDevice.id;
      	if expectedDeviceID ~= detectedDeviceID
            error('loadCalibration:deviceIDMismatch','The specified audio device ID (%i) does not match the ID of the device in the calibration file (%i)',expectedDeviceID,detectedDeviceID);
        end
    end    
	% check headphone ID (if one specified)
    if nargin>3 && ~isempty(varargin{3})
        expectedHeadphoneID = varargin{3};
        detectedHeadphoneID = calib.headphone.id;
      	if ~strcmpi(expectedHeadphoneID, detectedHeadphoneID)
            error('loadCalibration:headphoneIDMismatch','The specified headphone ID (%s) does not match the ID in the calibration file (%s)',expectedHeadphoneID,detectedHeadphoneID);
        end
    end   
    
    % check output channel(s) exist (if one or more specified)
    expectedOutputChannels = []; %#ok
    if nargin>4 && ~isempty(varargin{4})
        expectedOutputChannels = varargin{4};
        for i=1:length(expectedOutputChannels)
            chan = expectedOutputChannels(i);
            chanIndex = calib_getChanIndex(calib,chan);
            if isempty(chanIndex)
                error('loadCalibration:channelNotFound','The specified channel (%i) was not found in the calibration file',chan);
            end
        end
        % check white noise calibration exists for each channel (if so
        % specified)
        if nargin>5 && ~isempty(varargin{5}) && logical(varargin{5}) %hasWhiteNoise
            for i=1:length(expectedOutputChannels)
                chan = expectedOutputChannels(i);
                chanIndex = calib_getChanIndex(calib,chan);
                if isempty(fieldnames(calib.channels(chanIndex).whitenoise))
                    warning('loadCalibration:noiseCalibNotFound','Whitenoise calibration not found for channel %i',chan);
                    fprintf('Whitenoise calibration not found for channel %i\n',chan);
                    usrResp = get1ofMInput('Continue anyway? no(n), yes(y), yes all(a)? : ',{'n','y','a'});
                    if strcmp(usrResp,'n')
                        error('loadCalibration:terminatedByUser','Calibration failed to load.');
                    elseif strcmp(usrResp,'a')
                        break; %break out of for loop
                    end % else carry on to next
                end
            end
        end
        % check puretone calibration exists for each channel (if so
        % specified)
        if nargin>6 % freqs
            perc_tolerance = 0;
            if nargin>7 && ~isempty(varargin{7})
                perc_tolerance = varargin{7};
            end
            freqs = varargin{6};
            for i=1:length(expectedOutputChannels)
                chan = expectedOutputChannels(i);
                chanIndex = calib_getChanIndex(calib,chan);
                for j=1:length(freqs)
                    freq = freqs(j);
                    [freqIndex, nearestVal] = calib_getFreqIndex(calib,chanIndex,freq,perc_tolerance);
                    if isempty(freqIndex)
                        warning('loadCalibration:freqCalibNotFound','Freq==%1.2f+/-%1.2f calibration not found for channel %i  (nearest value==%1.2f)',freqs(j),freqs(j).*perc_tolerance,chan,nearestVal);
                        fprintf('Freq==%1.2f+/-%1.2f calibration not found for channel %i  (nearest value==%1.2f)\n',freqs(j),freqs(j).*perc_tolerance,chan,nearestVal);
                        usrResp = get1ofMInput('Continue anyway? no(n), yes(y), yes all(a)? : ',{'n','y','a'});
                        if strcmp(usrResp,'n')
                            error('loadCalibration:terminatedByUser','Calibration failed to load.');
                        elseif strcmp(usrResp,'a')
                            break; %break out of for loop
                        end % else carry on to next
                    end
                end %end freqs
            end %end channel
        end
    else
        if (nargin>5 && ~isempty(varargin{5})) || (nargin>6 && ~isempty(varargin{6})) % freqs
            warning('loadCalibration:noChannelSpecified','No channel specified. Specific calibrations cannot be checked.');
            if ~getLogicalInput('Continue anyway? no(n), yes(y)? : ')
                error('loadCalibration:terminatedByUser','Calibration failed to load.');
            end % else continue
        end
    end

end