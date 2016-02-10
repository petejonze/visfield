function [p, freq]=getFFTPow(y, Fs)
    % e.g., then use: stem(freq, p)

    n = length(y);
    nUniquePts = ceil((n+1)/2);

    p = y(1:nUniquePts); % select just the first half since the second half is a mirror image of the first
    p = abs(p); % take the absolute value, or the magnitude the fourier transform of the tone returned by the fft function contains both magnitude and phase information and is given in a complex representation (i.e. returns complex numbers). By taking the absolute value of the fourier transform we get the information about the magnitude of the frequency components.
    p = p/n; % scale by the number of points so that the magnitude does not depend on the length of the signal or on its sampling frequency
    p = p.^2;  % square it to get the power
    % p = (abs(y(1:nUniquePts))/n).^2; % as above (condensed)

    % Now multiply by two since we dropped half the spectrum
    if rem(n, 2) % odd nfft excludes Nyquist point
        p(2:end) = p(2:end)*2;
    else
        p(2:end -1) = p(2:end -1)*2;
    end
    
    % compute a vector containing corresponding frequency values, in Hertz 
    f_double = Fs*(mod(((0:n-1)+floor(n/2)), n)-floor(n/2))/n; % for FFT
    freq = f_double(1:nUniquePts); % not sure if robust?!
end