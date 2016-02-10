function [filt,f_double]=calib_getHRF(calib,Fs,d)
% get headphone response filter
% duration of time-domain vector
% Fs sampling rate

    % Init
    SLM = calib.headphone.hrf.SLM;
    filt_min = calib.headphone.hrf.min;
    filt_max = calib.headphone.hrf.max;
    
    
    % make filter
    n = d * Fs;
    nBins = n; %i.e. in order to achieve time domain signal of duration d
    f_double = Fs*(mod(((0:nBins-1)+floor(nBins/2)), nBins)-floor(nBins/2))/nBins;
    
    filt = slmeval(log10(abs(f_double)),SLM,0);
    filt = exp10(filt./10); %convert to rms power scale factor
    filt(abs(f_double)<filt_min) = 0;
    filt(abs(f_double)>filt_max) = 0;
    filt(1) = 1; % set DC to 1 (don't want to mess with this, though should always be 0 anyway for our purposes, since only using sine waves)

    % done
end

