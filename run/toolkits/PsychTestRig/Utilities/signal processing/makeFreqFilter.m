function [finalFilt,f_double]=makeFreqFilter(SLMs,Fs,d,filt_min,filt_max)
% adapted from calib_getHRF.m

    if nargin<4 || isempty(filt_min)
        filt_min = -inf;
    end
    if nargin<5 || isempty(filt_max)
        filt_max = inf;
    end
    
   	% init
    n = d * Fs;
    nBins = n; %i.e. in order to achieve time domain signal of duration d
    f_double = Fs*(mod(((0:nBins-1)+floor(nBins/2)), nBins)-floor(nBins/2))/nBins;
    finalFilt = ones(1,length(f_double));
    
    % make filters
    for SLM = SLMs
        filt = slmeval(log10(abs(f_double)),SLM,0);
        filt = exp10(filt./10); %convert to rms power scale factor
        filt(abs(f_double)<filt_min) = 0;
        filt(abs(f_double)>filt_max) = 0;
        filt(1) = 1; % set DC to 1 (don't want to mess with this, though should always be 0 anyway for our purposes, since only using sine waves)
        % add to / convolve with finalFilt
        finalFilt = finalFilt .* filt;
    end
end
