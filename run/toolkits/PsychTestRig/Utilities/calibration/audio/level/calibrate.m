function [fileName, calib]=calibrate(createNew,fileName,channels,useWhiteNoise,lowestNoiseFreq,highestNoiseFreq,usePureTones,freqs,nSamples,logSpaceAMP,minAMP,maxAMP,slmParams,deviceID,deviceName,deviceNOutputs,headphoneID)
% to add: display channels when listing hardware
% check that specified channels are valid
% play through one channel by buffering with zeros, not by only selecting
% that channel (which will only work with ASIO devices)
% make rms spacing type and bounds optional - cf.  ampVals = exp(linspace(log(0.0001),log(1),nSamples)); %get amp values
%
% nChannels in sub_init is dodgy
%
% calibrate(true,'pci24_test1_07-04-11.mat',[0   1   2   3   4   5   6   7
% 8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23],false,[],[],true,[1000],3,true,.3,.8,'lls(inst)',63,'MOTU PCI ASIO',24,'speakers')
%
% 07/04/2011 : corrections (e.g. ampVals)

    Fs = 44100;

    %%%%%%%
    %% 0 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% HARDWARE START %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        calib = struct();
        
    %%%%%%%
    %% 1 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% GET USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        clc; %clear the console
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
      	fprintf('%%%%%% 1. Initial setup\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n') 
        fprintf('\n\n');
        
        
        % 1
        if nargin<1 || isempty(createNew)
            resp = get1ofMInput('\nCreate new (n) or Modify existing (m) calibration file?  ',{'n','m'});
            createNew = strcmpi(resp,'n');
        end
        if ~islogical(createNew)
            ME = MException('myCalibration:InvalidInput', '"createNew" must be of type logical');
            throw(ME);
        end
        % 2
        if nargin<2 || isempty(fileName)
            if createNew
                fileName = getStringInput('Enter file name : ',false);
                affix = ['_' regexprep(datestr(now(),20),'/','-')];
                fileNameAppended = [fileName affix];
                appendDate = getLogicalInput(['Append today''s date? [' fileNameAppended ']  (y/n): ']);
                if appendDate
                    fileName = fileNameAppended;
                end
                calib = struct();
            else
                disp('select the file...');
                [fileName pathname] = uigetfile();
                fileName = fullfile(pathname,fileName);
            end
        end
        % add file extension if not there already
        if length(fileName) <= 4 || ~strcmpi(fileName(end-3:end),'.mat')
            fileName = [fileName '.mat'];
        end
        if createNew
            % check doesn't already exist
            if exist(fileName,'file')
                overwrite = getLogicalInput([fileName ' already exists. Overwrite?  (y/n): ']);
                if ~overwrite
                    ME = MException('myCalibration:InvalidInput', 'Specified output file already exists and overwrite==false');
                    throw(ME);
                end
            end
            % init
            calib.channels.freqs = struct();
            calib.channels.whitenoise = struct();
            calib.audioDevice = struct();
            calib.metaInfo.created = datestr(now(),0);
            % create
            %mkfile(fileName);
            save(fileName,'calib');
            disp(['file successfully created: ' fileName]);
        else
            calib = calib_load(fileName);
        	dispStruct4(calib)   
        end
        if ~exist(fileName,'file')
            ME = MException('myCalibration:InvalidInput', ['file "' fileName '" could not be located']);
            throw(ME);
        end
        % 3
        if nargin<3 || isempty(channels)
            channelstr = getStringInput('\nEnter channel indices (normally 0=left, 1=right).\nIf using multiple values separate using commas : ',false);
            channels = str2num(channelstr);
        end
        if ~all(mod(channels,1)==0)
            ME = MException('myCalibration:InvalidInput', '"channels" must be of type: integer');
            throw(ME);
        end
        % 4
        
        if nargin<4 || isempty(useWhiteNoise)
            useWhiteNoise = getLogicalInput('\nPerform white noise calibration? (y/n): ');
        end
        if ~islogical(useWhiteNoise)
            ME = MException('myCalibration:InvalidInput', '"useWhiteNoise" must be of type: logical');
            throw(ME);
        end
     	if useWhiteNoise
            % 5
            if nargin<5 || isempty(lowestNoiseFreq)
                lowestNoiseFreq = getIntegerInput('\nlowest frequency component to use? (blank for 0) : ',true);
            end
            if isempty(lowestNoiseFreq)
                lowestNoiseFreq = 0;
            end
            if ~(lowestNoiseFreq>=0 && mod(lowestNoiseFreq,1)==0)
                ME = MException('myCalibration:InvalidInput', '"lowestNoiseFreq" must be of type: integer');
                throw(ME);
            end
            % 6
            if nargin<6 || isempty(highestNoiseFreq)
                highestNoiseFreq = getIntegerInput(sprintf('\nhighest frequency component to use? (blank for %i) : ',Fs/2),true);
            end
            if isempty(highestNoiseFreq)
                highestNoiseFreq = Fs/2;
            end
            if ~(highestNoiseFreq>=0 && mod(highestNoiseFreq,1)==0)
                ME = MException('myCalibration:InvalidInput', '"highestNoiseFreq" must be of type: integer');
                throw(ME);
            end
        else
            lowestNoiseFreq = [];
            highestNoiseFreq = [];
        end
      	% 7
        if nargin<7 || isempty(usePureTones)
            usePureTones = getLogicalInput('\nPerform pure tone calibration? (y/n): ');
        end
        if ~islogical(usePureTones)
            ME = MException('myCalibration:InvalidInput', '"usePureTones" must be of type: logical');
            throw(ME);
        end
        % 8
        if usePureTones
            if nargin<8 || isempty(freqs)
                freqstr = getStringInput('\nEnter frequencies. If using multiple values separate using commas : ',false);
                freqs = str2num(freqstr);
            end
            if ~isnumeric(freqs)
                ME = MException('myCalibration:InvalidInput', '"freqs" must be of type: real');
                throw(ME);
            end
        else
            if nargin>8 && ~isempty(freqs)
                warning('myCalibration:IgnoredInput','Specified frequencies ignored since use of pure tones set to false');
            end
            freqs = [];
        end
        % 9
        if nargin<9 || isempty(nSamples)
            nSamples = getRealInput('\nNumber of samples (rms values) to test?\n[Alt: exact amplitudes to test, separated by commas]: ',false);
        end
        if length(nSamples)==1 && all(mod(nSamples,1)==0) % assume a number of samples
            if ~(nSamples>0 && mod(nSamples,1)==0)
                ME = MException('myCalibration:InvalidInput', '"nSamples" must be of type: positive integer');
                throw(ME);
            end
            
            % All of the following are moot if ampVals already specified
            % we won't bother querying the user about these, but the settings
            % are there is anybody wants to change them on the command line
            % 10
            if nargin<10 || isempty(logSpaceAMP)
                logSpaceAMP = true; %default
            else
                logSpaceAMP = logical(logSpaceAMP);
            end
            % 11
            if nargin<11 || isempty(minAMP)
                minAMP = 0.0001; %default
            else % validate
                if ~isnumeric(minAMP) || length(minAMP) ~= 1
                    ME = MException('myCalibration:InvalidInput', '"minAMP" must be of type: numeric scalar');
                    throw(ME);
                end
            end
            % 12
            if nargin<12 || isempty(maxAMP)
                maxAMP = 1; %default
            else % validate
                if ~isnumeric(maxAMP) || length(maxAMP) ~= 1
                    ME = MException('myCalibration:InvalidInput', '"maxAMP" must be of type: numeric scalar');
                    throw(ME);
                end
            end
            ampVals = [];
        else % if multiple values given then assume that the user wants to test these exact values
            ampVals = nSamples;
            logSpaceAMP = [];
            minAMP = [];
            maxAMP = [];
        end
        
        
        % 13
        if nargin<13 || isempty(slmParams)
            slmParams = getStringInput('\nSLM params? [e.g. "las (SPL)"] : ',false);
        end
        if ~ischar(slmParams)
            ME = MException('myCalibration:InvalidInput', '"slmParams" must be of type: String');
            throw(ME);
        end
        calib.metaInfo.SLM_settings = slmParams;

        
        % check for overwrites
        if ~createNew
            for i=1:length(channels);
                channel = channels(i);
                try %field won't exist in empty calibrations
                    ids = [calib.channels(:).id];
                    if any(ids==channel) % if data already stored for this channel
                        channelIndex = find(ids==channel);
                        
                        if useWhiteNoise
                            try
                                db = calib.channels(channelIndex).whitenoise.raw.db;
                            	if ~isempty(db) % if stored data includes measurement(s)
                                    getStringInput(sprintf('\n******WARNING******\nThe loaded calibration file already contains "channel %i" entries for white noise\n!!!If you continue these results will be overwritten!!!\n\nPress enter if you wish to continue. Press ctrl+c to abort.',channel,num2str(invalidFreqs)),true);
                                end
                            catch %#ok
                                % empty structure, fine
                            end
                        end
                        if usePureTones
                            storedfreqs = [calib.channels(channelIndex).freqs(:).val];
                            invalidFreqs = freqs(ismember(storedfreqs,freqs));
                            if ~isempty(invalidFreqs) % if stored data includes a specified measurement frequency
                                getStringInput(sprintf('\n******WARNING******\nThe loaded calibration file already contains "channel %i" entries for the following frequencies:\n    [%s]\n!!!If you continue these results will be overwritten!!!\n\nPress enter if you wish to continue. Press ctrl+c to abort.',channel,num2str(invalidFreqs)),true);
                            end
                        end   
                    end
                catch %#ok
                    % empty structure, fine
                end
            end
        end


        % set meta info
        calib.metaInfo.fileName = fileName;
        calib.metaInfo.lastUpdate = datestr(now(),0);
        calib.metaInfo.derivedFrom = 'n/a'; %for completeness, this becomes important when combining calibrations together
        
 	%%%%%%%
    %% 2 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% INITIALISE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('\n\n\n');
      	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
      	fprintf('%%%%%% 2a. Initialising Audio Hardware (1/2)\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n') 
        fprintf('\n\n');    
        
        %% INIT 1
        %check that Psychtoolbox is good to go
        AssertOpenGL % Make sure the script is running on Psychtoolbox-3
        %prep Psychtoolbox-3 for go
        InitializePsychSound(1) % Initialize driver, request low-latency preinit:
        PsychPortAudio('Verbosity', 10);
        Screen('Preference', 'SkipSyncTests', 1);

        % Enable unified mode of KbName, so KbName accepts identical key names on
        % all operating systems (not absolutely necessary, but good practice):
        KbName('UnifyKeyNames');
        
            
        fprintf('\n\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        fprintf('%%%%%% 2b. Select Audio Device\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        fprintf('\n');

        % GET/SHOW AUDIO DEVICES
        devices = PsychPortAudio('GetDevices');
        nDevices = length(devices);
        deviceIDs=[devices.DeviceIndex];
        deviceNames={devices.DeviceName};
        fprintf('\nAudio devices detected:\n\n');
        for i=1:nDevices;
            fprintf('       [%i]   %s  [%i out]\n', devices(i).DeviceIndex, devices(i).DeviceName, devices(i).NrOutputChannels);
        end
        
        
        
        
        if ~isfield(calib,'audioDevice') || ~isfield(calib.audioDevice,'id')
            calib.audioDevice.id = [];
        end
            
        % Check for prespecified values
        if nargin<14 || isempty(deviceID)
            %do nothing, proceed to manual setting
        else % deviceID was specified, check that it matches the current value (if one exists)
            calibDeviceID = calib.audioDevice.id;
            if ~isempty(calibDeviceID) && (calibDeviceID ~= deviceID)
                calib.audioDevice.id = [];
                ME = MException('myCalibration:InvalidInput', sprintf('specified device id [%i] does not match the device already listed in the calibration [%i]',deviceID,calibDeviceID));
                throw(ME);
            else
                % check that is valid & set
                if deviceID < 0 || deviceID >= nDevices
                    warning('myCalibration:InvalidInput','There was a problem setting the specified device ID [%i], proceeding manually..',deviceID);
                    calib.audioDevice.id = []; %probably not strictly necessary
                else
                    calib.audioDevice.id = deviceID;
                end
            end
        end

        % check device name
        if ~isempty(calib.audioDevice.id)
            try; calibDeviceName = calib.audioDevice.name; catch; calibDeviceName = []; end; %check for extant value

            if nargin<15 || isempty(deviceName)
                % if nothing specified and nothing found then will need to
                % set a value
                if isempty(calibDeviceName)
                    detectedName = devices(calib.audioDevice.id+1).DeviceName;
                    if ~getLogicalInput(sprintf('\nNo device name specified and none detected\nWould you like to use the detected value of: [%s]\n(y/n)?  ',detectedName));
                        calib.audioDevice.id = []; %clear to force manual entry
                    else
                        calib.audioDevice.name = detectedName;
                    end
                end
            else % deviceName was specified
                % check that it matches the current value (if one exists)
                if ~isempty(calibDeviceName) && (calibDeviceName ~= deviceName)
                    warning('myCalibration:InvalidInput', sprintf('specified device name [%s] does not match the device already listed in the calibration [%s]\nProceeding to manual input..\n',deviceName,calibDeviceName));
                    calib.audioDevice.id = []; %clear to force manual entry
                else
                   calib.audioDevice.name = deviceName; %ok, set 
                end
            end
        end

     	% check device nOutputs
        if ~isempty(calib.audioDevice.id)
            try; calibDeviceNOutputs = calib.audioDevice.nOutputChannels; catch; calibDeviceNOutputs = []; end; %check for extant value

            if nargin<16 || isempty(deviceNOutputs)
                % if nothing specified and nothing found then will need to
                % set a value
                if isempty(calibDeviceNOutputs)
                    detectedNOutputs = devices(calib.audioDevice.id+1).NrOutputChannels;
                    if ~getLogicalInput(sprintf('\nNo device nOutputs specified and none detected\nWould you like to use the detected value of: [%i]\n(y/n)?  ',detectedNOutputs) );
                        calib.audioDevice.id = []; %clear to force manual entry
                    else
                        calib.audioDevice.nOutputChannels = detectedNOutputs;
                    end
                end
            else % deviceNOutputs was specified
                % check that it matches the current value (if one exists)
                if ~isempty(calibDeviceName) && (calibDeviceName ~= deviceName)
                    warning('myCalibration:InvalidInput', sprintf('specified device nOutputs [%i] does not match the device already listed in the calibration [%i]\nProceeding to manual input..\n',deviceNOutputs,calibDeviceNOutputs));
                    calib.audioDevice.id = []; %clear to force manual entry
                else
                   calib.audioDevice.nOutputChannels = deviceNOutputs; %ok, set 
                end
            end
        end



            
            
        if isempty(calib.audioDevice.id)
            while (1)
                deviceID = getIntegerInput('\nIndex number for audio device? : ',false);
                if deviceID < 0 || deviceID >= nDevices
                    fprintf('Invalid device id. Must be between %i - %i',0,nDevices-1);
                else
                    deviceName = devices(deviceID+1).DeviceName;
                    NrOutputChannels = devices(deviceID+1).NrOutputChannels;
                    if NrOutputChannels < 1
                        fprintf('Specified device ("%s") has no detectable output channels.',deviceName);
                    else
                        break;
                    end
                end
            end
            calib.audioDevice.id = deviceID;
            calib.audioDevice.name = strtrim(deviceName); %trim to make sure no leading/trailing white spaces
            calib.audioDevice.nOutputChannels = NrOutputChannels;
        else
            fprintf('\nSpecified device:\n\n');
            fprintf('       [%i]   %s  [%i out]\n\n', calib.audioDevice.id, calib.audioDevice.name,calib.audioDevice.nOutputChannels);
            %             correct = getBooleanInput('Confirm correct (y/n) :');
            %             if ~correct
            %                 ME = MException('myCalibration:InvalidInput', 'file content error.\nPlease select a new calibration file or start from scratch.');
            %             throw(ME);
            %             end
            getStringInput('Press ENTER if correct (ctrl+c otherwise)',true);
        end

            
           
            
	

        if ~any(deviceIDs == calib.audioDevice.id)
            ME = MException('myCalibration:InvalidInput', sprintf('specified device id [%i] not found',calib.audioDevice.id));
            throw(ME);
        elseif ~strcmp(calib.audioDevice.name,strtrim(deviceNames{calib.audioDevice.id+1}))
            ME = MException('myCalibration:InvalidInput', sprintf('Specified device name ("%s") does not match the name detected for device %i ("%s").',calib.audioDevice.name,calib.audioDevice.id,strtrim(deviceNames{calib.audioDevice.id+1})));
            throw(ME);            
        elseif calib.audioDevice.nOutputChannels < 1
            ME = MException('myCalibration:InvalidInput', sprintf('Specified device ("%s") has no detectable output channels.',calib.audioDevice.name));
            throw(ME);                    
        elseif max(channels) > calib.audioDevice.nOutputChannels-1 %-1 since indexing begins at 0
            ME = MException('myCalibration:InvalidInput', sprintf('Specified channel "%i" is greater exceeds those supported by the specified device ("%s"; %i)\n[nb. remember that indexing begins at 0].',max(channels),calib.audioDevice.name,calib.audioDevice.nOutputChannels));
            throw(ME);     
        end
        
        % QUERY USER FOR HEADPHONE ID
        if nargin<17 || isempty(headphoneID) 
            if ~isfield(calib,'headphone') || ~isfield(calib.headphone,'id') || isempty(calib.headphone.id)
                headphoneID = getStringInput('\n\nFinally, please enter an (arbitrary) Headphone ID\n(e.g. ''Sen-2268''): ');
            else
                headphoneID = calib.headphone.id;
                if ~getLogicalInput('headphone id [%s] detected. Continue to use? (y/n [n==overwrite]):  ',calib.headphone.id);
                    headphoneID = getStringInput('\n\nFinally, please enter an (arbitrary) Headphone ID\n(e.g. ''Sen-2268''): ');
                end
            end
        end
        calib.headphone.id = headphoneID;

        % Initial save
        save(fileName,'calib')
        
        

    %%%%%%%
    %% 3 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% FEEDBACK/SUMMARY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        
        if nargin<17
            fprintf('\n\n');
            fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
            fprintf('Did you know you can save time by specifying parameters on the command line?\n')
            fprintf('For example, to re-run the current script just type:\n')
            str = sprintf('\n          calibrate(%s,''%s'',[%s],%s,[%i],[%i],%s,[%s],[%s],%s,[%1.4f],[%1.4f],''%s'',%i,''%s'',%i,''%s'')',log2str(createNew),fileName,num2str(channels),log2str(useWhiteNoise),lowestNoiseFreq,highestNoiseFreq,log2str(usePureTones),num2str(freqs),num2str(nSamples),log2str(logSpaceAMP),minAMP,maxAMP,slmParams,calib.audioDevice.id,calib.audioDevice.name,calib.audioDevice.nOutputChannels,calib.headphone.id);
            fprintf([escape(str) '\n']) %#ok
            fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
        end

        if isempty(ampVals)
            if logSpaceAMP
                ampVals = exp(linspace(log(minAMP),log(maxAMP),nSamples)); %get amp values
            else
                ampVals = linspace(minAMP,maxAMP,nSamples);
            end
        end % else were manually specified earlier
        
        
        fprintf(['\nCalibration file = ' escape(fileName) '\n']); %escape backstrokes to avoid illegal formatting strings
        fprintf(['Channels = [' num2str(channels) ']\n']);
        fprintf(['useWhiteNoise = [' log2str(useWhiteNoise) ']\n']);
        if useWhiteNoise
            fprintf('   lowestNoiseFreq = %i\n',lowestNoiseFreq);
            fprintf('   highestNoiseFreq = %i\n',highestNoiseFreq);
        end
        fprintf(['usePureTones = [' log2str(usePureTones) ']\n']);
        if usePureTones
            fprintf(['   freqs = [' num2str(freqs) ']\n']);
        end
        fprintf(['Amp Values = ' num2str(ampVals) '\n']);
        
        fprintf(['SLM setting = "' num2str(slmParams) '"\n\n']);
        getStringInput('Press ENTER to continue to leave setup and continue to calibration\n\n\n',true);
    
        
        
    %%%%%%%
    %% 4 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% FINAL INIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            

     	fprintf('\n\n\n');
      	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
      	fprintf('%%%%%% 2c. Initialising Audio Hardware (2/2)\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n') 
        fprintf('\n\n');    

        %% INIT 2
        % kill any pre-existing connection
        PsychPortAudio('Close');
        
        % Try opening a connection . If not ASIO
        % then this will produce lots of warnings.
        % n.b. we could use the Open command to connect to specific/a
        % subset of channels. But this would only work if ASIO. Instead, we
        % shall direct our audio data to a specific channel by constructing
        % a nchans-by-nsamples matrix, with zero elements on the rows for
        % all but the currently testing channel
        fprintf('\n\n');
        pahandle=PsychPortAudio('Open', calib.audioDevice.id,[],2,[],[],[],[],[]);
        
        % ok, kill this connection
        PsychPortAudio('Close');
        
        % Limit to only printing errors
        PsychPortAudio('Verbosity', 1);      

    %%%%%%%
    %% 5 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% RUN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        fprintf('\n\n');
      	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
      	fprintf('%%%%%% 4. Run!\n');
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n') 
       	fprintf('\n');
        
        
%         ampVals = linspace(0,1,nSamples+1); % should be log space really?
%         ampVals = ampVals(2:end);   % get rid of 0(!)
%         ampVals = exp(linspace(log(0.0001),log(1),nSamples)); %get amp values

        nChannels = length(channels);
        nFreqs = length(freqs);
        
        d = 1;
        n = Fs * d;
       
        blankAudioMatrix = zeros(calib.audioDevice.nOutputChannels,n);

        getStringInput('Press ENTER to begin calibration',true);
    

                
        %when working with the PTB it is a good idea to enclose the whole body of your program
        %in a try ... catch ... end construct. This will often prevent you from getting stuck
        %in the PTB full screen mode
        try
            
            for i=1:nChannels
                
                channel = channels(i);
                pahandle=sub_init();
                
                
                fprintf('\n\n');
                fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
                fprintf('//// Channel %i\n',channel);
                fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
                fprintf('\n\n\n');
                
                
                % get index to this channel in the calib struct
                % see also: calib_getChanIndex()
                ids = [];
                try %field won't exist in empty calibrations
                    ids = [calib.channels(:).id];
                end
                if isempty(ids)
                    chanIndex = 1;
                elseif any(ids==channel)
                    chanIndex = find(ids==channel);
                else
                    chanIndex = length(ids) + 1;
                end
                calib.channels(chanIndex).id = channel;

                if useWhiteNoise
                    fprintf('amplitude values to test:\n[%s]\n',num2str(ampVals));
                    
                    seed=sum(100*clock);                % Generate pseudorand seed
                    rand('twister',seed);               % init with seed
                    calib.channels(chanIndex).whitenoise.seed = seed; % save seed for our records
                    
                    rmsVals = ones(1,length(ampVals)).*NaN;
                    dbMeas = ones(1,length(rmsVals)).*NaN;
                    for k=1:nSamples
                        % generate sound data
                        x = randn(1, n);                    % Gausian noise
                        % filter
                        lf = max(1, lowestNoiseFreq) %?! is inclusive, so can't have 0?? or no?
                        hf = highestNoiseFreq;   % highest frequency
                        lp = lf * d; % ls point in frequency domain
                        hp = hf * d; % hf point in frequency domain
                        mask = zeros(1, n);           % initializaiton by 0
                        mask(1, lp : hp) = 1;         % filter design in real number
                        mask(1, n - hp : n - lp) = 1; % filter design in imaginary number
                        y = fft(x);
                        y = y.*mask;
                        x = real(ifft(y));
                        % set amplitude
                        x = x / max(abs(x));                % -1 to 1 normalization
                        x = x.*ampVals(k);
                        % calc RMS power (time-domain, discrete signal)
                        rms = sqrt(mean(x.^2));
                        rmsVals(k) = rms;
                        % assign to channel
                        audiodata = blankAudioMatrix;
                        audiodata(channel+1,:) = x;
                        %                         figure(k)
                        %                         plot(x)
                        
                        % query for measurement
                        instructions=sprintf('\n\n---------------------------------------------\n%1.3f amp (rms=%1.3f)\n------------------------\nPress s to start/stop audio. When finish making a measurement press f.\n\n',ampVals(k), rmsVals(k));
                        feedback=sprintf('Playing white noise @ %1.3f amp (rms=%1.3f) from channel %i\n', ampVals(k), rmsVals(k), channel); %#ok<MXFND>
                        dbMeas(k) = local_getDB_Manual(pahandle,audiodata,instructions,feedback);
                    end
                    
                    % fit
                    [fitCoeficients,r2,nPointsInc,nPointsExcluded,excludedIdx]=calib_fit_auto(rmsVals, dbMeas);
                    if getLogicalInput(sprintf('auto-fit complete (r2=%1.3f, n=%i [%i excluded]). Manually view/edit? (y/n): ',r2,n,nPointsExcluded));
                        [fitCoeficients,r2,nPointsInc,nPointsExcluded,excludedIdx]=calib_fit_manual(rmsVals, dbMeas);
                    end

                    % store measurement values
                    calib.channels(chanIndex).whitenoise.raw.rms = rmsVals;
                    calib.channels(chanIndex).whitenoise.raw.db = dbMeas;
                    calib.channels(chanIndex).whitenoise.fit.poly.coefs = fitCoeficients;
                    calib.channels(chanIndex).whitenoise.fit.poly.r2 = r2;
                    calib.channels(chanIndex).whitenoise.fit.poly.n = nPointsInc;
                    calib.channels(chanIndex).whitenoise.fit.poly.nExcluded = nPointsExcluded;
                    calib.channels(chanIndex).whitenoise.fit.poly.exclusionIdx = excludedIdx;
                    calib.channels(chanIndex).whitenoise.band.lf = lowestNoiseFreq;
                    calib.channels(chanIndex).whitenoise.band.hf = highestNoiseFreq;
                    calib.metaInfo.lastUpdate = datestr(now(),0);
                end
                if usePureTones
                    rmsVals = ampVals./sqrt(2);
                    fprintf('RMS values to test ==\n[%s]\n\n',num2str(rmsVals));
                    for j=1:nFreqs
                        freq = freqs(j);
                        dbMeas = ones(1,length(rmsVals)).*NaN;
                        for k=1:length(rmsVals)
                            % generate sound data
                            x = ampVals(k) * sin(2 * pi * freq * (1:n)/Fs);
                            audiodata = blankAudioMatrix;
                            audiodata(channel+1,:) = x;
                            % query for measurement
                            instructions=sprintf('\n\n---------------------------------------------\n%1.3f amp (rms=%1.3f)\n------------------------\nPress s to start/stop audio. When finish making a measurement press f.\n\n',ampVals(k), rmsVals(k));
                            feedback=sprintf('Playing %ihz tone @ %1.3f amp (rms=%1.9f) from channel %i\n', freq, ampVals(k), rmsVals(k), channel); %#ok<MXFND>
                            while 1
                                try
                                    dbMeas(k) = local_getDB_Manual(pahandle,audiodata,instructions,feedback);
                                    break
                                catch ME
                                    warning('a:b','Measurement error, try again')
                                end
                            end
                        end
                        
                        [fitCoeficients,r2,nPointsInc,nPointsExcluded,excludedIdx]=calib_fit_auto(rmsVals, dbMeas);
                        if getLogicalInput(sprintf('auto-fit complete (r2=%1.3f, n=%i [%i excluded]). Manually view/edit? (y/n): ',r2,n,nPointsExcluded));
                            [fitCoeficients,r2,nPointsInc,nPointsExcluded,excludedIdx]=calib_fit_manual(rmsVals, dbMeas);
                        end
                        
                        % get index to this freq in the calib.channel struct
                        % see also: calib_getFreqIndex()
                        vals = [];
                        try %field won't exist in empty calibrations
                            vals = [calib.channels(chanIndex).freqs(:).val];
                        end
                        if isempty(vals)
                            freqIndex = 1;
                        elseif any(vals==freq)
                            freqIndex = find(vals==freq);
                        else
                            freqIndex = length(vals) + 1;
                        end
                            
                        % store measurement values
                        calib.channels(chanIndex).freqs(freqIndex).val = freq;
                        calib.channels(chanIndex).freqs(freqIndex).raw.rms = rmsVals;
                        calib.channels(chanIndex).freqs(freqIndex).raw.db = dbMeas;
                        calib.channels(chanIndex).freqs(freqIndex).fit.poly.coefs = fitCoeficients;
                        calib.channels(chanIndex).freqs(freqIndex).fit.poly.r2 = r2;
                        calib.channels(chanIndex).freqs(freqIndex).fit.poly.n = nPointsInc;
                        calib.channels(chanIndex).freqs(freqIndex).fit.poly.nExcluded = nPointsExcluded;
                        calib.channels(chanIndex).freqs(freqIndex).fit.poly.exclusionIdx = excludedIdx;
                        calib.metaInfo.lastUpdate = datestr(now(),0);
                    end
                    
                end
                
                                    
                % save
                save(fileName,'calib')
                
                % CLEANUP
                sub_cleanUp(); %clean up before exit
                
            end
        catch
            % This section is executed only in case an error happens in the
            % experiment code implemented between try and catch...
            sub_cleanUp(); %clean up before exit

            %output the error message
            dispStruct(lasterror);
            psychrethrow(psychlasterror);
        end
        
%         calib_plot(calib)
        dispStruct(calib)
   
        
	%%%%%%%
    %% 4 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% SAVE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
      	% save
        save(fileName,'calib')
    
 	%%%%%%%
    %% 5 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% DISPLAY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    function pahandle=sub_init()
        % Open the default audio device [], with default mode [] (==Only playback),
        % and a required latencyclass of 2 (two == low-latency mode), as well as
        % a frequency of freq and nrchannels sound channels.
        % pahandle = PsychPortAudio('Open' [, deviceid][,mode][,reqlatencyclass][,freq][, channels][, buffersize][, suggestedLatency][, selectchannels]);
        % This returns a handle to the audio device:
%         pahandle = PsychPortAudio('Open', [], [], 2, Fs,
%         1,[],[],channel);
%         pahandle = PsychPortAudio('Open', calib.audioDevice.id,1,2,Fs, nChannels,[],[],[]);      
        pahandle = PsychPortAudio('Open', calib.audioDevice.id,1,2,Fs, [],[],[],[]);  %no longer specify number of channels (i.e. use blankAudioMatrix instead, for the non-ASIO folk)     
 
        % For the fun of demoing this as well, we switch PsychPortAudio to runMode
        % 1, instead of the default runMode 0. This will slightly increase the cpu
        % load and general system load, but provide better timing and even lower
        % sound onset latencies under certain conditions. It is not really needed
        % in this demo, just here to grab your attention for this feature. Type
        % PsychPortAudio RunMode? for more details...
        PsychPortAudio('RunMode', pahandle, 1);
    end
    function sub_cleanUp()

        % Wait for end of playback, then stop:
        PsychPortAudio('Stop', pahandle, 1);

        % Delete all dynamic audio buffers:
        PsychPortAudio('DeleteBuffer');

        % Close audio device, shutdown driver:
        PsychPortAudio('Close');
    end



end



function dbMeas=local_getDB_Manual(pahandle,audiodata,instructions,feedback)


    %                         dbMeas(1,k) = randn*10 + 20 * rmsVals(k);

    %disable output of keypresses to Matlab. !!!use with care!!!!!!
    %if the program gets stuck you might end up with a dead keyboard
    %if this happens, press CTRL-C to reenable keyboard handling -- it is
    %the only key still recognized.
    ListenChar(2);

    
    % load sound data into output buffer
    audioBuffer = PsychPortAudio('CreateBuffer', [], audiodata);
    
    % Instructions (2)
    fprintf(instructions);

    % Stay in a little interactive loop:
    currentlyPlaying = false;
    while 1
        % seems to cause crashes?? (Caught
        % MathWorks::System::FatalException)
%         % Query current playback status:
%         s = PsychPortAudio('GetStatus', pahandle);

        % Keyboard input?
        [secs, keyCode, deltaSecs] = KbWait([], 2);
        % Yes. Respond to it:
        if strcmpi(KbName(keyCode),'s')
            % If not already playing this sample
            if ~currentlyPlaying

                % Force stop as quickly as possible
                PsychPortAudio('Stop', pahandle, 2);

                % Provide feedback
                fprintf(feedback);

                % Before adding new slots we first must delete the
                % old ones, i.e. reset the schedule
                PsychPortAudio('UseSchedule', pahandle, 2);

                % Add new slot with playback request for user-selected buffer
                % to a still running or stopped and reset empty schedule. This
                % time we select one repetition of the full soundbuffer:
                PsychPortAudio('AddToSchedule', pahandle, audioBuffer, 99, 0, [], 1);

                % Play the sound (n.b. number of loop parameter
                % ignored - set during AddToSchedule)
                PsychPortAudio('Start', pahandle, [], 0, 1);

                % set the currently playing flag
                currentlyPlaying = true;
            else
%                 if s.Active
                    % Force stop as quickly as possible
                    PsychPortAudio('Stop', pahandle, 2);
%                 end

                % unset the currently playing flag
                currentlyPlaying = false;

                % Provide feedback
                fprintf('Audio terminated (s to replay, f to continue)\n'); %#ok<MXFND>
            end
        elseif strcmpi(KbName(keyCode),'f')
%             if s.Active
                % Force stop as quickly as possible
                PsychPortAudio('Stop', pahandle, 2);
%             end

            % Restore user input to matlab command window
            ListenChar(0);

            % Query user for measured value
            usrInput = getRealInput('\nMeasured intensity (SPL dB) : ',true);

            if ~isempty(usrInput)
                % store value
                dbMeas = usrInput;
                break; % break out of the sound playing loop
            else
                % return to audio output
                ListenChar(2);
                % Instructions (2)
                fprintf('Press s to start/stop audio. When finish making a measurement press f.\n')

            end
        end

        % Wait a bit before next status and key query. The 'YieldSecs' option
        % tells WaitSecs that this wait doesn't need to be accurate down to the
        % millisecond, but allows for some lenience in timing. This slack
        % allows to reduce system load:
        WaitSecs('YieldSecs', 0.05);
    end % End of interactive loop.
end

