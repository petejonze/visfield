function y=sinAmpMod(x,Fs,mFreq,mDepth,adjustAmplitude)
% SINAMPMOD Sinusoidally amplitude modulate the input vector, x.
%
%   <Further Info>
%
% @Parameters:  
%
%       x                   Real        Input signal vector (time-domain)
%
%       Fs                  Real        Sample rate (e.g., 44100)
%
%       mFreq               Real        Modulation frequency (Hz)
%
%       mDepth              Real        Index between 0 - 1
%
%       adjustAmplitude 	logical     Whether to adjust amplitude to compensate for differences in RMS due to modulation (see Viemeister, 1979)
%
%
% @Returns:  
%
%    	y       	Real      Output signal vector (time-domain)
%
% @Usage:           y=sinAmpMod(x,Fs,mFreq,mDepth,[adjustAmplitude])  
% @Example:         y=sinAmpMod(x, 44100, 80, .7, true)
%
% @Requires:        PsychTestRig
%   
% @See also:        #####
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	14/06/2012
% @Last Update:     14/06/2012
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	14/06/2012    Initial build.
%
% @Todo:            ####
    
    % parse input(s)
    if nargin < 5 || isempty(adjustAmplitude)
        adjustAmplitude = true;
    end

    % init
    n = length(x);                              % number of samples

    % set modulator
    t = (0:(n-1)) / Fs;                         % modulator data preparation
    m = 1 + mDepth * sin(2 * pi * mFreq * t);   % sinusoidal modulation depth [between 0 and 1]

    % apply modulator
    y = m .* x;                                 % perform amplitude modulation
    
    % apply amplitude compensation
    if adjustAmplitude
        y = y / (1 + (mDepth^2)/2)^(1/2);       	% see Viemeister (1979) [sqrt since changing amplitude not power]
    end
    
end