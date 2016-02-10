function calib=calib_makeDummy(channels,freqs,hundredDbRMSs, id,name,nOutputChannels)
% CALIB_MAKEDUMMY Returns a dummy calibration structure
%
%   #########
%         
%         % dummy calibrations are useful if you are just developing a script
%         % (e.g. on a random computer), and don't want all the hassle of having
%         % to actually perform a proper calibration
%         
% @Parameters:             
%
%     	channels            	Real            #####
%                                e.g. ######
%     	freqs                   Real            #####
%                                e.g. ######
%     	hundredDbRMSs        	Real            #####
%                                e.g. ######
% @Returns:  
%
%    	calib     	Struct    	#####
%
%
% @Usage:           calib=calib_makeDummy(channels, freqs, hundredDbRMSs)  
% @Example:         calib=calib_makeDummy(.5 / sqrt(2)); %to make a calibration where puretones will have an amplitude of .5 at '100dB'
% 
%     
%     %% BASIC EXAMPLE 
% 
%     calib = calib_makeDummy(0, 1000, .4/sqrt(2)); % to give an amplitude of .2 @ 100db
%     % basic synthesis
%     Fs = 44100; d = .3; n = ceil(d * Fs); t = (1:n) / Fs;
%     x = .4 * sin(2 * pi * 1000 * t + 0);
%     sound(x,Fs)
%     % make it quieter
%     x_new = calib_setRMS(x, calib_getTargRMS(calib,70,0,1000) );
%     sound(x_new,Fs)
%     % make it louder
%     x_new = calib_setRMS(x, calib_getTargRMS(calib,110,0,1000) );
%     sound(x_new,Fs)
%     
%     
%     %% SILLY EXAMPLE 
% 
%     calib = calib_makeDummy([0 1], 1000, [.1 / sqrt(2); .9 / sqrt(2)] ); % to give an amplitude of .2 @ 100db
%     dispStruct(calib)
%     % basic synthesis
%     Fs = 44100; d = .3; n = ceil(d * Fs); t = (1:n) / Fs;
%     x = .4 * sin(2 * pi * 1000 * t + 0);
%     sound(x,Fs)
%     % make it quieter
%     x_new = calib_setRMS(x, calib_getTargRMS(calib,100,0,1000) );
%     sound(x_new,Fs)
%     % make it louder
%     x_new = calib_setRMS(x, calib_getTargRMS(calib,100,1,1000) );
%     sound(x_new,Fs)
%     
%     
%     %% BINAURAL (MULTI-CHANNEL) EXAMPLE 
%     
%     % this time same for both noise and tones, but different between
%     % channels (left ear louder)
%     calib=calib_makeDummy([0 1],[-1 1000],[.9/sqrt(2),.9/sqrt(2); .2/sqrt(2),.2/sqrt(2)])
%     % basic synthesis
%     Fs = 44100; d = .3; n = ceil(d * Fs); t = (1:n) / Fs;
%     x = .4 * sin(2 * pi * 1000 * t + 0);
%     sound(x,Fs)
%     % calibrated play
%     x_new = calib_setRMS(x, calib_getTargRMS(calib,100,[0 1],1000));
%     sound(x_new',Fs)
%     % plot
%     figure(); plot(x_new(1,:),'r'); hold on; plot(x_new(2,:),'b');
%     % repeat for even calibration
%     calib=calib_makeDummy([0 1],[-1 1000],[.5/sqrt(2),.5/sqrt(2); .5/sqrt(2),.5/sqrt(2)]);  
%     sound(x,Fs)
%     x_new = calib_setRMS(x, calib_getTargRMS(calib,100,[0 1],1000));
%     sound(x_new',Fs)
%     figure(); plot(x_new(1,:),'r'); hold on; plot(x_new(2,:),'b:');
% 
%
% @Requires:        PsychTestRig2
%   
% @See also:        #####
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	18/02/2011
% @Last Update:     18/02/2011
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	28/01/2011    Initial build.
%
% @Todo:            Lots!


    %% INPUTS

    % If vectors given for freqs and/or hundredDbRMSs then replace with matrices (identical row for each channel) 
    if size(hundredDbRMSs,1) == 1
        hundredDbRMSs = repmat(hundredDbRMSs,length(channels),1);
    end
    if size(freqs,1) == 1
        freqs = repmat(freqs,length(channels),1);
    end

    % check that each channels has a row vector of freqs and hundredDbRMSs
    if size(hundredDbRMSs,1) ~= length(channels)
        error('calib_makeDummy:inputError','Each channel must have a row of 100dB RMS values. Input a vector to use the same values for each channel.');
    end
    if size(freqs,1) ~= length(channels)
        error('calib_makeDummy:inputError','Each channel must have a row of frequency values. Input a vector to use the same values for each channel.');
    end

    if nargin < 4 || isempty(id)
        id = -1;
    end
    if nargin < 5 || isempty(name)
        name = 'Default';
    end
    if nargin < 6 || isempty(nOutputChannels)
        nOutputChannels = 'Unknown';
    end

    %% INIT

    calib = struct();
    
    calib.audioDevice.id = id;
    calib.audioDevice.name = name;
    calib.audioDevice.nOutputChannels = nOutputChannels;
    
    calib.metaInfo.created = datestr(now(),0);
    calib.metaInfo.SLM_settings = 'n/a';
    calib.metaInfo.fileName = 'n/a';
    calib.metaInfo.lastUpdate = 'n/a';
    calib.metaInfo.derivedFrom = 'n/a';
    
    calib.headphone.id = 'Unknown';
    

               
    %% MAKE
    
    
    for chanIdx=1:length(channels)
        calib.channels(chanIdx).id = channels(chanIdx);
    
        pureToneCounter = 1;
        for freqIdx=1:size(freqs,2)
            freq = freqs(chanIdx, freqIdx);
            
            % CALC COEFICIENTS
            hundredDbRMS = hundredDbRMSs(chanIdx,freqIdx);
            % no idea if this is right, but seems to vaguely do the job!
            P0 = (2*10^-5);
            coefs = polyfit(log10([P0 hundredDbRMS]),[1 100],1);

            % Store values
            if freq==-1
                calib.channels(chanIdx).whitenoise.fit.poly.coefs = coefs;
            else
                calib.channels(chanIdx).freqs(pureToneCounter).val = freq;
                calib.channels(chanIdx).freqs(pureToneCounter).fit.poly.coefs = coefs;
              	calib = calib_poly2SLM(calib, chanIdx, pureToneCounter, [], [], false);
                pureToneCounter = pureToneCounter + 1;
            end
            
        end    
    end
    
   
%     
% %     calib.coefs(2) = 0; % inercept assumed to be 0
% %     calib.coefs(1) = 100 / log10(hundredDbRMS); %i.e. from reordering 'mx + c = y'
%     
%     % no idea if this is right, but seems to vaguely do the job!
%     P0 = (2*10^-5);
%     calib.coefs = polyfit(log10([P0 hundredDbRMS]),[1 100],1);
    
end


    % this stuff is all rubbish!
%     calib.coefs(2) = 0; % inercept assumed to be 0
%     P0 = (2*10^-5);
%  	calib.coefs(1) = (P0*exp(5))/hundredDbRMS; %from solve('100 = 20*log10((x*hundredDbRMS)/P0)')
%     calib.coefs(1) = 5/log(hundredDbRMS/P0)
