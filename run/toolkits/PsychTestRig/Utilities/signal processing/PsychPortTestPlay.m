function PsychPortTestPlay(x,Fs,outputChannels,calib)

    pahandle=sub_init();
    
    % could just select only the specified output channels when
    % initialising PsychPortAudio, but this only works with ASIO drivers,
    % so instead we'll manually blank out the unwanted channels..
    n = size(x,2);
    audioMatrix = zeros(calib.audioDevice.nOutputChannels,n); % blank init
    audioMatrix(outputChannels+1,:) = x; % insert vals
    x = audioMatrix;
    
    try
        d = length(x)/Fs;
        PsychPortAudio('FillBuffer', pahandle, x);
        PsychPortAudio('Start', pahandle, 1,[],[],[]); % Play once, start it immediately (0) and wait for the playback to start, return onset timestamp.
        WaitSecs(d+0.2);
    catch ME
        sub_cleanUp();
        throw(ME);
    end
    sub_cleanUp();



    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    function pahandle=sub_init()
        InitializePsychSound
        
        % Open the default audio device [], with default mode [] (==Only playback),
        % and a required latencyclass of 2 (two == low-latency mode), as well as
        % a frequency of freq and nrchannels sound channels.
        % pahandle = PsychPortAudio('Open' [, deviceid][,mode][,reqlatencyclass][,freq][, channels][, buffersize][, suggestedLatency][, selectchannels]);
        % This returns a handle to the audio device:
        pahandle = PsychPortAudio('Open', calib.audioDevice.id,1,2,Fs,[],[],[],[]);
        
 
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