classdef VfStimulusClassic < visfield.graphic.VfStimulus
	% ########.
    %
    %   http://www.perimetry.org/GEN-INFO/standards/IPS90.HTM
    %
    % VfStimulusClassic Methods:
    %   * VfStimulusClassic  	- Constructor.
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
        IS_COLOUR = false;
        IS_REWARDABLE = true;
        PADDING_PX = 50;  % n.b., increase this number if a large amount of warping is required (i.e., to prevent image being cut off at the edges)
    end
    
    properties (GetAccess = public, SetAccess = private)
        % init: spatial parameters
        diameter_deg
        
        % init: temporal parameters
        stim_cycle_secs % cycle time (including the 'off' portion)
        stim_cycle_duty % percent of time for light to be 'on'
        stim_cycle_n    % number of times to flash
        timeElapsed_secs
        startTime_secs
        
        % init: audio parameters
        pahandle
        
        % trial-by-trial parameters
        x_px;
        y_px;
        stimLuminance_norm
        tex = [];
        shader = [];
        srcrect = [NaN NaN NaN NaN];
        drawrect = [NaN NaN NaN NaN];
        
        
      	hInternalShader = fspecial('gaussian',7, 7);
            
        stimIsForcedOn = false
    end

        
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = VfStimulusClassic(goldmanType, stim_cycle_on_secs, stim_cycle_off_secs, stim_cycle_n, pahandle)
            % VfStimulusClassic Constructor. If pahandle is omited then no
            % audio will be played
            %
            % @param    winhandle 	#####
            % @return   obj   	VfStimulusClassic object
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % parse inputs
            if nargin < 5 || isempty(pahandle)
                pahandle = [];
            end
            
            % Initialise spatial info
            obj.diameter_deg = obj.getGoldmannDiameter(goldmanType);
            
            % Initialise temporal info
            obj.stim_cycle_secs = stim_cycle_on_secs + stim_cycle_off_secs; % 0.3; % cycle time (including the 'off' portion)
            obj.stim_cycle_duty = stim_cycle_on_secs/obj.stim_cycle_secs*100; % 2/3*100; % percent of time for light to be 'on'
            obj.stim_cycle_n = stim_cycle_n; % number of times to flash
            
            % Initialise audio info
            if ~isempty(pahandle)
                % prepare schedule
                PsychPortAudio('UseSchedule', pahandle, 1, stim_cycle_n*2-1); % *2-1 because the gaps between sounds also take up slots(!)

                % create 1 1kHz sound of duration 'stim_cycle_on_secs'
                audio = ivis.audio.IvAudio.getInstance();
                d = stim_cycle_on_secs;  	% duration, in seconds
                testChans = audio.outChans; % both speakers
                lvlFactor = 0.1;           % attenuate it to some arbitrarily low level to avoid blowing anybody's eardrums
                x = audio.rampOnOff(audio.padChannels(audio.getPureTone(200,audio.Fs,d)*lvlFactor, testChans, audio.outChans));

                % Create audio buffers prefilled with the sound:
                pabuffer = PsychPortAudio('CreateBuffer', [], x);

                % This command code in a slot tells to take a break (+1) before processing
                % the following of the following slot. The (+16) means to wait until the
                % given amount of seconds has elapsed since start of playback of the most
                % recent soundbuffer. Therefore it defines a relative spacing between
                % playback of successive sound buffers.
                % Note that there are more command codes available (see PsychPortAudio AddToSchedule?).
                % These allow for other types of timing, just don't make sense in this
                % demo.
                cmdCode = 1 + 16;

                % Add 1st sound buffer
                PsychPortAudio('AddToSchedule', pahandle, pabuffer);

                for i = 2:stim_cycle_n                 
                    % Tell pasound to start playing the following buffer exactly 'stim_cycle_secs' seconds
                    % after playback of the previous buffer has started:
                    PsychPortAudio('AddToSchedule', pahandle, -cmdCode, obj.stim_cycle_secs);
                    PsychPortAudio('AddToSchedule', pahandle, pabuffer);
                end

                % store pahandle
                obj.pahandle = pahandle;
            end
        end
        
        %% == METHODS =====================================================
        
        
        function [] = setLocation(obj, x_px, y_px) % interface implementation
            % store
            obj.x_px = x_px;
            obj.y_px = y_px;
        end
        
        function [] = setLuminance(obj, stimLuminance_norm) % interface implementation
            % store
            obj.stimLuminance_norm = stimLuminance_norm;
        end
        
        function [] = initGraphic(obj, winhandle, stimDiameter_px, warper, shader, back) % interface implementation
            % release any previous textures from RAM
            if ~isempty(obj.tex)
                Screen('Close', obj.tex)
            end
            
            % store shader handle (if any)
            obj.shader = shader;

            % create dot shape (pixel-by-pixel matrix)
%             I_original = myEllipse(stimDiameter_px /2);
            
%             if rand()<0.5
            I_original = filter2(obj.hInternalShader, padarray(Ellipse(stimDiameter_px/2),[obj.PADDING_PX obj.PADDING_PX],0,'both') );
            I_original = filter2(obj.hInternalShader, I_original );
%             else
%             I_original = Ellipse(stimDiameter_px/2);
%             end
            
%             gazex_cm, gazey_cm, obj.x_px, obj.y_px
            
%             I_warped = warper.warp(I_original, gazex_cm, gazey_cm, obj.x_px, obj.y_px, obj.PADDING_PX);
% I_warped = warper.warp(I_original, gazex_cm, gazey_cm, 1920/2, 1080/2, 30);

