classdef PtrVisual < handle
    %#####
    %
    %   dfdfdf
    %
    % @Requires the following toolkits: <none>
    %
    % @Constructor Parameters:
    %
    %     	######
    %
    %
    % @Example:         <none>
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
    % @Todo:            add 'crop' option (re: DcPointsBar.m)
    
    properties (GetAccess = 'public', SetAccess = 'private')
        image
        width
        height
        sourceRect
        rect % resized version of sourceRect
        destRect % rect + xy
        texture
        winhandle
        tween
        tweenLoop
        %
        x % these are the underlying real value numbers, unlike the integers, above
        y
        %
        isHidden = false
    end
    
    %% ====================================================================
    %  -----CONSTRUCTOR/DESTRUCTOR METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')
        
        function obj = PtrVisual(ImageOrFullFn, winhandle, dimScale, xy)
            
            % parse inputs
            if nargin < 3  || isempty(dimScale)
                dimScale = 1;
            end
            if nargin < 4  || isempty(xy)
                xy = [];
            end
                
            if ischar(ImageOrFullFn)
                [obj.image, ~, alpha] = imread(ImageOrFullFn,'png');
                if isempty(alpha)
                    alpha = ones(size(obj.image,1), size(obj.image,2))*255;
                end
                obj.image(:,:,4) = alpha(:,:); % add the transparency layer to the image (for trans. back.)
            else
                obj.image = ImageOrFullFn;
            end
            
            
            obj.texture = Screen('MakeTexture', winhandle, obj.image);
            obj.winhandle = winhandle;
            
            % calc raw source dimensions
            obj.width = size(obj.image, 2);
            obj.height = size(obj.image, 1);
            obj.sourceRect = [0 0 obj.width obj.height];
            
            % apply size scaling
            obj.width = round(obj.width * dimScale);
            obj.height = round(obj.height * dimScale);
            obj.rect = [0 0 obj.width obj.height];
            
            % apply positioning
            obj.destRect = obj.rect;
            if isempty(xy)
                % start centred in middle by default
                screenRect = Screen('Rect', winhandle);
                obj.destRect = CenterRectOnPoint(obj.rect, screenRect(3)/2, screenRect(4)/2);
                obj.x = obj.destRect(1);
                obj.y = obj.destRect(2);
            else
                obj.setXY(xy(1), xy(2));
            end
            
        end
        
        function obj = delete(obj)
        end
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')

        function [] = setXY(obj, x, y, centre)
            if nargin < 2 || isempty(x)
                x = obj.x;
            end
            if nargin < 3 || isempty(y)
                y = obj.y;
            end
            if nargin < 4 || isempty(centre)
                centre = false;
            end
            
            if centre
                obj.destRect = CenterRectOnPoint(obj.rect, x, y);
%                 [obj.x, obj.y] = RectCenter(obj.destRect);
                obj.x = obj.destRect(1);
                obj.y = obj.destRect(2);
            else
                % set
                obj.destRect = obj.rect + [round(x) round(y) round(x) round(y)];
                % store
                obj.x = x;
                obj.y = y;
            end
            
        end
        
        
        function x = getX(obj)
            %x = obj.destRect(1);
            x = obj.x;
        end
        function y = getY(obj)
            %y = obj.destRect(2);
            y = obj.y;
        end
        function mx = getMX(obj)
            mx = obj.x + obj.width/2;
        end
        function my = getMY(obj)
            my = obj.y + obj.height/2;
        end
        
        function isOff = isOffscreen(obj)
            [w, h]=Screen('WindowSize', obj.winhandle);
            isOff = (obj.destRect(1) > w) | (obj.destRect(3) < 0) | (obj.destRect(2) > h) | (obj.destRect(4) < 0);
        end
        
        function [] = nudge(obj, x, y)
            obj.x = obj.x + x;
            obj.y = obj.y + y;
            % set
            obj.destRect = obj.rect + [round(obj.x) round(obj.y) round(obj.x) round(obj.y)];
        end
        
        function [] = draw(obj)
            if ~obj.isHidden
                Screen('DrawTexture', obj.winhandle, obj.texture, obj.sourceRect, obj.destRect);
            end
        end
        
        function [] = nudgeAndDraw(obj, x, y)
            obj.nudge(x, y);
            obj.draw();
        end
        
        function [] = setXYAndDraw(obj, x, y, centre)
            if nargin < 4 || isempty(centre)
                centre = false;
            end
            
            obj.setXY(x,y,centre);
            obj.draw();
        end
        
        function [] = resize(obj, dimScale)
            % apply size scaling
            %obj.width = round(obj.width * dimScale);
            %obj.height = round(obj.height * dimScale);
            % not cumulative:
            obj.width = round(obj.sourceRect(3) * dimScale);
            obj.height = round(obj.sourceRect(4) * dimScale);

            obj.rect = [0 0 obj.width obj.height];
            [xx, yy] = RectCenter(obj.destRect);
            obj.destRect = CenterRectOnPoint(obj.rect, xx, yy);
        end

        
        function [] = nudgeRGBA(obj, rgba)
            obj.image(:,:,1) = obj.image(:,:,1) + rgba(1);
            obj.image(:,:,2) = obj.image(:,:,2) + rgba(2);
            obj.image(:,:,3) = obj.image(:,:,3) + rgba(3);
            obj.image(:,:,4) = obj.image(:,:,4) + rgba(4);
            
            obj.image = max(min(obj.image, 255), 0);
            
            obj.texture = Screen('MakeTexture', obj.winhandle, obj.image);
        end

        function [] = grayscale(obj)
            % convert to greyscale (using CCIR601 weights)
            L = obj.image(:,:,1)*0.2989 + obj.image(:,:,2)*0.5870 + obj.image(:,:,3)*0.1140;

            obj.image(:,:,1) = L;
            obj.image(:,:,2) = L;
            obj.image(:,:,3) = L;
            
            obj.texture = Screen('MakeTexture', obj.winhandle, obj.image);
        end
        
        
        function [] = hide(obj)
            obj.isHidden = true;
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