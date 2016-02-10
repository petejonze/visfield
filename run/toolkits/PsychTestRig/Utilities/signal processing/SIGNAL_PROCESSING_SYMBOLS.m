%% SIGNAL_PROCESSING_SYMBOLS
% Okay, so I'm sick of srambling around looking for synthesis code. This is
% a central repository that demonstrates how to do various things, and -
% just as importantly - what variable names/comments to yse

%%
% Some definitions

% x     time domain sample array
% y     frequency domain sample array (also known as: fftx)

% n     number of samples in time domain (also known as: L)
% nBins number of samples in frequency domain (also known as: NFFT)


%% Initialise
clc

%%
% Global

Fs = 44100;                 % sample frequency (Hz)
Fn = Fs/2;                  % Nyquist frequency [limit] (Hz)
twoPI = 2 * pi;


d = 0.37;                 	% duration (s)
n = Fs * d;                 % number of samples
nh = n / 2;                 % half number of samples


%%
% Sinusoid

t = (1:n) / Fs;             % time vector [sound data preparation]
cf = 1000;                  % carrier frequency (Hz)
amp = 1;
phase = 0;
x = amp * sin(twoPI * cf * t + phase);    % sinusoidal modulation


%%
% FFT

rand('twister',sum(100 * clock));   % initialize random seed
x = randn(1, n);                    % Gausian noise
x = x / max(abs(x));                % -1 to 1 normalization

dF = Fs/n;                      % DeltaF (step size in Hz between bin centre frequencies) [i.e. bin width?]
nBins = Fs/dF;                  % Number of bins/frequency-components.
% nBins = 2^nextpow2(nBins);    % This optimisations no longer necessary (?)
nUnique = ceil((nBins+1)/2);    % Calculate the number of unique points

y=fft(x,nBins);                 % Some argue that you should use: fftshift(fft(fftshift(x))) - see http://www.mathworks.co.uk/matlabcentral/fileexchange/25473-why-use-fftshiftfftfftshiftx-in-matlab-instead-of-fftx


y = y(1:nUnique);               % 2nd half of fft redundent, so can throw away

% GET MAGNITUDE (http://www.mathworks.com/support/tech-notes/1700/1702.html)
mag_vector = y.*conj(y); % Since the fourier transform values are complex quantities. Alt: mag_vector = abs(freqSpec)^2; % Take the magnitude of fft of x
mag_vector = mag_vector/length(y); % Normalise: Scale the fft so that it is not a function of the length of y

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% (i.e. compensate for missing negative frequencies)
% The DC component and Nyquist component, if it exists, are unique and
% should not be multiplied by 2.
if rem(nBins, 2) % odd nfft excludes Nyquist point
    mag_vector(2:end) = mag_vector(2:end).*2;
else
    mag_vector(2:end -1) = mag_vector(2:end -1).*2;
end

% GET PHASE
phase_vector = unwrap(angle(y));  % phase of sinusoids in radians, [unwrap() copes with 360 degree jumps?? - see below]

% Now, create a frequency vector.
% This is an evenly spaced frequency vector with nUnique points.
% The frequency scale begins at 0 and extends to N - 1 for an N-point FFT
f = (0:nUnique-1)*Fs/nBins; 
% Sometimes we might not want to throw the imaginary side away, in which
% case the frequency vector can be constructed symmetrically as follows:
f_double = Fs*(mod(((0:nBins-1)+floor(nBins/2)), nBins)-floor(nBins/2))/nBins; % Alt: f_double = [f fliplr(-f)]; f_double_alt(end) = [];

% Always useful to see if/what it plots!
figure(666)
subplot(4,1,1); plot(t,x);
subplot(4,1,2); plot(f,mag_vector); xlim([0 10000]);

y=fft(x,nBins);
mag_vector = y.*conj(y);
mag_vector = mag_vector/length(y);
subplot(4,1,3); plot(f_double,mag_vector);
subplot(4,1,4); plot(f_double,fftshift(mag_vector)); % ???

%%
% FFT filtering

seed=sum(100*clock);
rand('twister',seed);               % initialize random seed
x = randn(1, n);                    % Gausian noise
x = x / max(abs(x));                % -1 to 1 normalization
t = (1:n) / Fs;                     % time vector [sound data preparation]

dF = Fs/n;                      % DeltaF (step size in Hz between bin centre frequencies) [i.e. bin width?]
nBins = Fs/dF;                  % Number of bins/frequency-components.
% nBins = 2^nextpow2(nBins);    % This optimisations no longer necessary (?)
nUnique = ceil((nBins+1)/2);    % Calculate the number of unique points
f_double = Fs*(mod(((0:nBins-1)+floor(nBins/2)), nBins)-floor(nBins/2))/nBins; % frequency values vector. Alt: f_double = [f fliplr(-f)]; f_double_alt(end) = [];


% build a mask [... 0 0 0 1 1 ... 1 1 0 0 0 ...]
% with one entry per frequency. We shall use the name mask rather than
% filter to avoid overwriting any functions
% find nearest point: [i]=find(min(abs(x-v))==abs(x-v))
mask=(abs(f_double) < 2000) | (abs(f_double) > 4000);

% to frequency domain
y=fft(x,nBins);                 % Some argue that you should use: fftshift(fft(fftshift(x))) - see http://www.mathworks.co.uk/matlabcentral/fileexchange/25473-why-use-fftshiftfftfftshiftx-in-matlab-instead-of-fftx


figure(667)
subplot(4,1,1); plot(t,x);
subplot(4,1,2); plot(f_double,y); xlim([0 10000]);
sound(x,Fs); pause(d);

% apply filter (i.e. convolution(?))
y = y .* mask;

% back to time domain
x=ifft(y);

% overwrite original data
% real() is needed to remove imaginary part caused by finite numerical precision
x=real(x);
x = x / max(abs(x));                % -1 to 1 normalization

subplot(4,1,3); plot(f_double,y); xlim([0 10000]);
subplot(4,1,4); plot(t,x);
sound(x,Fs); pause(d);

%% Finish Up
disp('done')

%%
% Notes

% The complex magnitude squared of Y is called the power, and a plot of power versus frequency is a "periodogram".