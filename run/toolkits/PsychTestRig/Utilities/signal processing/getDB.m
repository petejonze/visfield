function db=getDB(x, direction, domain, inPressure, PRef)
    % inTimeDomain : if false then assume frequency domain.
    % inPressure : if true then 20*log10, if false then in 10*log10 (power)
    % PRef : reference power. Defaults to 0.000002 [arbitrary]
    %
    % Uses getRMS to first get the power
    %
    % getDB(x*2)-getDB(x) % should approx equal 6
    % getDB(x)+getDB(y)     % should approx equal getDB(x)+3, if y is
    %                       % uncorrelated with x
   
            
    %%%%%%%%%
    %%% 0 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialise variable %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % necessary params
        if nargin < 1 || isempty(x)
            fprintf('USAGE: rms=getDB(x, [direction], [domain])\n');
            error('getDB:invalidInput','No input specified');
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
                 error('getDB:invalidInput', '"%s" is not a recognised domain. Please specify either "time" or "freq"', domain) 
        end
        if nargin < 4 || isempty(inPressure)
            inPressure = true;
        end
        inPressure = logical(inPressure);
        if nargin < 5 || isempty(PRef)
            PRef = 20 * 1.0E-6; % ALT: 0.0002;
        end
        
    %%%%%%%%%
    %%% 1 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Calc RMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        power = getRMS(x, direction, domain);
        
    %%%%%%%%%
    %%% 2 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Convert to db %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
        if inPressure
            db = 20 * log10(power/PRef); % i.e. since pressure = power^2; ALT: 10 * log10((power^2)/(PRef^2))
        else % in power
            db = 10 * log10(power/PRef);
        end
end