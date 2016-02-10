function rms=getRMS(x, direction, domain)
    % gets RMS amplitude
    % inTimeDomain : if false then assume frequency domain.
    %
    % Time : sqrt(mean(x.^2))
    % Freq : sqrt(sum(Power Spectral Density))
    %
    % Parseval's theorem suggests that these two values should be equal
    %
    % EXAMPLE:
    %
    %     d = 1;
    %     Fs = 44100;
    %     n = d * Fs;
    %     x = 1 * sin(2 * pi * 1000 * (1:n)/Fs);
    %     sound(x,Fs)
    %     %
    %     y = fft(x, n);
    %     p = getFFTPow(y)
    %     %
    %     getRMS(x)
    %     getRMS(p,[],'freq')  
    %
    %
    % EXAMPLE 2:
    %
    %       getRMS(x)
    %       getRMS(getFFTPow(fft(x)),[],'freq')
   %
   %
   % gets RMS amplitude
   % n.b. POWER is proportional to amplitude SQUARED
            
    %%%%%%%%%
    %%% 0 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialise variable %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % necessary params
        if nargin < 1 || isempty(x)
            fprintf('USAGE: rms=getRMS(x, [direction], [domain])\n');
            error('getRMS:invalidInput','No input specified');
        end

        % optional params
        if nargin < 2 || isempty(direction)
            % return 2 if row is longest, 1 if column is longest (i.e. if 1 then
            % probably column vectors)
            direction = find(size(x)==length(x));
        end
        if nargin < 3 || isempty(domain)
            domain = 'time';
        elseif ~any(strcmpi(domain,{'time','freq'}))
                 error('getRMS:invalidInput', '"%s" is not a recognised domain. Please specify either "time" or "freq"', domain)
        end
        
    %%%%%%%%%
    %%% 1 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Calc RMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        if strcmpi(domain,'time')
            rms = sqrt(mean(x.^2,direction));
        elseif strcmpi(domain,'freq')
            rms = sqrt(sum(x));
        else
            error('getRMS:invalidInput', '"%s" is not a recognised domain. Please specify either "time" or "freq"', domain)
        end
    
end