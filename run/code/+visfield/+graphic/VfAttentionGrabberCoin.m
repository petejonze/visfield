classdef VfAttentionGrabberCoin < visfield.graphic.VfAttentionGrabber
	% ########.
    %
    %   http://www.perimetry.org/GEN-INFO/standards/IPS90.HTM
    %
    % VfAttentionGrabberCoin Methods:
    %   * VfAttentionGrabberCoin  	- Constructor.
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
        T_fade
        ivGraphicStub
        nFrames
        
        x_px
        y_px
        i = 1; % frame counter
        
        isInColour
    end

        
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = VfAttentionGrabberCoin(winhandle, duration_secs, framerate, IMG_DIR, SND_DIR, isInColour)
            % VfAttentionGrabberCoin Constructor.
            %
            % @param    winhandle 	#####
            % @return   obj   	VfAttentionGrabberCoin object
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % load graphics
            fn = fullfile(IMG_DIR, 'feedback', 'gold_coin.png');
            obj.visual = PtrVisual(fn, winhandle);

            % load audio
            fn = fullfile(SND_DIR, 'feedback', '91924__benboncan__till-with-bell.wav');
            obj.sound = ivis.audio.IvAudio.getInstance().wavload(fn);

            % set whether to show in colour
            obj.isInColour = isInColour;
            
            % init animation params
            obj.T_scale = PtrTween(.4, 1, duration_secs, framerate, 'log10');
            obj.T_fade = PtrTween(1, 0, duration_secs, framerate, 'log10');
            obj.nFrames = obj.T_scale.length;
            
            % #####
            obj.ivGraphicStub = ivis.graphic.IvGraphic('target', obj.visual.texture, 0, 0, obj.visual.width, obj.visual.height, winhandle);
        end
        
        %% == METHODS =====================================================
        
        
        function [] = init(obj, x_px, y_px)
            % Get x/y coordinates.
            %
            % @param   x_px 	#####
            % @param   y_px     #####
            % @param   idx      #####
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
            obj.T_scale.reset();
            obj.T_fade.reset();
            obj.i = 1;
        end
        
        function [] = draw(obj, winhandle)
            % #######.
            %
            % @param    winhandle   #######
            %
            % @date     11/07/14
            % @author   PRJ
            %
            
            % draw visuals
            dstRect = CenterRectOnPointd(obj.visual.sourceRect*obj.T_scale.get(), obj.x_px, obj.y_px);
            Screen('DrawTexture', winhandle, obj.visual.texture, [], dstRect, [], [], obj.T_fade.get());

            % increment frame counter
            obj.i = obj.i + 1;
        end
        
        function [] = stop(obj)
            % ######.
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % stop audio playing
            ivis.audio.IvAudio.getInstance().stop();
        end
    end

end