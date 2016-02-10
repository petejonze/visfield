classdef VfAttentionGrabberFace < visfield.graphic.VfAttentionGrabber
	% ########.
    %
    %   http://www.perimetry.org/GEN-INFO/standards/IPS90.HTM
    %
    % VfAttentionGrabberFace Methods:
    %   * VfAttentionGrabberFace  	- Constructor.
    %   * ######        - ######.
    %
    % See Also:
    %   none
    %
    % Example:
    %   none
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 07/2014 : first_build\n
    %
    % @todo truncate
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================      
    
    properties (Constant)
    end
    
    properties (GetAccess = public, SetAccess = private)
        visual
        sound
        
        T_scale
        T_sway
        ivGraphicStub
        nFrames
        
        x_px
        y_px
        i = 1; % frame counter
    end

        
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = VfAttentionGrabberFace(winhandle, framerate, IMG_DIR, SND_DIR)
            % VfAttentionGrabberFace Constructor.
            %
            % @param    winhandle 	#####
            % @return   obj   	VfAttentionGrabberFace object
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % ####
            obj.visual = PtrVisual(fullfile(IMG_DIR, 'feedback', '500px-Happy_face.svg.png'), winhandle, .35);

            % init animation params
            d = 4; % N seconds max
            obj.T_scale = getTween(.22, .28, d, framerate, 'sin', 2);
            obj.T_sway = getTween(-10, 10, d, framerate, 'sin', 4);
            obj.nFrames = length(obj.T_scale);
            
            % #####
            obj.ivGraphicStub = ivis.graphic.IvGraphic('target', obj.visual.texture, 0, 0, obj.visual.width*2, obj.visual.height*2, winhandle); %/2 hack

            % init audio
            obj.sound = 0.1 * ivis.audio.IvAudio.getInstance().wavload(fullfile(SND_DIR, '173881__toam__xylophon-play-melody-c3-loop.wav')); 
        end
        
        %% == METHODS =====================================================
        
        
        function [] = init(obj, x_px, y_px)
            % Get x/y coordinates.
            %
            % @return   x   #####
            % @return   y   #####
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % set graphic position
            obj.x_px = x_px;
            obj.y_px = y_px;
            obj.ivGraphicStub.reset(x_px, y_px);

        end
         
        function [] = start(obj, playAudio)
            % #######.
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % parse inputs
            if nargin < 2 || isempty(playAudio)
                playAudio = true;
            end
            
            % start audio playing
            if playAudio
                blocking = false;
                ivis.audio.IvAudio.getInstance().play(obj.sound, [], blocking);
            end

            % reset frame counter
            obj.i = 1;
        end
        
        function [] = draw(obj, winhandle)
            % Get x/y coordinates.
            %
            % @return   x   #####
            % @return   y   #####
            %
            % @date     11/07/14
            % @author   PRJ
            %
            
            % draw visuals
            dstRect = CenterRectOnPointd(obj.visual.rect*obj.T_scale(obj.i), obj.x_px, obj.y_px);
            Screen('DrawTexture', winhandle, obj.visual.texture, [], dstRect, obj.T_sway(obj.i));
            
            % increment frame counter
            obj.i = obj.i + 1;
        end
        
        function [] = stop(obj)
            % Get x/y coordinates.
            %
            % @return   x   #####
            % @return   y   #####
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % stop audio playing
            ivis.audio.IvAudio.getInstance().stop();
        end
    end

end