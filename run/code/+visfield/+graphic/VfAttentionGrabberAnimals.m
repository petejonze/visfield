classdef VfAttentionGrabberAnimals < visfield.graphic.VfAttentionGrabber
	% ########.
    %
    %   http://www.perimetry.org/GEN-INFO/standards/IPS90.HTM
    %
    % VfAttentionGrabberAnimals Methods:
    %   * VfAttentionGrabberAnimals  	- Constructor.
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
        visuals
        T_scale
        T_sway
        ivGraphicStub
        sounds
        nFrames
        
        x_px
        y_px
        i = 1; % frame counter
        
        nAnimals
        idx
    end

        
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = VfAttentionGrabberAnimals(winhandle, duration_secs, framerate, IMG_DIR, SND_DIR)
            % VfAttentionGrabberAnimals Constructor.
            %
            % @param    winhandle 	#####
            % @return   obj   	VfAttentionGrabberAnimals object
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % load graphics
            IMG_DIR = fullfile(IMG_DIR, 'animals');
            imgFiles = dir(fullfile(IMG_DIR, '*.png'));
            %
            % get file names
            if isempty(imgFiles)
                error('VfAttentionGrabberAnimals:loadAll','No png images found in %s', IMG_DIR)
            end
            imgFullFns = fullfile(IMG_DIR, {imgFiles.name}); % convert to cell, and prepend path
            %
            % load each file, store in obj.visuals
            nGraphics = length(imgFullFns);
            obj.visuals = cell(1,nGraphics);
            for j = 1:nGraphics
                obj.visuals{j} = PtrVisual(imgFullFns{j}, winhandle, 1);
            end

            % load audio
            SND_DIR = fullfile(SND_DIR, 'animals') ;
            obj.sounds = ivis.audio.IvAudio.getInstance().loadAll(SND_DIR, '*.wav', .1); % .1 intensity hack
            nSounds = length(obj.sounds);
            if nSounds ~= nGraphics
                error('VfAttentionGrabberAnimals:InitFail','N animal images (%i) cannot be different than N animal sounds (%i)', nGraphics, nSounds);
            end
            
            % init
            obj.nAnimals = nSounds;

            % init animation params
            obj.T_scale = PtrTween(.4, .6, duration_secs, framerate, 'sin', 2);
            obj.T_sway = PtrTween(-20, 20, duration_secs, framerate, 'sin', 4);
            obj.nFrames = obj.T_scale.length;
            
            % #####
            obj.ivGraphicStub = ivis.graphic.IvGraphic('target', obj.visuals{1}.texture, 0, 0, obj.visuals{1}.width, obj.visuals{1}.height, winhandle); % use first as arbitrary exemplar
        end
        
        %% == METHODS =====================================================
        
        
        function [] = init(obj, x_px, y_px, idx)
            % Get x/y coordinates.
            %
            % @param   x_px 	#####
            % @param   y_px     #####
            % @param   idx      #####
            %
            % @date     11/07/14
            % @author   PRJ
            %

            if nargin < 4 || isempty(idx)
                % select a random animal to play
                idx = randi(obj.nAnimals);
            end
            obj.idx = idx;
            
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
            obj.T_sway.reset();
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
            dstRect = CenterRectOnPointd(obj.visuals{obj.idx}.sourceRect*obj.T_scale.get(), obj.x_px, obj.y_px);
            Screen('DrawTexture', winhandle, obj.visuals{obj.idx}.texture, [], dstRect, obj.T_sway.get());
            
            % increment frame counter
            obj.i = obj.i + 1;
        end
        
        function [] = stop(obj) %#ok
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