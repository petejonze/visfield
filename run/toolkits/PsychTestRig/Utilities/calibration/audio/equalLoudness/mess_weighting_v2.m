%% changing rms to reflect db attenuation

REF = .0002

db = 10*log10(1000/REF)
% db = 0
% z = exp10((db-11)/10) / exp10((db)/10)
z = exp10((-11)/10)
% 10 * log10(1000/.000002)
% 10 * log10((.7943*1000)/.000002)
10 * log10((z*1000)/REF)

%% calculating db attenuation

phon = 80;

f = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 ...
1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500];
y=iso226(phon);
pp = spline(log10(f),y)
xx = linspace(log10(f(1)),log10(f(end)),1000);
yy = ppval(pp, xx);

close all; 
figure(); plot(log10(f),y,'o',xx,yy,'r'); 
set(gca,'XTick',log10(f(1:3:end)),'XTickLabel',f(1:3:end))
figure(); plot(log10(f),y-phon,'o',xx,yy-phon,'r');
set(gca,'XTick',log10(f(1:3:end)),'XTickLabel',f(1:3:end))
ppval(pp,log10(1000))-phon


%% Play, Brick-wall bandpass filter, play, equal loudness filter (+ brickwall), play
phon = 80;

f = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 ...
1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500];
y=iso226(phon);
pp = spline(f,y-phon)

Fs = 22050;
d = 10;
n = floor(d * Fs);
t = (1:n)/Fs;

nBins = n; %i.e. in order to achieve time domain signal of duration d
f_double = Fs*(mod(((0:nBins-1)+floor(nBins/2)), nBins)-floor(nBins/2))/nBins;
    


x = .1 * randn(1,n);
cf = 250;
% x = .5 * sin(2 * pi * cf * t);
sound([x; x*0]',Fs)


z = ones(1,n);
z(abs(f_double)<200) = 0;
z(abs(f_double)>5000) = 0;
z(1) = 1; % set DC to 1 (don't want to mess with this, though should always be 0 anyway for our purposes, since only using sine waves)
y = fft(x) .* z;
xxx = real(ifft(y));
% sound(xxx,Fs)
% sound([xxx; xxx*0]',Fs)


z = ppval(pp, abs(f_double));
z = exp10(z./10); %convert to rms power scale factor
z(abs(f_double)<200) = 0;
z(abs(f_double)>5000) = 0;
z(1) = 1; % set DC to 1 (don't want to mess with this, though should always be 0 anyway for our purposes, since only using sine waves)
% z = sqrt(z);
% z(1:199) = 0;
% z(5001:end) = 0;
% zz = [fliplr(z) 1 z];
% yy = fft(x) .* zz;
% xx = real(ifft(yy));

yy = fft(x) .* sqrt(z); % sqrt of z since fft(x).^2 gives power (well, the real part does at any rate)
xx = real(ifft(yy));
sound([xx; xx*0]',Fs)

            %
            close all
            figure();
            subplot(2,1,1); plot(f_double,abs(fft(x)).^2,'r',f_double,abs(fft(xxx)).^2,'g',f_double,abs(fft(xx)).^2,'b')
            xlim([0 Fs/2])

            subplot(2,1,2); plot(t,x,'r',t,xx)

ppval(pp,cf)
% these changes have been checked and verified for individual tones using a B&K 2260
% Investigator Sound Level Meter [SLM]. Also checked roughly when
% monitoring individual frequencies in a random noise field (using a slow
% temporal filter setting)



% esp. at low freqs: prone to get clipping. Could avoid this by scaling the
% final time-domain waveform, but wouldn't this potentially reduce the total
% level disproportionately?
% might not be an issue in practice; will have to see.            
% hmmmm




%% odds and ends
% %% couldn't we just apply to individual components?
% 
% cf = randi(10000);
% phi = rand*(2*pi);
% x1 = 1.4142 * sin(2 * pi * cf * t + phi);
% 
% cf = randi(10000);
% phi = rand*(2*pi);
% x2 = 1.4142 * sin(2 * pi * cf * t + phi);
% 
% cf = randi(10000);
% phi = rand*(2*pi);
% x3 = 1.4142 * sin(2 * pi * cf * t + phi);
% 
% cf = randi(10000);
% phi = rand*(2*pi);
% x4 = 1.4142 * sin(2 * pi * cf * t + phi);
% 
% cf = randi(10000);
% phi = rand*(2*pi);
% x5 = 1.4142 * sin(2 * pi * cf * t + phi);
% 
% getRMS(x1)
% sqrt(getRMS(x1)*5)
% getRMS(x1+x2+x3+x4+x5)
% 
%         %%
%         for i=1:30
%             cf = randi(10000);
%             phi = rand*(2*pi);
%             A =  rand*10
%             x(i,:) = A * sin(2 * pi * cf * t + phi);
%         end
%         
%         sqrt(sum(getRMS(x)))
%         getRMS(sum(x))
%         
%         %% in conclusion: no. since level not the additive sum of
%         %% individual levels (esp. if phase random, such that get
%         %% a lot of constructive/destructive interactions)