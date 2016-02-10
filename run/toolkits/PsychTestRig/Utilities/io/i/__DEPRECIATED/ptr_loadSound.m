function [wav]=ptr_loadSound(fullFn, Fs, rms, testChans, outChans)
    [wav, obsFs] = wavread(char(fullFn));
    if obsFs ~= Fs
        warning('ptr_loadSound:SamplingFrequencyMismatch', 'Sampling rate mismatch.\n          Specified file (%s) had a detected sampling rate (%i) that differed from that specified/expected (%i)', fullFn, obsFs, Fs);
        wav = resample(wav, obsFs, Fs);
    end
    wav = calib_setRMS(wav', rms ); %transpose to make compatible with psychportaudio (later) and set volume [i.e. portaudio expects row vectors, but wav is read in as columns]
    wav = padChannels(wav, testChans, outChans);
end