I_warped = warper.warp(I_original, obj.x_px, obj.y_px, 0);
% I_warped = padarray(I_original,[10 10],0,'both');


s = regionprops(I_warped>0.1, 'centroid','BoundingBox');
% s.Centroid
% [(s.Centroid(1)-(stimDiameter_px+obj.PADDING_PX)/2) (s.Centroid(2)-(stimDiameter_px+obj.PADDING_PX)/2)]


% What is this for?? Surely we *want* the location to be shifted??
% xy_shift = floor(s.Centroid-size(I_warped)/2)
% 
% obj.x_px = obj.x_px + xy_shift(1);
% obj.y_px = obj.y_px + xy_shift(2);


            % set luminance
            I_warped = I_warped*obj.stimLuminance_norm;
            
%             I_warped = I_warped*0.1;
            
%             size(I_warped)
            
%             I_warped
% visfield.graphic.VfStimulusWarper.plot(I_original, I_warped, obj.x_px, obj.y_px, 1920, 1080);
% dfdfdfdfdf                     
            
% idx = find(I_warped<back);
% n = numel(back);

% I_warped(1:10,1:10)
% back(1:10,1:10)

% I_warped=max(I_warped,back);

% I_warped(I_warped<0.90) = 0;
% size(I_warped)
% size(back)

I_warped = max(I_warped, back);
% I_warped(I_warped<back) = 0;
% idx = I_warped<back;


I_warped = I_warped(round(s(1).BoundingBox(2):s(1).BoundingBox(2)+s(1).BoundingBox(4)),round(s(1).BoundingBox(1):s(1).BoundingBox(1)+s(1).BoundingBox(3)));


            % make background transparent
%             z = mean(mean(back))*1;
%             z = back*1.5;
%             alpha = (I_warped>z);
%             I_warped = cat(3,I_warped,alpha);
            I_warped = repmat(I_warped,[1 1 2]);
    
%             I_warped(find(idx)+numel(idx)) = 1;
%             I_warped(idx) = back(idx);
%             I_warped(idx+n) = 255;
%             I_warped
% back

% I_warped(:,:) = 1;

% save('tmp.mat','I_warped')
   
            % create texture
%             obj.tex = Screen('MakeTexture', winhandle, uint8(I_warped));
            obj.tex = Screen('MakeTexture', winhandle, I_warped, [], [], 1); % high precision (16 bit)

         	% compute bounding box
            obj.srcrect = [0 0 size(I_warped,2) size(I_warped,1)];
            obj.drawrect = CenterRectOnPoint(obj.srcrect, obj.x_px, obj.y_px);
        end
         
        function [] = start(obj)
            % Get x/y coordinates.
            %
            % @return   x   #####
            % @return   y   #####
            %
            % @date     11/07/14
            % @author   PRJ
            %

            % check ready to go
            if isempty(obj.x_px) || isempty(obj.y_px)
                error('Location must first be set, using setLocation()');
            elseif isempty(obj.stimLuminance_norm)
                error('Luminance must first be set, using setLuminance()');
            elseif isempty(obj.tex) || isempty(obj.drawrect)
                error('Graphic must first be initialised, using initGraphic()');
            end
            
            % note start time
            obj.startTime_secs = GetSecs();
            obj.timeElapsed_secs = 0;
            
            % start audio playing
            if ~isempty(obj.pahandle)
                PsychPortAudio('Start', obj.pahandle);
            end
            
            % init misc
            obj.stimIsForcedOn = false;
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
            obj.timeElapsed_secs = GetSecs() - obj.startTime_secs;
            
            % compute whether stimulus should be drawn
            if obj.stimIsForcedOn
                stimIsOn = true;
            else
                cycle = obj.timeElapsed_secs/obj.stim_cycle_secs;
                nCyclesCompleted = floor(cycle);
                duty = square(cycle*2*pi, obj.stim_cycle_duty); % -1 or 1
                stimIsOn = (duty > 0) && (nCyclesCompleted < obj.stim_cycle_n);
            end

            % !Draw!
            if stimIsOn
%                 Screen('FillOval', winhandle, obj.stimLuminance_norm, obj.drawrect);
% obj.srcrect
% obj.drawrect
obj.shader = [];
                Screen('DrawTexture', winhandle, obj.tex, obj.srcrect, obj.drawrect, [], [], [], [], obj.shader);
            end
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

            % stop any audio playing
            
            if ~isempty(obj.pahandle)
                PsychPortAudio('Stop', obj.pahandle);
            end
        end
        
        function [] = forceAlwaysOn(obj)
            % ######.
            %
            % @date     24/07/14
            % @author 
            %
            obj.stimIsForcedOn = true;
        end
    end
    
    
        
    %% ====================================================================
    %  -----STATIC PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Static, Access = public)
        function diameter_deg = getGoldmannDiameter(goldmanType)
            switch lower(goldmanType)
                case 'i'
                    diameter_deg = 6.5 / 60; % minutes per arc -> degrees visual angle
                case 'ii'
                    diameter_deg = 13 / 60;
                case 'iii'
                    diameter_deg = 26 / 60;
                case 'iv'
                    diameter_deg = 52 / 60;
                case 'v'
                    diameter_deg = 104 / 60;
                otherwise
                    error('Unknown grid point type: %s (known types: iii)')
            end
        end
    end

end