function w=getSquaredCosineWindow(Fs,d,wd,nChannels)
%GETSQUAREDCOSINEWINDOW generates a squared cosine (Hann) window.
%
%   Generates a Hann window using the formula:
%
%       w = .5*(1 - cos(2*pi*(0:M-1)'/(M-1)));
%
%   It is important to be aware that the denominator of the Hann window is
%   somewhat contentious. Although in practice the different formulations
%   differ minutely, it is important to be aware of the issue. The three
%   common formulations are as follows:
% 
%       (1) M+1 Often (though not always!) used by Matlab functions. This
%       has the effect of removing the non-zero endpoints. The logic of
%       this seems sound, since essentially this just removes/wastes a
%       sample point at the beginning & end.
% 
%       (2) M-1 The Hann formula as defined on Wikipedia. results in a
%       symmetric window with zero endpoints. This function uses this.
% 
%       (3) M   Also sometimes cited as the Hann formula. This results in
%       a zero endpoint at the start but not the end. This means that the
%       window is not symmetric (but is periodic(??)).
%
%   For more info on this issue, see:
%       https://ccrma.stanford.edu/~jos/sasp/Matlab_Hann_Window.html
%       http://www.wikidoc.org/index.php/Window_function
%       http://www.mathworks.com/matlabcentral/newsreader/view_thread/816
%
%   Further trivia:
%       > The Hann window is often (mistakenly) called the "Hanning" window
%       > Together with the Hamming window this forms part of the "raised
%       cosine" family
%
% @Requires the following toolkits: <none>
%   
% @Parameters:  
%
%    	Fs              Integer.  	The sampling rate/frequency (Hz).
%                                   e.g. 44100
%     	d               Real.       Total stimulus duration (used to
%                                   generate the sustain period)                  
%       wd              Real.       Onset(/Offset) duration (seconds)
%
% @Returns:  
%
%    	w               RealArray. 	Vector containing time-domain window.
%
% @Example:         myWin=getSquaredCosineWindow(44100,0.37,0.01);
%                   mySig = mySig .* myWin;
%
% @See also:        <none>
% 
% @Earliest compatible Matlab version:	<unknown>
%
% @Author:          Pete R Jones
%
% @Creation Date:	10/07/10
% @Last Update:     10/07/10
%
% @Todo:            <none>

    % validate input
    if wd > d
        ME = MException('getSquaredCosineWindow:InvalidInput', sprintf('Invalid input:\n  Specified window duration (%1.4f) exceeds specified stimulus duration (%1.4f).\nScript aborted.',wd,d));
     	throw(ME);
    end
    
    % initialise parameters
    n = floor(Fs * d); 	% number of samples total (ramp + sustain)
                        % not sure about floor here, but we do need some
                        % kind of rounding. E.g. a .37 duration signal
                        % played at Fs==22050 would be 8158.5 samples(!)
    Mh = floor(Fs * wd);       % number of samples in just the onset (/offset)
 	M = Mh * 2;	% number of ramp samples
        
    % generate samples
    H = .5*(1 - cos(2*pi*(1:M)/(M+1))); 	% generate ramp
    sustain = ones(1,n-M);                  % generate sustain

    % construct window
    w = [H(1:Mh) sustain H(Mh+1:end)];      	% join
    
    % ease of use
    if nargin > 3 && ~isempty(nChannels)
        w = repmat(w,nChannels,1);
    end
    
    return;

end