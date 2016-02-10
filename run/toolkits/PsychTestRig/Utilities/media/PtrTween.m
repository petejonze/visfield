classdef PtrTween < handle
    %#####
    %
    % Interpolates between two known points, startVal and endVal
    % based on a specified function, with steps according to
    % a given duration & framerate.
    %
    % Skips startVal/start point. Always ends at endVal.
    % Valid functions: linear, exp, exp10, log, log10, norm
    %
    % Returns column vector(s) of points
    %
    %     startVal    Start value
    %     endVal    End value
    %     d       duration (seconds, or if Framerate not specified then 'd' will assumed to be the number of frames)
    %     Fr      frame rate
    %     func    function type: exp, exp10, log, log10, norm, inorm, sin
    %
    % @Requires the following toolkits: <none>
    %
    % @Constructor Parameters:
    %
    %     	######
    %
    %
    % @Example:
    %
    %         start_coords = [1 4];
    %         end_coords = [8 7];
    %         %
    %         close all
    %         figure();
    %         hold on
    %         plot([start_coords(1) end_coords(1)],[start_coords(2) end_coords(2)],'-');
    %         %
    %         tween = PtrTween(start_coords,end_coords,1,30,'inorm');
    %         plot(tween.vals(:,1),tween.vals(:,2),'ro');
    %
    % Example, relative:
    %       clearAbsAll; T_panDown = PtrTween(50, 100, 3, 10, 'linear',
    %       [],[], false), T_panDown.vals
    %
    % Example, misc:
    %        clearAbsAll; close all; o = PtrTween(-10, 10, 2, 100, 'sin', 1/2, [], true, false); plot(o.vals);
    %
    % @See also:        <none>
    %
    % @Requires:        Matlab v2012 or later
    %
    % @Author:          Pete R Jones
    %
    % @Creation Date:	28/01/2014
    % @Last Update:     28/01/2014
    %
    % @Current Verion:  1.0.0
    % @Version History: v1.0.0	PJ 28/01/2014    Initial build.
    %
    % @Todo:            relative slightly out?
    %                   relative very out for 'sin' !
    
    properties (GetAccess = 'public', SetAccess = 'private')
        isLooping = false;
        vals; % 1 column for each variable
        idx = 1;
        delta = 1; % increment direction
        isFinished = false;
        length;
    end
    
    %% ====================================================================
    %  -----CONSTRUCTOR/DESTRUCTOR METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')
        
        function obj = PtrTween(startVal, endVal, duration, Fr, func, auxParam, isLooping, isAbsolute, integerSteps)
            
            
            %% 1 Parse inputs
            % check for equal row-vectors
            if size(startVal,1) > 1
                startVal = startVal';
                endVal = endVal';
            end
            if ~all(size(startVal) == size(endVal))
                error('getTween:invalidInput','startVal and endVal must have common dimensions');
            end
            
            if nargin < 4 || isempty(Fr) % if Framerate not specified then 'd' will assumed to be the number of frames
                n = duration;
            else
                n = floor(Fr * duration);
            end
            if n < 1
                error('getTween:invalidInput','n must be > 0');
            end
            
            if nargin < 5 || isempty(func)
                func = 'linear';
            end
            
            if nargin < 6 || isempty(auxParam)
                auxParam = 1; % e.g., 1 loops per second
            end
            
            if nargin < 7 || isempty(isLooping)
                isLooping = false;
            end
            
            if nargin < 8 || isempty(isAbsolute)
                isAbsolute = true;
            end
            
            if nargin < 9 || isempty(integerSteps)
                integerSteps = false; % whether, if using relative steps, to enforce whole-numbers only
            end
            
            
            
            
            
            %% 2 Get interpolation index
            startPoint = min(.0001,1/n);
            endPoint = 1;
            
            switch lower(func)
                case 'linear'
                    i = linspace(startPoint,endPoint,n+1);
                case 'exp'
                    i = exp(linspace(log(startPoint),log(endPoint),n+1));
                case 'exp10'
                    i  = exp10(linspace(log10(startPoint),log10(endPoint),n+1));
                case 'log'
                    i  = log(linspace(exp(startPoint),exp(endPoint),n+1));
                case 'log10' % more pronounced
                    i  = log10(linspace(exp10(startPoint),exp10(endPoint),n+1));
                case 'norm'
                    i = normcdf(linspace(norminv(startPoint),norminv(endPoint-startPoint),n+1),0,1);
                case 'inorm'
                    tmp = norminv(linspace(startPoint,endPoint-startPoint,n+1),0,1);
                    i = (tmp + max(tmp)) / (max(tmp)*2);
                case 'sin'
                    t = (0:n) / Fr;    	% time vector
                    cf = auxParam; % frequency
                    i = sin(2 * pi * cf * t + 0);
                    
                otherwise
                    error('getTween:UnknownMethod','%s is an invalid function.\nFunction type must be one of: %s',func,strjoin(', ','linear','exp','exp10','log','log10','norm','inorm'));
            end
            
            if strcmpi(func, 'sin') % EXPERIMENTAL
                % ensure loops cleanly
                i(end) = i(1);
                i(1) = [];
            else
                % remove first, and ensure converges at 1 (e.g. for continuous
                % distributions such as norm)
                i(1) = [];
                i(end) = 1;
            end
            
            %% 3 Apply interpolation
            if strcmpi(func,'sin')
                obj.vals = (endVal+startVal)/2 + i'*diff([startVal,endVal])/2; % works a bit differently to others. oscillates between startVal and endVal, N times per second
            else
                i = repmat(i',1,size(startVal,2));
                startVal = repmat(startVal,n,1);
                endVal = repmat(endVal,n,1);
                obj.vals = startVal.*(1-i) + endVal.*i;
            end
            
            %% if relative then prefix startVal and differentiate
            if ~isAbsolute
                
                if strcmpi(func, 'sin') % EXPERIMENTAL - n.b. assumes vector not mat!!!!
                    obj.vals = diff(obj.vals);
                    n = length(obj.vals(2:end-1)); 
                    obj.vals =  [obj.vals(1); resample(obj.vals(2:end-1), n+1, n); obj.vals(end)];
                else
                    obj.vals = [startVal(1,:); obj.vals];
                    obj.vals = diff(obj.vals,[],1);
                end
                
                if integerSteps
                    dx = obj.vals;
                    n = length(dx)-1; %#ok
                    for i = 1:n;
                        obj.vals(i) = round(dx(i));
                        dx(i+1) = dx(i+1) + (dx(i) - obj.vals(i)); % add any remainder after rounding onto the next step
                    end
                    obj.vals(end) = round(dx(end)); % round last element
                end
            end
            
            
            %% store
            obj.isLooping = isLooping;
            obj.length = size(obj.vals, 1);
            
        end
        
        function obj = delete(obj)
        end
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')

        function x = get(obj)
            % get value
            x = obj.vals(obj.idx, :);
            
            % incremement counter
            obj.idx = obj.idx + obj.delta;
            
            % if passed end/start then either signal terminated, or if
            % looping then reverse increment direction (delta), and adjust
            % the counter appropriately
            if (obj.idx > obj.length) || (obj.idx < 0)
                if ~obj.isLooping
                    obj.isFinished = true;
                else
                    obj.delta = -obj.delta;
                    obj.idx = obj.idx + 2*obj.delta; 
                end
            end
            
        end
        
        % n.b. no looping or reverse directions currently supported
        function x = getAll(obj)
            % get value
            x = obj.vals(obj.idx:end, :);
            
            % incremement counter
            obj.idx = obj.length;
            obj.isFinished = true;
            
        end
        

    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS-----
    %$ ====================================================================
    
    methods(Static)
    end
    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
    
    methods(Access = 'private')
    end
    
end