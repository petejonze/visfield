function [x,t]=getSilence(Fs,d,chans)
% returns zeros representing a given time period for length(chans)

    %% init
    if nargin < 3 || isempty(chans)
        nChans = 1; % assume a single channel
    else
        nChans = length(chans);
    end

    %% SYNTH
    n = floor(Fs * d);  % number of samples
    t = (0:(n-1)) / Fs;
    x = zeros(nChans, n);  
end