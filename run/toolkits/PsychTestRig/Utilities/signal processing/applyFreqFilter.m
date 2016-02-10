function x_filt=applyFreqFilter(x,filt)
% apply (e.g. headphone response) filter

    if size(filt,1) == 1
        nChans = size(x,1);
        filt = repmat(filt,nChans,1);
    end

    y = fft(x) .* sqrt(filt); % sqrt offilt since fft(x).^2 gives power (well, the real part does at any rate)
    x_filt = real(ifft(y));

end

