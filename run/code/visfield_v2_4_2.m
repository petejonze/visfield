function Zest = visfield_v2_4_2(metaParams, gridParams, stimParams, luxParams, graphicParams, paradigm, eyeParams, audioParams)    
% Example RE-ASTP test script
%
% Requires:         To be downloaded seperately:   
%                    - PsychToolBox v3 (needs 
%                   Included in this download:
%                    - Zest toolbox
%                    - EyeX_SDK
%                    - fig-matlab toolbox
%                    - ivis toolbox
%                    - PsychTestRig toolbox, 
%
% Matlab:           v2012 onwards
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
%
% Example:          ptr -run visfield
%                   > NB:
%                    - files in visfield/run/toolkits must be added to the Matlab path before running
%                    - PsychTestRig must be setup ("ptr -setup")
%                    - assumes directory structure of: .../visfield/run/visfield_v2_4_2.m
% 
% Version History:  1.0.0	PJ  07/07/2014    Initial build.
%                   1.1.0	PJ  18/07/2014    Screen calibration, tracker calibration, myStimulus placement, myStimulus selection/adaptation. Still no support for limited-range gamma tables.
%                   1.2.0	PJ  22/07/2014    First functional (proof-of-concept) build.  Still no support for limited-range gamma tables.
%                   1.3.0	PJ  31/07/2014    Stationarity criteiron (trial onset). Heavy rewriting/streamlining.
%                   1.4.0	PJ  ??/08/2014    Pilot version 1 (worked well, but only with some people)
%                   1.5.0	PJ  30/09/2014    Tobii EyeX pilot version 1 : rough_results_average_rightEye.png
%                   1.6.0	PJ  20/10/2014    Tobii EyeX pilot version 2 : reworked grid. Attempting to refine various aspects. Cleaned up
%                   1.7.0	PJ  01/12/2014    Used for first experiment
%                   2.0.0	PJ  09/03/2015    Attempt at a rapid version, using my own eyex Matlab binding (which provides distance info), and a more intelligent prior.
%                                               - changed to Goldmann III (as per HFA) rather than IV
%                                               - changed to using ZEST algorithm (involved whole new .visfield packge)
%                   2.1.0	PJ  08/06/2015    Misc prcoedural modifications
%                   2.2.0   PJ  13/07/2015    For use with new 10-bit system
%                                               - stop background changing luminance when pseudogray disabled
%                                               - implemented new background calib
%                                               - removed redundant inputs
%                   2.3.0   PJ  15/07/2015    Miscellaneous tweeks to improve performance
%                   2.4.0   PJ  17/07/2015    Coninuted refinements
%                                               - Added istance calibration
%                                               - Changed logic so that classifier box now specified in degrees (and is sensitive to viewing distance), and dimensions changed by calling the classifier, rather than indirectly via the graphic size
%                                               - Tweaked logic for carying classifier-relaxtion with eccentricity
%                   2.4.2   PJ  10/02/2016    First Beta upload
%                                               
%
% Copyright 2016 : P R Jones
% *********************************************************************
% 

    %%%%%%%
    %% 1 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Very basic init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        fprintf('\nSetting up the basics...\n');
        
        %-------------Check OS/Matlab version------------------------------
        if ~strcmpi(computer(),'PCWIN')
            error('This code has only been tested on Windows 7 running 32-bit Matlab\n  Detected architecture: %s', computer());
        end
        
       	%-------------Ready workspace-------------------------------------- 
        tmp = javaclasspath('-dynamic');
        clearJavaMem();
        close all;
        if length(tmp) ~= length(javaclasspath('-dynamic'))
            % MATLAB calls the clear java command whenever you change
            % the dynamic path. This command clears the definitions of
            % all Java classes defined by files on the dynamic class
            % path, removes all variables from the base workspace, and
            % removes all compiled scripts, functions, and
            % MEX-functions from memory.
            error('clearJavaMem:MemoryCleared','clearJavaMem has modified the java classpath (any items in memory will have been cleared)\nWill abort, since this is highly likely to lead to errors later.\nTry running again, or see ''help PsychJavaTrouble'' for a more permenant solution\n\ntl;dr: Try running again.');
        end

        %-------------Check for requisite toolkits-------------------------
        AssertPTR();
        AssertOpenGL(); % PTB-3 correctly installed? Abort otherwise.

        %-------------Check classpath--------------------------------------
        ivis.main.IvMain.checkClassPath();

        %-------------Hardcoded User params--------------------------------  
        IN_DEBUG_MODE = false; % true;
        IN_FINAL_MODE = false;
        % media files
        RESOURCES_DIR   = fullfile('..', 'resources');
        SND_DIR         = fullfile(RESOURCES_DIR, 'audio', 'wav');
        IMG_DIR         = fullfile(RESOURCES_DIR, 'images');
        VID_DIR         = fullfile('..', '..', '..', 'acuity', 'run', 'resources', 'video');   
        LOG_RAW_DIR     = fullfile('..', '..', 'data', '__EYETRACKING', 'raw');
        LOG_DAT_DIR     = fullfile('..', '..', 'data', '__EYETRACKING', 'data');
        samplingRate_hz = 60;
        
        %-------------Add any requisite paths------------------------------ 
        import ivis.main.* ivis.classifier.* ivis.video.*  ivis.broadcaster.* ivis.math.* ivis.graphic.* ivis.audio.* ivis.log.* ivis.calibration.*;
        import visfield.graphic.* visfield.math.* visfield.zest.*

        %-------------Display key params to user---------------------------
        dispStruct(metaParams)

        %-------------Assert correct eye config has been loaded------------
        if ~IN_DEBUG_MODE
            eyeCheck = get1ofMInput('[L]eft or [R]ight Eye? ', {'L','R'});
            if strcmpi(eyeCheck, 'l')
                eyeCheck = 'left';
            else
                eyeCheck = 'right';
            end
            if isempty(regexp(metaParams.cfgID, eyeCheck, 'once'))
                error('Stated eye (%s) does not match config file name (%s)', eyeCheck, metaParams.cfgID)
            end
        else
            warning('RUNNING IN DEBUG MODE');
        end


    %%%%%%%
    %% 2 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Validate User Inputs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        fprintf('\nVaidating inputs...\n');
    
        %-------------gridParams-------------------------------------------
        p = inputParser; p.StructExpand = true;
        p.addParameter('dB_max',                      	@isPositiveNum);
        p.addParameter('doPlot',                      	@islogical);
        p.addParameter('goldmann',                    	@ischar);
        p.addParameter('COMMENT',                    	@ischar);
        p.parse(gridParams);
        
        %-------------stimParams-------------------------------------------
        p = inputParser; p.StructExpand = true;
        p.addParameter('screenMargins_deg',          	@(x)isempty(x) || length(x)==4);
        p.addParameter('maxPlaceAttempts',            	@isPositiveInt);
        p.addParameter('calibMargins_deg',          	@(x)all(isnumeric(x)) && length(x)==4);
        p.addParameter('stim_cycle_on_secs',           	@isPositiveNum);
        p.addParameter('stim_cycle_off_secs',         	@isNonNegativeNum);
        p.addParameter('stim_cycle_n',                	@isPositiveInt);
        p.addParameter('stim_audio',                 	@islogical);
        p.addParameter('additionalGrabberMargins_px', 	@(x)all(isnumeric(x)) && length(x)==4);
        p.addParameter('minDistFromCentre_px',         	@isPositiveNum);
        p.addParameter('minDistFromTopRight_px',     	@isPositiveNum);
        p.addParameter('minDistFromTopLeft_px',       	@isPositiveNum);
        p.addParameter('useStimRamping',                @islogical);
        p.addParameter('useStimWarping',                @islogical);
        p.addParameter('useLegacyMode',                 @islogical);
        p.addParameter('COMMENT',                     	@ischar);
        p.parse(stimParams);
        
        %-------------luxParams--------------------------------------------
        p = inputParser; p.StructExpand = true;
        p.addParameter('is10Bit',                    	@islogical);
        p.addParameter('useBitstealing',              	@islogical);
        p.addParameter('useCompressedGamma',           	@islogical);
        p.addParameter('bkgdLum_cdm2',                 	@isPositiveNum);
        p.addParameter('deltaLum_min_cdm2',           	@isPositiveNum);
        p.addParameter('deltaLum_max_cdm2',            	@isPositiveNum);
        p.addParameter('maxAbsLum_cdm2',               	@isPositiveNum);
        p.addParameter('screenCalibRaw',              	@ischar);
        p.addParameter('screenCalibFittedBgd',          @ischar);
        p.addParameter('COMMENT',                       @ischar);
        p.parse(luxParams);
        
        %-------------graphicParams----------------------------------------
        p = inputParser; p.StructExpand = true;
        p.addParameter('screenNum',                   	@isNonNegativeInt);
        p.addParameter('Fr',                         	@isPositiveInt);
        p.addParameter('screenWidth_px',              	@isPositiveInt);
        p.addParameter('screenHeight_px',            	@isPositiveInt);
        p.addParameter('screenWidth_cm',              	@isPositiveNum);
        p.addParameter('screenHeight_cm',              	@isPositiveNum);
        p.addParameter('assumedViewingDistance_cm',    	@isPositiveNum);
        p.addParameter('useGUI',                      	@islogical);
        p.addParameter('COMMENT',                     	@ischar);
        p.parse(graphicParams);
        
        %-------------paradigm---------------------------------------------
        p = inputParser; p.StructExpand = true;
        p.addParameter('videoAfterNTrials',            	@isPositiveNum);
        p.addParameter('suppressVideoOnTrial1',        	@islogical);
        p.addParameter('showTrackBoxDuringVid',       	@islogical);
        p.addParameter('runIntroCalib',                	@islogical);
        p.addParameter('nSecsRqdToBreakVid',           	@isPositiveNum);
        p.addParameter('trialInitContactThreshold_secs',@isPositiveNum);
        p.addParameter('delayMin_secs',                	@isNonNegativeNum);
        p.addParameter('delaySigma_secs',             	@isNonNegativeNum);
        p.addParameter('delayMax_secs',               	@isPositiveNum);
        p.addParameter('trialDuration_secs',          	@isPositiveNum);
        p.addParameter('maxNTestTrials',               	@isPositiveInt);
        p.addParameter('attentionGrabberType',        	@(x)ismember(x,{'VfAttentionGrabberFace'}));
        p.addParameter('refixationType',               	@(x)ismember(x,{'controltrial','animalsprite'}));
        p.addParameter('rewarder_type',               	@(x)ismember(x,{'coin','animalsprite'}));
        p.addParameter('rewarder_duration_secs',       	@isPositiveNum);
        p.addParameter('rewarder_playGraphics',       	@islogical);
        p.addParameter('rewarder_playAudio',           	@islogical);
        p.addParameter('rewarder_isColour',           	@islogical);
        p.addParameter('stationarity_nPoints',        	@isPositiveInt);
        p.addParameter('stationarity_criterion_degsec',	@isPositiveNum);
        p.addParameter('COMMENT',                     	@ischar);
        p.parse(paradigm);

        %-------------eyeParams--------------------------------------------
        p = inputParser; p.StructExpand = true;
        p.addParameter('ivisVersion',                  	@isPositiveNum);
        p.addParameter('npoints',                      	@isPositiveNum);
        p.addParameter('relaxClassifierAfterNdegs',  	@isPositiveNum);
        p.addParameter('maxPathDeviation_px',         	@isPositiveNum);
        p.addParameter('boxdims_uncalibrated_deg',    	@(x)length(x)==2 && all(isPositiveNum(x)));
        p.addParameter('boxdims_calibrated_deg',      	@(x)length(x)==2 && all(isPositiveNum(x)));
        p.addParameter('type',                        	@(x)ismember(x,{'tobii','mouse'}));
        p.addParameter('eye',                        	@(x)ismember(x,[0 1 2]));
        p.addParameter('driftCorrectionWeight',      	@(x)(x>=0 && x <= 1));
        p.addParameter('calibration_range_criterion_px',@isPositiveNum);
        p.addParameter('recalib_falseNegativeLim',    	@(x)(x>=0 && x <= 1));
        p.addParameter('recalib_afterNTrials',         	@isPositiveNum);
        p.addParameter('calibrateDistanceAtStart',    	@islogical);
        p.addParameter('COMMENT',                       @ischar);
        p.parse(eyeParams);
        
        %-------------audioParams------------------------------------------
        p = inputParser; p.StructExpand = true;
        p.addParameter('devID',                       	@(x)isempty(x) || isNonNegativeInt(x));
        p.addParameter('playBackground',              	@islogical);
        p.addParameter('nTracksToQueue',              	@isPositiveInt);
        p.addParameter('resetAfterNTrials',           	@isPositiveInt);
        p.addParameter('COMMENT',                    	@ischar);
        p.parse(audioParams);
        

    %%%%%%%%
    %% 3  %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Preliminary computations and validation %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
        %-------------Assert correct eye specified in config---------------
        if ~IN_DEBUG_MODE
            if strcmpi(eyeCheck, 'l') && (eyeParams.eye~=0)
                error('Config file indicated left eye, but does not specify left eye (0) in its eyeParams.eye parameter');
            elseif strcmpi(eyeCheck, 'r') && (eyeParams.eye~=1)
                error('Config file indicated right eye, but does not specify right eye (0) in its eyeParams.eye parameter');
            end
        end

        %-------------Check luminance params-------------------------------
        % step size minimum on at 8-bit system is:
        %   1/(2^8) by default
        %   1/(2^10.7) if using bitstealing
        %   1/(2^9) if using a compressed LUT (50% size)
        %   1/(2^11.7) if using both bitstealing and a compressed LUT
        if luxParams.is10Bit
            b = 10;
        else
            b = 8;
        end
        if luxParams.useBitstealing
            b = b + 2.7; % e.g., 10.7
        end
        if luxParams.useCompressedGamma
            error('implement me!')
            b = b + 1;
        end
        unitStepSize_norm = 1/(2^b);

        % luxParams.maxAbsLum_cdm2 is the greatest target luminance level (n.b., 
        % minLum_cdm2 is the smallest step in luminance after the
        % background baseline
        % level, where not otherwise stated appears to = (TargLevel -
        % BackLevel)
        dynamicRange_db = 10*log10(luxParams.deltaLum_max_cdm2/luxParams.deltaLum_min_cdm2);

        % check luminance values (more below, once we have the calibration data)
       	if abs(dynamicRange_db - 10*log10(luxParams.deltaLum_max_cdm2/luxParams.deltaLum_min_cdm2)) > 0.01
            error('User specified dynamic range (%1.3f) does not match computed range (%1.3f)', dynamicRange_db, 10*log10(luxParams.deltaLum_max_cdm2/luxParams.deltaLum_min_cdm2))
        end

        %-------------Check dB staircase params----------------------------
        %if gridParams.dB_min > dynamicRange_db
        %    error('gridParams.dB_max (%1.3f) cannot be outside the dynamic range (%1.3f)', gridParams.dB_max, dynamicRange_db);
        %end
        if gridParams.dB_max ~= floor(dynamicRange_db)
            error('gridParams.dB_max (%1.3f) should equal the FLOOR of the dynamic range (%1.3f / %i)', gridParams.dB_max, dynamicRange_db, floor(dynamicRange_db));
        end 
        
        %-------------Check screen params----------------------------------
        if any(stimParams.screenMargins_deg.*[1 1 -1 -1] < 1)
            error('A minimum of 1 degree margin is required on all four edges of the screen\n  For example: [3 1 -3 -1]\nYou entered: [%1.2f %1.2f %1.2f %1.2f]', stimParams.screenMargins_deg)
        end
        
      	%-------------Check stimulus timings-------------------------------   
        % check stimParams.stim_cycle_on_secs (1/2)
        % less than 100 leads to summation issues, more than 200 may have
        % problems with saccades:
        % http://www.perimetry.org/articles/Conventional-Perimetry-Part-I.pdf
        if IN_FINAL_MODE && (stimParams.stim_cycle_on_secs < 0.1 || stimParams.stim_cycle_on_secs > 0.2)
            error('User specified myStimulus duration (%1.3f secs) must lie between 100 and 200 milliseconds', stimParams.stim_cycle_on_secs);
        end
        % check stimParams.stim_cycle_on_secs (2/2)
        x = mod(stimParams.stim_cycle_on_secs * graphicParams.Fr, 1);
        if min(x, abs(1-x)) > 0.01
            error('User specified myStimulus duration (%1.3f secs) must be an integer multiple of stimParams.stim_cycle_on_secs*framerate (%i)', stimParams.stim_cycle_on_secs, graphicParams.Fr);
        end
        %
        % ensure that myStimulus 'off' duration is also a multiple of the
        % framerate
        x = mod(stimParams.stim_cycle_off_secs * graphicParams.Fr, 1);
        if min(x, abs(1-x)) > 0.01
            error('User specified myStimulus ''off'' duration (%1.3f secs) must be an integer multiple of stimParams.stim_cycle_off_secs*framerate (%i)', stimParams.stim_cycle_off_secs, graphicParams.Fr);
        end
        
        %-------------Check input/output directories exist-----------------
        if ~exist(SND_DIR, 'dir')
            error('Resources directory not found: %s\nPwd: %s', SND_DIR, pwd());
        end
        if ~exist(IMG_DIR, 'dir')
            error('Resources directory not found: %s\nPwd: %s', IMG_DIR, pwd());
        end
        if ~exist(VID_DIR, 'dir')
            error('Resources directory not found: %s\nPwd: %s', VID_DIR, pwd());
        end
      
        %-------------Cannot be in debug mode if IN_FINAL_MODE==true-------
        if IN_DEBUG_MODE && IN_FINAL_MODE
            error('Inconsistent. Cannot be in debug mode if in final mode');
        end
        
        %-------------Misc-------
        if IN_FINAL_MODE && gridParams.doPlot
            error('GUI plots must be disabled.\nThese appear to cause the main window to lose focus, resulting in:\n  - Windows menu bar showing up\n  - Screen reverting to 8-bit mode\n  - Performance takes a massive hit\n');
        end        
    
    %%%%%%%%
    %% 4  %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialise variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        if IN_DEBUG_MODE
            showFixationMarker = true;
            eyetracker.fixationMarker = 'whitedot';
        else
            % can be toggled during the experiment with 'f' key
            showFixationMarker = false;
            eyetracker.fixationMarker = 'none';
        end
        

    %%%%%%%%
    %% 5  %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Load calibration and intinitialise uniform background %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % get calibration: raw
        fn = fullfile('.', 'calib', luxParams.screenCalibRaw);
        calib = load(fn);
        % set screen dimensions
        calib.marginLeft_px = calib.x_px(1,1);
        calib.marginRight_px = calib.x_px(1,end); % screenWidth_px-calib.x_px(1,end)
        calib.marginTop_px = calib.y_px(1,1);
        calib.marginBottom_px = calib.y_px(end,1); % screenHeight_px-calib.y_px(end,1)
        
        % get calibration: uniformity-corrected background (derived from
        % above, but computed in advance for speed/convenience)
        back_fn = fullfile('.', 'calib', luxParams.screenCalibFittedBgd);
        calibBgrd = load(back_fn);
        idx = abs(luxParams.bkgdLum_cdm2 - calibBgrd.targAbs_cdm2) < 0.01; % calibBgrd.targAbs_cdm2 == luxParams.bkgdLum_cdm2
        if ~any(idx)
            error('no background calibration found for luxParams.bkgdLum_cdm2 == %1.2f', luxParams.bkgdLum_cdm2);
        end
        backgroundMatrix = calibBgrd.backgroundMatrix(:,:,idx);
        
        % check that backgroundMatrix matches screen dimensions
        if calibBgrd.screenWidth_px ~= graphicParams.screenWidth_px
            error('luminance calibration pixel width (%i) does not match that of the specified screen (%i)', calibBgrd.screenWidth_px, graphicParams.screenWidth_px)
        end
        if calibBgrd.screenHeight_px ~= graphicParams.screenHeight_px
            error('luminance calibration pixel height (%i) does not match that of the specified screen (%i)', calibBgrd.screenHeight_px, graphicParams.screenHeight_px)
        end

        %% validate user inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % verify that user values are valid given calibration
        calib.out_xyY_Y_mu = mean(calib.out_xyY_Y,4); % average across measurement repetitions
        screen_min_cdm2 = max(max(calib.out_xyY_Y_mu(:,:,1)));
        screen_max_cdm2 = min(min(calib.out_xyY_Y_mu(:,:,end)));
        
        if luxParams.maxAbsLum_cdm2 ~= (luxParams.bkgdLum_cdm2+luxParams.deltaLum_max_cdm2)
            error('maxAbsLum_cdm2 (%1.2f) should match the background (%1.2f) + max DLS (%1.2f)', luxParams.maxAbsLum_cdm2, luxParams.bkgdLum_cdm2, luxParams.deltaLum_max_cdm2);
        end
        if luxParams.bkgdLum_cdm2 < screen_min_cdm2 
            error('Specified background luminance value (%1.2f) is below the displayable range (%1.3f:%1.3f)', luxParams.bkgdLum_cdm2, screen_min_cdm2, screen_max_cdm2)
        end
        if luxParams.maxAbsLum_cdm2 > screen_max_cdm2
            calib.out_xyY_Y_mu(:,:,end)
            error('Specified max luminance value (%1.2f) is above displayable range (%1.3f:%1.3f)', luxParams.maxAbsLum_cdm2, screen_min_cdm2, screen_max_cdm2)
        end

        % find the smallest luminance difference after the background,
        % given the mean calibration
        mu_valsRaw = reshape(mean(mean(mean(calib.out_xyY_Y_mu,4))),[],1); % get mean luminance value for each input level, averaged across spatial (screen) locations
        mu_valsRaw = mu_valsRaw(:);
        mu_in_CL = calib.in_CL'; % formerly: 'inputV'
        fittedmodel = fit(mu_valsRaw, mu_in_CL, 'splineinterp');
        % https://www.mathworks.co.uk/matlabcentral/newsreader/view_thread/287031
        bkgdLum_norm = fittedmodel(luxParams.bkgdLum_cdm2);
        desired_norm = bkgdLum_norm + unitStepSize_norm;
        objective = @(cdm2) fittedmodel(cdm2) - desired_norm;
        est_targLum_min_cdm2 = fzero(objective, 0);
        est_luxParams.deltaLum_min_cdm2 = est_targLum_min_cdm2 - luxParams.bkgdLum_cdm2;

        if abs(est_luxParams.deltaLum_min_cdm2 - luxParams.deltaLum_min_cdm2) > 0.005
            error('Specified delta min (%1.6f) is inconsistent with computed minimum value, given mean screen calibration (%1.6f)', luxParams.deltaLum_min_cdm2, est_luxParams.deltaLum_min_cdm2)
        elseif abs(est_luxParams.deltaLum_min_cdm2 - luxParams.deltaLum_min_cdm2) > 0.005
            warning('Specified delta min (%1.3f) does not match computed minimum value, given screen calibration (%1.3f)', luxParams.deltaLum_min_cdm2, est_luxParams.deltaLum_min_cdm2)
        end
        
        
    try % wrap in try..catch to ensure a graceful exit

        %%%%%%%%
        %% 6  %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Open eyetracker interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            if ~IN_FINAL_MODE
                setpref('ivis','disableScreenChecks',true);
            end
        
            % verify, initialise, and launch the ivis toolbox
            IvMain.assertVersion(eyeParams.ivisVersion);
            IvMain.initialise(IvParams.getDefaultConfig('graphics.testScreenNum',graphicParams.screenNum, 'graphics.useScreen',false, 'eyetracker.sampleRate',[], 'audio.devID',audioParams.devID, 'keyboard.handlerClass','MyInputHandler', 'eyetracker.type',eyeParams.type, 'eyetracker.fixationMarker',eyetracker.fixationMarker, 'eyetracker.id',{'TX120-301-22300547','TX120-203-81900130'}, 'GUI.useGUI',graphicParams.useGUI, 'GUI.screenNum',2, 'classifier.nsecs',paradigm.trialDuration_secs, 'log.raw.dir',LOG_RAW_DIR, 'log.data.dir',LOG_DAT_DIR)); % , 'audio.isConnected',false));
            [eyetracker, logs, InH, winhandle, params] = IvMain.launch(graphicParams.screenNum);

            % Crucial that the geometry of the task is correctly specified,
            % for when converting between pixels/cm/degrees. Just to be
            % safe, we will therefore set the parameters manually here
            % (n.b., though viewDist may get updated based on new
            % eyetracking data).
            screenHeight_cm = graphicParams.screenHeight_cm;
            screenWidth_cm = graphicParams.screenWidth_cm;
            screenWidth_px = graphicParams.screenWidth_px;
            viewingDist_cm = graphicParams.assumedViewingDistance_cm;
            IvUnitHandler(screenWidth_cm, screenWidth_px, viewingDist_cm);
            
            
            

            
        %%%%%%%%
        %% 7  %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Open PTB screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % PTB-3 correctly installed and functional? Abort otherwise.
            AssertOpenGL;

            % !!!!required to work on slow computers!!! Use with caution!!!!!
            Screen('Preference', 'SkipSyncTests', 1);
            
            % Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
            % mogl OpenGL for Matlab wrapper:
            InitializeMatlabOpenGL(1); % necessary for, e.g., trackbox
                        
            % open the screen
            PsychImaging('PrepareConfiguration');
            % This will try to get 32 bpc float precision if the hardware supports
            % simultaneous use of 32 bpc float and alpha-blending. Otherwise it
            % will use a 16 bpc floating point framebuffer for drawing and
            % alpha-blending, but a 32 bpc buffer for gamma correction and final
            % display. The effective stimulus precision is reduced from 23 bits to
            % about 11 bits when a 16 bpc float buffer must be used instead of a 32
            % bpc float buffer:
            PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible'); % 'FloatingPoint32Bit');
            if luxParams.is10Bit
                % Enable GPU's 10 bit framebuffer under certain conditions
                % (see help for this file):
                PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
            end
            if luxParams.useBitstealing
                PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
            end
            % PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'GainMatrix');
            [winhandle, winrect_px] = PsychImaging('OpenWindow', graphicParams.screenNum, 0);
            
            % set alpha blending mode
            Screen('BlendFunction', winhandle, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

            % compute values
            masterGammaTable = Screen('ReadNormalizedGammaTable', winhandle);
            Fr_obs = 1./Screen('GetFlipInterval', winhandle);
            [screenWidth_px, screenHeight_px] = RectSize(Screen('Rect', winhandle));
            
            % verify that user values are valid given PTB screen
            if ~(graphicParams.Fr == round(Fr_obs))
                error('Specified framerate (%1.6f) does not match observed value (%1.6f)', graphicParams.Fr, Fr_obs)
            end
            if ~(screenWidth_px == graphicParams.screenWidth_px)
                if IN_FINAL_MODE
                    error('Specified screen width (%1.6f) does not match observed value (%1.6f)', graphicParams.screenWidth_px, screenWidth_px) %#ok<*UNRCH>
                else
                    warning('Specified screen width (%1.6f) does not match observed value (%1.6f)', graphicParams.screenWidth_px, screenWidth_px)
                end
            end
            if ~(screenHeight_px == graphicParams.screenHeight_px)
                if IN_FINAL_MODE
                    error('Specified screen height (%1.6f) does not match observed value (%1.6f)', graphicParams.screenHeight_px, screenHeight_px)
                else
                    warning('Specified screen height (%1.6f) does not match observed value (%1.6f)', graphicParams.screenHeight_px, screenHeight_px)
                end
            end
            
            % Currently we need to explicitly register the screen with
            % ivis, once it has opened. At one point it was possible to
            % open the screen first and then pass it into ivis upon
            % initilisation. However, ivis GUIs do not work if a PTB window
            % is open, so here we: (1) Open Ivis; (2) Open PTB window; (3)
            % manually register the window.
            IvParams.registerScreen(winhandle)

            % Create a convolution shader for a gaussian blur of width 5 and
            % stddev. 1.5. Needs image processing toolbox for fspecial() function, or
            % alternatively compute your own 5 x 5 kernel matrix with a gaussian
            % convolution kernel inside:
            kernel = fspecial('gaussian', 7, 7); % kernel = fspecial('gaussian', 5, 1.5);
            shader = EXPCreateStatic2DConvolutionShader(kernel, 4, 4, 0, 2);
            % for details, see DrawManuallyAntiAliasedTextDemo.m

            % Create image warper for correcting for flat screen (see
            % VfStimulusWarper.exampleOfUse() for more info)
            %   <moved to later, in order to use empirical distance values>

            
        %%%%%%%%
        %% 7  %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Initialise myStimulus grid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         	% initialise grid objects
            if eyeParams.eye == 0
                fprintf('loading LEFT eye grid..\n');           
            elseif eyeParams.eye == 1
                fprintf('loading RIGHT eye grid..\n');
            else
                error('Unknown eye: %1.2f', eyeParams.eye)
            end
            domain = linspace(0, gridParams.dB_max, gridParams.dB_max+1); % 0:36 ?
            Zest = myZestWrapper(eyeParams.eye, luxParams.deltaLum_max_cdm2, domain, gridParams.doPlot);
            
            % add figure window to GUI (if using a GUI)
            if gridParams.doPlot
                if graphicParams.useGUI
                    ivis.gui.IvGUI.getInstance().addFigureToPanel(Zest.plotObj.hFig, 4);
                else % else reposition manaully
                    %set(Zest.plotObj.hFig,'Position', [3000 300 1000 800])
                end
            end

            % initialise unit handler
            VfUnitHandler(screen_min_cdm2, screen_max_cdm2, luxParams.bkgdLum_cdm2, luxParams.deltaLum_min_cdm2, luxParams.deltaLum_max_cdm2)
            
            % compute any further params
            stimDiam_deg = VfStimulusClassic.getGoldmannDiameter(gridParams.goldmann); % stimDiam_deg = 0.5
            if isempty(stimParams.screenMargins_deg)
                stimParams.screenMargins_deg = repmat(stimDiam_deg*2, 1, 4) .* [1 1 -1 -1];
            end

            % validate screen dimensions
            [screenWidth_px, screenHeight_px] = RectSize(Screen('Rect', graphicParams.screenNum));
            if screenWidth_px~=graphicParams.screenWidth_px
                error('Detected screen width (%i) not as specified (%i)\n', screenWidth_px, graphicParams.screenWidth_px);
            end
            if screenHeight_px~=graphicParams.screenHeight_px
                error('Detected screen width (%i) not as specified (%i)\n', screenHeight_px, graphicParams.screenHeight_px);
            end 
            % can't check physical size reliably, since the queried info is
            % highly suspect in absolute terms, but the relative dimensions
            % are usually about right
            [width_mm, height_mm]=Screen('DisplaySize', graphicParams.screenNum);
            if abs(screenWidth_cm/screenHeight_cm - width_mm/height_mm) > 0.01
                error('Specified aspect ratio (%1.2f x %1.2f = %1.2f) do not match those returned by the monitor itself (%1.2f x %1.2f = %1.2f)', screenWidth_cm, screenHeight_cm, screenWidth_cm/screenHeight_cm, width_mm, height_mm, width_mm/height_mm)
            end
            
            screenDims_deg = [screenWidth_px, screenHeight_px] / (screenWidth_px / (2*rad2deg(atan(graphicParams.screenWidth_cm/(2*graphicParams.assumedViewingDistance_cm))))); % IvUnitHandler.getInstance().deg2px([screenWidth_px, screenHeight_px], graphicParams.assumedViewingDistance_cm) - stimParams.screenMargins_deg*2
            validPlacementDims_deg = screenDims_deg - [sum(abs(stimParams.screenMargins_deg([1 3]))) sum(abs(stimParams.screenMargins_deg([2 4])))];

            fprintf('Screen dimensions = %1.4f x %1.4f DVA\n',screenDims_deg);
            fprintf('Usable screen dimensions = %1.4f x %1.4f DVA\n',validPlacementDims_deg);

            xy_deg = reshape(Zest.zObj.locations_deg, [],2); % reshape into 2 columns (x/y)
            if any(any(bsxfun(@gt, abs(xy_deg), validPlacementDims_deg)))
                error('targets are too far appart to EVER fit on the viewable screen area');
            end
            if any(any(bsxfun(@gt, abs(xy_deg), validPlacementDims_deg/2)))
                warning('some targets are too far appart to be placed when observer is fixating centrally (eccentic viewing required)');
            end
            
                
        %%%%%%%%
        %% 8  %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Open additional audio handles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            audio = IvAudio.getInstance();
            pahandle = audio.getNewSlave();
            pahandle_bkgd = audio.getNewSlave();
            
            
      	%%%%%%%&
        %% 9 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Load Resources %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             
            %-------------Load Sounds--------------------------------------
            fprintf('\nLoading sounds...\n');
            
            nurseryRhymes = audio.loadAll(fullfile(params.toolboxHomedir,'resources','audio','nurseryrhymes'), '*.wav', 0.1);
            n = length(nurseryRhymes);
            
            if audioParams.nTracksToQueue > n
                error('attempting to queue more tracks than have been detected in the audio/nurseryrhymes directory');
            end
            
            enableSchedule = 1;
            maxSize = audioParams.nTracksToQueue;
            PsychPortAudio('UseSchedule', pahandle_bkgd, enableSchedule, maxSize);
            pabuffer_bkgd = cell(1, n);
            
            for i = 1:n
                % Create audio buffers prefilled with the sound:
                pabuffer_bkgd{i} = PsychPortAudio('CreateBuffer', [], nurseryRhymes{i});
            end
             
            
            %-------------Synth Sounds-------------------------------------
            fprintf('\nSynthesising sounds...\n');
            
            
            %-------------Load Images--------------------------------------
            fprintf('\nLoading images...\n');

            switch lower(paradigm.attentionGrabberType)
                case lower('VfAttentionGrabberFace')
                    attentionGrabber = VfAttentionGrabberFace(winhandle, params.graphics.Fr, IMG_DIR, SND_DIR);
                otherwise
                    error('Unknown VfAttentionGrabber: %s', paradigm.attentionGrabberType);
            end

            switch lower(paradigm.rewarder_type)
                case 'animalsprite'
                    rewarder = VfAttentionGrabberAnimals(winhandle, paradigm.rewarder_duration_secs, params.graphics.Fr, IMG_DIR, SND_DIR);
                case 'coin'
                    rewarder = VfAttentionGrabberCoin(winhandle, paradigm.rewarder_duration_secs, params.graphics.Fr, IMG_DIR, SND_DIR, paradigm.rewarder_isColour);
                otherwise
                    error('Unrecognised rewarder type: %s', paradigm.rewarder_type);
            end

    
            %-------------Synth Images-------------------------------------
            fprintf('\nSynthesising images...\n');
            
            % make background luminance texture
            %   backgroundMatrix -> PTB texture
            backTex = Screen('MakeTexture', winhandle, backgroundMatrix, [], [], 1); % high precision (16 bit)

            % make a hacky flat version of the grey background for when
            % only using 8-bits
            backgroundMatrix_mu = backgroundMatrix;
            backgroundMatrix_mu(:,:) = mean(mean(backgroundMatrix_mu));
            backTex_mu = Screen('MakeTexture', winhandle,  backgroundMatrix_mu, [], [], 1); % high precision (16 bit)

            
            % set the background screen for when feedback is being given
            % (hacky?)
            if paradigm.rewarder_isColour && ~luxParams.is10Bit 
                backTex_fback = backTex_mu;
            else
                backTex_fback = backTex;
            end

          	% create grid point stimulus-object
            if stimParams.stim_audio             
                myTestpointStimulus = VfStimulusClassic(gridParams.goldmann, stimParams.stim_cycle_on_secs, stimParams.stim_cycle_off_secs, stimParams.stim_cycle_n, pahandle);
            else
                myTestpointStimulus = VfStimulusClassic(gridParams.goldmann, stimParams.stim_cycle_on_secs, stimParams.stim_cycle_off_secs, stimParams.stim_cycle_n);
            end
            
            % create refixation stimulus-object
            switch lower(paradigm.refixationType)
                case 'controltrial'
                    myRefixationStimulus = VfStimulusClassic(gridParams.goldmann, stimParams.stim_cycle_on_secs, stimParams.stim_cycle_off_secs, stimParams.stim_cycle_n, pahandle);
                case 'animalsprite'
                    myRefixationStimulus = VfAttentionGrabberAnimals();
                otherwise
                    error('Unrecognised refixation type: %s', paradigm.refixationType);
            end              
             
            %-------------Load Movies--------------------------------------
            fprintf('\nLoading videos...\n\n');
            
            fn = fullfile(VID_DIR, 'Waybuloo Adventures in Nara (2009) DVDRip Xvid - EMU.avi');
            IvVideo.getInstance().open(fn);

            
            
            
        %%%%%%%%
        %% 10 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Set viewing distance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            
            lastKnownViewingDistance_cm = NaN;
        
            if ~eyeParams.calibrateDistanceAtStart 
                if IN_FINAL_MODE
                    error('In final mode distance MUST be calibrated');
                end
                
                lastKnownViewingDistance_cm = graphicParams.assumedViewingDistance_cm;
            else
                % run video, enter viewing distance, set lastKnownViewingDistance_cm
                fprintf('Playing video..\n\n');

                % pause background audio
                PsychPortAudio('Stop', pahandle_bkgd);

                % Enable colour display (disable pseudogray)
                if luxParams.useBitstealing
                    % Screen('LoadNormalizedGammaTable', winhandle, masterGammaTable);
                    Screen('HookFunction', winhandle, 'Disable', 'FinalOutputFormattingBlit');
                end

                % Start displaying trackbox, if so specified
                if paradigm.showTrackBoxDuringVid
                    TrackBox.getInstance().start();
                    IvVideo.getInstance().play(true);
                end

                % Start playing video
                IvVideo.getInstance().play(true);  % true for fullscreen

                fprintf('\nRunning distance calibration...\n   > Press SPACE when the user is sat %1.2f cm away from the centre of the screen\n', graphicParams.assumedViewingDistance_cm);
                calibIsSet = false;
                % Play until:
                %   (1) the z-distance of the eyetracker has been
                %       successfully calibrated
                %   (2) The user has pressed space again (if in DEBUG mode)
                while 1
                    
                    % update eyetracker
                    eyetracker.refresh(true); % logging
                    
                    % evaluate whether eyetracker is tracking
                    isTracking = false;
                    if logs.data.getN()>0
                        [~, t] = logs.data.getLastKnownXY(1, true, false); % [useRaw, allowNan]
                        timeNow = GetSecs();
                        if (timeNow-t) <= 0.4 % must have recent non-NaN data
                            isTracking = true;
                        end
                    end
                    
                    % check for input
                    if InH.getInput() == InH.INPT_SPACE.code
                        if calibIsSet % if have already set calibration, and are just loitering in debug mode
                            break
                        else
                            if ~isTracking % defensive check (also performed internally by IvDataInput
                                fprintf('Cannot perform distance calibration; not currently tracking!\n'); 
                            else
                                calibIsSet = eyetracker.calibrateDistanceToScreen(10*graphicParams.assumedViewingDistance_cm);
                                if calibIsSet
                                    fprintf('Additive distance calibration successfully set\n\n');
                                    if ~IN_DEBUG_MODE % if in debug mode will continue running until space pressed again, so as to confirm that the eyetracker is now returning the calibrated value
                                        break;
                                    end
                                else
                                    fprintf('Calibration failed.\nPress SPACE when the user is sat %1.2f cm away from the centre of the screen\n', graphicParams.assumedViewingDistance_cm);
                                end
                            end
                        end
                    end
                    
                    % report current state by writing text directly onto
                    % the screen
                    if ~isTracking
                        DrawFormattedText(winhandle, 'Not Tracking', params.graphics.mx, 50, [1 0 0]);
                    else
                        lastKnownViewingDistance_cm = eyetracker.getLastKnownViewingDistance()/10;
                        DrawFormattedText(winhandle, sprintf('%1.1f cm',lastKnownViewingDistance_cm), params.graphics.mx, 50, [0 1 0]);
                    end
                    
                    % update screen
                    Screen('Flip', winhandle);
                    WaitSecs(.01);
                end

                % Stop displaying video and trackbox
                IvVideo.getInstance().stop();
                if paradigm.showTrackBoxDuringVid
                    TrackBox.getInstance().stop();
                    IvVideo.getInstance().stop();
                end

                % pause for a short moment on blank screen to readjust
                Screen('DrawTexture', winhandle, backTex);
                Screen('Flip', winhandle);
                WaitSecs(.25);
            end
                
            % defensive check
            if isnan(lastKnownViewingDistance_cm)
                error('lastKnownViewingDistance_cm must be set by this point');
            end
            
            % Create image warper for correcting for flat screen (see
            % VfStimulusWarper.exampleOfUse() for more info)
            %   <moved to later, in order to use empirical distance values>           
            zdistBottom_cm = lastKnownViewingDistance_cm + 4; % 64.5     % in cm
            zdistTop_cm    = lastKnownViewingDistance_cm + 4; % 64.5     % in cm
            % create warper object
            warper = visfield.graphic.VfStimulusWarper(screenWidth_cm, screenHeight_cm, screenWidth_px, screenHeight_px, zdistBottom_cm, zdistTop_cm);
          
                
        %%%%%%%%
        %% 11 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Run: Trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            % initialise the classifier to be used throughout testing
            myGraphic = IvGraphic('target', [], 0, 0, 1, 1, [], winhandle); % will make 1x1 pixel, and control classifier margins using IvClassifierBox margins
           	myClassifier = IvClassifierBox(myGraphic, eyeParams.boxdims_calibrated_deg, eyeParams.npoints, [], [], eyeParams.maxPathDeviation_px); % use default margin size of 2 degrees for now
            %myVectorClassifier = IvClassifierVector(0);
            
            % initialise counters
            nTestTrial = 0;
            trialNum = 0;
            resetAudio = true; % force audio to start on trial 1
            nCorrect = 0;
            
            % init point to return to (after a refixation trial)
            stimulusToReturnTo = []; % x_rel_deg, y_rel_deg, targLum_dB

            % initialise calibration parameters
            % recalib params
            triggerRecalib = paradigm.runIntroCalib; % start 
            falseNegative_rate = NaN;
            falseNegative_nPossible = 0;
            falseNegative_n = 0;
            % init adult calib values
            screenMargins_px = round(IvUnitHandler.getInstance().deg2px(stimParams.screenMargins_deg, lastKnownViewingDistance_cm));
            calibMargins_px = round(IvUnitHandler.getInstance().deg2px(stimParams.calibMargins_deg, lastKnownViewingDistance_cm));
            calibRect_px = winrect_px + (screenMargins_px+calibMargins_px);
            xcalib_px = linspace(calibRect_px(1), calibRect_px(3), 3);
            ycalib_px = linspace(calibRect_px(2), calibRect_px(4), 3);
            [xcalib_px, ycalib_px] = meshgrid(xcalib_px, ycalib_px);
            xcalib_px = xcalib_px(:);
            ycalib_px = ycalib_px(:);
            nCalibPoints = length(xcalib_px);
            % 1D classifier, for bootstrapping the calibration
            lmag = params.classifier.loglikelihood.lMagThresh;
            timeout_secs = 3;
            calibClassifier = IvClassifierLL('1D', {IvPrior(), attentionGrabber.ivGraphicStub},[inf lmag*4], [],5, timeout_secs);
            % flags
            isCalibrated = false;
            forceBlankCatchTrial = true;

            

            %%%%%%%%%%%%%%%%%%%%%% Begin Trial Loop %%%%%%%%%%%%%%%%%%%%%%%
            
            % n.b., while loop also useful, because we can manually
            % decremenet 'trialNum', on control (null) trials
            %while (trialNum < maxNTrials) && grid.hasSelectablePoints();
            while ~Zest.isFinished() && (nTestTrial < paradigm.maxNTestTrials)
                trialNum = trialNum + 1;

                % clear eye tracker buffer
                eyetracker.flush();
                
                % init log file name (with time of trial onset)
                logFn = sprintf('%s-%i-%i-%i-%s', metaParams.expID, metaParams.partID, metaParams.sessID, getBlockNum(), datestr(now(),30));

                %%%%%%%%%%% Play Video (before every N trials) %%%%%%%%%%%%
                
                if 0 == mod(trialNum-1, paradigm.videoAfterNTrials) && trialNum>paradigm.suppressVideoOnTrial1
                    fprintf('Playing video..\n');
                    forceContinue = false;
                    
                    % pause background audio
                    PsychPortAudio('Stop', pahandle_bkgd);
                    
                    % Enable colour display (disable pseudogray)
                    if luxParams.useBitstealing
                        % Screen('LoadNormalizedGammaTable', winhandle, masterGammaTable);
                        Screen('HookFunction', winhandle, 'Disable', 'FinalOutputFormattingBlit');
                    end
                    
                    % Start displaying trackbox, if so specified
                    if paradigm.showTrackBoxDuringVid
                        TrackBox.getInstance().start();
                        IvVideo.getInstance().play(true);
                    end
                    
                    % Start playing video
                    IvVideo.getInstance().play(true);  % true for fullscreen
                    
                    % Play until:
                    %   (1) N seconds have elapsed
                    %   (2) The eyes are currently being tracked
                    %   (3) The eyes have been tracked for the proceeding N seconds
                    % OR:
                    %   (1) Experimenter has pressed space
                    lookStartTime = GetSecs();
                    while 1
                        % check for input
                        if InH.getInput() == InH.INPT_SPACE.code
                            fprintf('Playing video: Skipping\n')
                            forceContinue = true;
                        end
                        % update eyetracker
                        eyetracker.refresh(true); % logging
                        % evaluate criteria
                        if logs.data.getN()==0
                            fprintf('Playing video: Waiting for non-NaN eyetracking data\n')
                        else
                            [~, t] = logs.data.getLastKnownXY(1, true, false); % [useRaw, allowNan]
                            timeNow = GetSecs();
                            if (timeNow-t) > 0.4 % must have recent non-NaN data
                                fprintf('Playing video: Eyes lost, resetting timer (Current time: %1.2f; Last known time: %1.2f\n', timeNow, t);
                                lookStartTime = timeNow; % reset
                            elseif forceContinue || ((timeNow-lookStartTime) > paradigm.nSecsRqdToBreakVid)
                                break
                            end
                        end
                        % update screen
                        Screen('Flip', winhandle);
                        WaitSecs(.01);
                    end
                    
                    % Stop displaying video and trackbox
                    IvVideo.getInstance().stop();
                    if paradigm.showTrackBoxDuringVid
                        TrackBox.getInstance().stop();
                        IvVideo.getInstance().stop();
                    end
                    
                    % flag for background audio to be resumed
                    resetAudio = true;
                    
                    % pause for a short moment on blank screen to readjust
                    Screen('DrawTexture', winhandle, backTex);
                    Screen('Flip', winhandle);
                    WaitSecs(.25);
                end % end-of-video

                
                %%%%%%%%%%%%%%%%%%%%% Calibrate, if necessary %%%%%%%%%%%%%%%%%%%%%

                % recalibrate automatically every N trials
                if 0 == mod(trialNum-1, eyeParams.recalib_afterNTrials) && trialNum>1
                    triggerRecalib = true;
                end
                
                if triggerRecalib
                    % clear any existing calibartion
                    IvCalibration.getInstance().clearMeasurements();
                    IvCalibration.getInstance().clear();
                    IvCalibration.getInstance().resetDriftCorrection();
                	isCalibrated = false;
                    WaitSecs(0.2); % wait a bit to make sure buffer cleared
                    eyetracker.flush();
                    
                    % Enable colour display (disable pseudogray)
                    if luxParams.useBitstealing
                        Screen('HookFunction', winhandle, 'Disable', 'FinalOutputFormattingBlit');
                    end
                    
                    % shuffle presentation order
                    [xcalib_px,idx] = Shuffle(xcalib_px);
                    ycalib_px = ycalib_px(idx);

                    % present points, record gaze
                    tLastData_secs = GetSecs();
                    for j = 1:nCalibPoints
                        % set positions
                        attentionGrabber.init(xcalib_px(j), ycalib_px(j))
                     	myGraphic.reset(xcalib_px(j), ycalib_px(j));
 
                        % will keep testing each point until we detect a
                        % fixation or until N seconds have elapsed
                        while 1
                            % Start: classifier, audio
                            calibClassifier.start();
                            attentionGrabber.start();

                            % Run until decision (or timeout)
                            for i = 1:attentionGrabber.nFrames
                                % Query for input (to allow quitting)
                                InH.getInput();
                                % Draw graphics
                                Screen('DrawTexture', winhandle, backTex);
                                attentionGrabber.draw(winhandle);
                                % Update eyetracker
                                n = eyetracker.refresh(true); % false to supress logging
                                if n > 0 % Update classifier
                                    tLastData_secs = GetSecs();
                                    calibClassifier.update();
                                    if calibClassifier.status == calibClassifier.STATUS_HIT % see if reached decision
                                        break
                                    elseif calibClassifier.status == calibClassifier.STATUS_RETIRED
                                        fprintf('calibration point timed out\n');
                                        break
                                    end
                                else
                                    if (tLastData_secs - GetSecs()) > 1;
                                        fprintf('waiting for data... [%1.2 seconds since last data]\n', tLastData_secs - GetSecs());
                                    end
                                end
                                % flip screen
                                Screen('Flip', winhandle);
                                % pause momentarily
                                WaitSecs(params.graphics.ifi);
                            end

                            % Restart calibration if no decision was reached, or if the
                            % classifier deemed that the observer did NOT fixate the
                            % target
                            anscorrect = strcmpi(calibClassifier.interogate().name, 'target');
                            if calibClassifier.isUndecided() || ~anscorrect
                                %eyetracker.setFixationMarker('whitedot'); % enable fixation marker for debugging
                                continue % restart trial (Aborted?)
                            end
                            
                            % remove fixation marker (in case has been
                            % manually reenabled previously for any reason)
                            if ~showFixationMarker
                                eyetracker.setFixationMarker('none');
                            end
                                
                            % add measurements to poly-calib
                            trueXY = [xcalib_px(j), ycalib_px(j)]; % assume fixating middle of target
                            estXYs = logs.data.getLastKnownXY(20, true, false); % [useRaw, allowNan] : Use RAW rather than processed (n.b., no drift correction will be applied), don't permit NaNs
                            IvCalibration.getInstance().addMeasurements(trueXY, estXYs);

                            break % done with calibrating this point
                        end
                    end % end of all calibration points
                    
                    % attempt to compute the eye-tracker calibration
                    if IvCalibration.getInstance().compute();
                        isCalibrated = true;
                        triggerRecalib = false;
                        % reset FN counters
                        falseNegative_n = 0;
                        falseNegative_nPossible = 0;
                        falseNegative_rate = NaN;
                        fprintf('.. Success.');
                    else
                        beep();
                        warning('calibration failed(?)');
                        triggerRecalib = true;
                        continue % skip to next trial, whereupon calibration will start again (i.e., since triggerRecalib==true)
                    end

                    % lurk on a plain screen for a while, to give the
                    % observer a chance to evaluate the calibration
                    if IN_DEBUG_MODE
                        eyetracker.setFixationMarker('whitedot');
                        while ~any(InH.getInput() == InH.INPT_SPACE.code)
                            Screen('Flip', winhandle);
                            % Update eyetracker
                            eyetracker.refresh(false); % false to supress logging
                            % pause momentarily
                            WaitSecs(params.graphics.ifi);
                        end
                        if ~showFixationMarker
                            eyetracker.setFixationMarker('none');
                        end
                    end
                    
                    % pause for a short moment on blank screen to readjust
                    Screen('DrawTexture', winhandle, backTex);
                    Screen('Flip', winhandle);
                    WaitSecs(.33);
                end % end of calibration

                
                %%%%%%%%%%%%%%%%% Reset background audio %%%%%%%%%%%%%%%%%%
                % e.g., after video has ceased, or a certain number of
                % trials have elapsed
                
                if audioParams.playBackground && (resetAudio || mod(trialNum-1, audioParams.resetAfterNTrials)==0)
                    % defensive: make sure is stopped first (otherwise will
                    % crash)
                    status = PsychPortAudio('GetStatus', pahandle_bkgd);
                    if status.Active == 1 % if active..
                        % warning('pabuffer_bkgd was active??! Attempting to stop...');
                        PsychPortAudio('Stop', pahandle_bkgd, 2); % ..immediately stop any playing sounds
                        WaitSecs(0.05);
                    end
                    
                    % reset the schedule (with flag == 2):
                    PsychPortAudio('UseSchedule', pahandle_bkgd, 2);
                    
                    % queue tracks
                    buffers = randsample(pabuffer_bkgd, audioParams.nTracksToQueue);
                    for i = 1:audioParams.nTracksToQueue
                        % Add sound buffers to playlist: The special '1' flag at the end tells not to delete
                        % this command from the schedule, but keep it for further execution on
                        % repetitions of the schedule:
                        PsychPortAudio('AddToSchedule', pahandle_bkgd, buffers{i}, [], [], [], [], 1);
                    end
                    
                    % start playing
                    PsychPortAudio('Start', pahandle_bkgd);
                    resetAudio = false;
                end
                
                
                %%%%%%%%%%%%%%%%%%% !!! START TRIAL !!! %%%%%%%%%%%%%%%%%%%
                
                if IN_DEBUG_MODE
                    fprintf('Running trial..\n');
                end
                
                % init
                inCalibrationMode = false;
                
                % don't want to reset log, since we *want* to know where they
                % were last looking!! The downside of this is that can't
                % have a nice, compartmentalised data file for each trial
                %IvDataLog.getInstance().reset();
                            
                %%%%%%%%%%%%%%%%%%% Initialise Graphics %%%%%%%%%%%%%%%%%%%
                
                % ensure that pseudo-gray is enabled
                if luxParams.useBitstealing
                    Screen('HookFunction', winhandle, 'Enable', 'FinalOutputFormattingBlit');
                end

                %%%%%%%%%%%%%%%%% Ensure Eyes Are Tracked %%%%%%%%%%%%%%%%%
                %
                % Pause here and ensure eyetracker contact before
                % continuing (n.b., crucial for knowing where to place the
                % myStimulus). Key outcomes:
                %       - gaze_xy_px
                %       - lastKnownViewingDistance_cm

                % if no acceptably recent contact, or if gaze is too
                % variable (e.g., mid-saccade), play an attention grabber,
                % and wait until it is fixated (using a liberal classifier)
                startTime_secs = GetSecs();
                while 1
                    % get eye-tracking data
                    eyetracker.refresh(true); % logging
                    [gaze_xy_px, t] = logs.data.getLastKnownXY(1, false, false); % [useRaw, allowNan] : important that post-processing
                    
                    % no point continuing if data buffer is empty
                    if isempty(gaze_xy_px)
                        WaitSecs(0.05);
                        continue;
                    end
                    
                    % are the eyes sufficiently stationarity?
                    v = logs.data.getLastN(min(paradigm.stationarity_nPoints,logs.data.getN()), 8, false); % allow NaNs, get as many velocity points (column 8) as we can (up to paradigm.stationarity_nPoints)
                    if any(v > 999)
                        xyt = logs.data.getLastN(min(paradigm.stationarity_nPoints,logs.data.getN()), 1:3, false);
                        fprintf('%1.2f  %1.2f  %1.2f\n', xyt');
                        fprintf('%1.2f\n', v);
                        warning('Velocity > 999 deg/sec detected - this is most likely an error in the eyetracker timing code??');
                    end
                    stationarity_isViolated = any(v > paradigm.stationarity_criterion_degsec);

                    % compute the viewing distance, so that we can
                    % convert visual-degree parameters to pixels (N.B. this
                    % code is repeated below, within the while loop)
                    z_mm = eyetracker.getLastKnownViewingDistance();
                    lastKnownViewingDistance_cm = z_mm/10; % + graphicParams.monitorTrackerOffset_cm; % offset no longer required because explicit calibration has been performed
                    if lastKnownViewingDistance_cm < 40 || lastKnownViewingDistance_cm > 110
                        fprintf('impossible viewing distance? [%1.2f]. Value has been supressed.\n', lastKnownViewingDistance_cm);
                        lastKnownViewingDistance_cm = NaN;
                    end
                                        
                    %--- break loop if all in order -----------------------
                    % ensure that stationary tracking data is available
                    % from an acceptably recent time
                    if ~isempty(gaze_xy_px) && ((GetSecs()-t) < paradigm.trialInitContactThreshold_secs) && ~stationarity_isViolated && ~isnan(lastKnownViewingDistance_cm)
                        break
                    end
                
                    %--- give feedback to experimenter --------------------
                    if stationarity_isViolated
                        fprintf('waiting for eyes... [stationarity violated]\n');
                    elseif isnan(lastKnownViewingDistance_cm)
                        fprintf('waiting for eyes... [no known viewing distance]\n');
                    elseif isempty(gaze_xy_px)
                        fprintf('waiting for eyes... [no data found]\n');
                    else
                        fprintf('t = %1.3f    now = %1.3f\n', t, GetSecs())
                        fprintf('waiting for eyes... [latest data too old]\n');
                    end
                        
                    %--- grace period before attention grabber ------------
                    if (GetSecs()-startTime_secs) < 0.5
                        WaitSecs(0.02);
                        continue
                    end
                    
                    %--- run attention grabber ----------------------------
                    %  make this next bit run in colour
                    if luxParams.useBitstealing
                        Screen('HookFunction', winhandle, 'Disable', 'FinalOutputFormattingBlit');
                    end
                    
                    % determine attention-grabber placement
                    %targx_px = params.graphics.mx;
                    %targy_px = params.graphics.my;
                    screenMargins_px = round(IvUnitHandler.getInstance().deg2px(stimParams.screenMargins_deg, lastKnownViewingDistance_cm));
                    grabberMargins_px = stimParams.additionalGrabberMargins_px; % [250 250 -250 -250];
                    grabberRect_px = winrect_px + (screenMargins_px+grabberMargins_px);
                    try
                        targx_px = randi([grabberRect_px(1) grabberRect_px(3)]);
                        targy_px = randi([grabberRect_px(2) grabberRect_px(4)]);
                    catch ME
                        rethrow(ME);
                    end
 
                    % Start: flush eyetracker, start classifier, start audio
                    attentionGrabber.init(targx_px, targy_px);
                    % n.b., using myGraphic rather than
                    % attentionGrabber.ivGraphicStub so that we don't have
                    % to make a new classifier in-between trials
                    myGraphic.reset(targx_px, targy_px);
                    myClassifier.setCriterion(20);
                    myClassifier.start();
                    attentionGrabber.start();
                    
                    % Run until decision (or timeout)
                    for i = 1:attentionGrabber.nFrames
                        % Query for input (to allow quitting)
                        InH.getInput();
                        % Draw background
                        if luxParams.is10Bit
                            Screen('DrawTexture', winhandle, backTex);
                        else
                            Screen('DrawTexture', winhandle, backTex_mu);
                        end
                        % Draw graphic
                        attentionGrabber.draw(winhandle);
                        Screen('Flip', winhandle);
                        % Update eyetracker
                        n = eyetracker.refresh(true); % logging
                        % Update classifier % compute velocity
                        if n > 0
                            myClassifier.update();
                            
                            % compute whether gaze is sufficiently
                            % stationary, by checking whether *any* of the
                            % previous N velocity samples exceed some
                            % specified value (deg-per-sec)
                            v = logs.data.getLastN(min(paradigm.stationarity_nPoints,logs.data.getN()), 8, false); % allow NaNs, get as many velocity points (column 8) as we can (up to paradigm.stationarity_nPoints)
                            stationarity_isViolated = any(v > paradigm.stationarity_criterion_degsec & v < 999);
                            
                            if ~myClassifier.isUndecided() && ~stationarity_isViolated % see if reached decision
                                % update calibration - if we've reached
                                % this point then the subject has looked at
                                % the attention grabber. So we might as
                                % well add the data to the eyetracker
                                % calibration
                                resp = myClassifier.interogate().name;
                                anscorrect = strcmpi(resp, 'target');
                                if anscorrect
                                    trueXY = [targx_px targy_px];
                                    % update drift correction
                                    estXY = logs.data.getLastKnownXY(1, false, false); % [useRaw, allowNan] : Use PROCESSED rather than raw, don't permit NaNs (mportant that post-processing)
                                    eyetracker.updateDriftCorrection(trueXY, estXY, [], eyeParams.driftCorrectionWeight);
                                    % update calibration
                                    estXYs = logs.data.getLastKnownXY(15, true, false); % [useRaw, allowNan] : Use RAW rather than processed, don't permit NaNs
                                    IvCalibration.getInstance().addMeasurements(trueXY, estXYs);
                                    IvCalibration.getInstance().compute();
                                end
                                
                                % stop the attention grabber routine
                                break
                            end
                        end
                
                        % pause momentarily, before continuing to the next
                        % frame of the attentiongrabber routine
                        WaitSecs(params.graphics.ifi);
                    end

                    % ensure that pseudo-gray is re-enabled
                    if luxParams.useBitstealing
                        Screen('HookFunction', winhandle, 'Enable', 'FinalOutputFormattingBlit');
                    end
                end % end waiting-for-eyes loop

                %%%%%%%%%%%%% Determine Stimulus Placement %%%%%%%%%%%%%%%%
                %
                % Key outcomes:
                %       - stimOffset_px
                %       - gridPoint
                %       - myStimulus
                %       - myStimulus.setLocation(x_px, y_px)
                %       - isBlankCatchTrial
                
                % validation (defensive)
                if isnan(lastKnownViewingDistance_cm) || lastKnownViewingDistance_cm < 40 || lastKnownViewingDistance_cm > 110
                    error('lastKnownViewingDistance_cm cannt be NaN at this point!');
                end
                
                % init
                screenMargins_px = round(IvUnitHandler.getInstance().deg2px(stimParams.screenMargins_deg, lastKnownViewingDistance_cm));
                validRect_px = winrect_px + screenMargins_px;
                nStimPlacementFails = 0;

                isRefixationTrial = false;
                isEasyCatchTrial = false;
                isBlankCatchTrial = false;
                isValidPlacement = false;
                while ~isValidPlacement
                    
                    % see if there is already a stimulus queued for
                    % presentation (i.e., if we just refixated to be able
                    % to view this point..)
                    if ~isempty(stimulusToReturnTo)
                        x_rel_deg = stimulusToReturnTo.x_rel_deg;
                        y_rel_deg = stimulusToReturnTo.y_rel_deg;
                        targLum_dB = stimulusToReturnTo.targLum_dB;
                        % clear queue
                        stimulusToReturnTo = [];
                    else
                        % select a random gridpoint
                        [x_rel_deg, y_rel_deg, targLum_dB] = Zest.getTarget();
                    end

                    % compute target location, in pixels
                    x_rel_px = IvUnitHandler.getInstance().deg2px(x_rel_deg, lastKnownViewingDistance_cm);
                    y_rel_px = -IvUnitHandler.getInstance().deg2px(y_rel_deg, lastKnownViewingDistance_cm); % n.b., y inverted so as to match PTB (in PTB origin, <0,0>, is at top-left)
                    x_px = round(gaze_xy_px(1) + x_rel_px); % offset from current gaze position
                    y_px = round(gaze_xy_px(2) + y_rel_px);

                    % compute whether grid point lies at a valid location
                    distFromCentre_px   = sqrt(sum([x_px-params.graphics.mx y_px-params.graphics.my ].^2));
                    distFromTopLeft_px  = sqrt(sum([x_px-validRect_px(1)    y_px-validRect_px(2)    ].^2));
                    distFromTopRight_px = sqrt(sum([x_px-validRect_px(3)    y_px-validRect_px(2)    ].^2));
                    
                    % if placement is valid, create a standard myStimulus
                    % object, and set location.
                    if IsInRect(x_px, y_px, validRect_px) && (distFromCentre_px > stimParams.minDistFromCentre_px) && (distFromTopRight_px > stimParams.minDistFromTopRight_px) && (distFromTopLeft_px > stimParams.minDistFromTopLeft_px)
                        
                        % myStimulus successfully placed: create...
                        % ...and note if it is a catch trial
                        switch targLum_dB
                            case {-Inf, forceBlankCatchTrial*targLum_dB}
                                isBlankCatchTrial = true;
                                forceBlankCatchTrial = false;
                            case Inf
                                isEasyCatchTrial = true;
                            otherwise
                                nTestTrial = nTestTrial + 1;
                        end
                        myStimulus = myTestpointStimulus;

                        % break loop
                        isValidPlacement = true;
                    else
                        % myStimulus placement failed
                        fprintf('myStimulus {%1.1f %1.1f} placement failed {%1.1f %1.1f} [%1.1f %1.1f]\n', x_rel_deg, y_rel_deg, gaze_xy_px(1), gaze_xy_px(2), x_px, y_px);
                        nStimPlacementFails = nStimPlacementFails + 1;
                        
                        % if too many failed attempts have occurred, attempt to
                        % refixate attention on the middle of the screen, and
                        % then start again
                        if nStimPlacementFails >= stimParams.maxPlaceAttempts

                            % ####
                            isRefixationTrial = true;
                            
                            % store previous gridPoint so that we can
                            % return to it after this refixation trial
                            stimulusToReturnTo.x_rel_deg = x_rel_deg;
                            stimulusToReturnTo.y_rel_deg = y_rel_deg;
                            stimulusToReturnTo.targLum_dB = targLum_dB;

                            % Determine fixation-shifter placement. Rather
                            % than dumbly placing in centre, will put it
                            % somewhere more likely to allow the previous
                            % point to be shown. But will add some
                            % randomness to stop things getting too
                            % predictable                          
                            xmin = round(max(validRect_px(1), validRect_px(1) - x_rel_px)); % n.b., validRect_px includes a margin
                            xmax = round(min(validRect_px(3), validRect_px(3) - x_rel_px));
                            ymin = round(max(validRect_px(2), validRect_px(2) - y_rel_px));
                            ymax = round(min(validRect_px(4), validRect_px(4) - y_rel_px));
                            x_px = randi([xmin xmax]);
                            y_px = randi([ymin ymax]);
                            % It is vital that these points are constrained to be within the stimulus
                            % placement area, since these points are used to measure false-negatives,
                            % and to (thereby) trigger recalibrations.

                            % initialise myStimulus
                            myStimulus = myRefixationStimulus;
                            
                            % break loop
                            isValidPlacement = true;
                        end
                    end
                end
                
                % !Set location!
                myStimulus.setLocation(x_px, y_px);
                
                
                %%%%%%%% Rescale classification box based on distance %%%%%
                % further away points should be classified more liberally
                % (e.g., larger hit box, and fewer gaze-points required),
                % while near points should be classified more
                % conservatively
                
                if ~isCalibrated
                    boxdims_deg = eyeParams.boxdims_uncalibrated_deg;
                else
                    boxdims_deg = eyeParams.boxdims_calibrated_deg;
                end
                   
                % compute distance-sensitive modifiers (relax classifier at
                % more distant locations)
                d_deg = sqrt(x_rel_deg^2 + y_rel_deg^2);
                addscale_deg = max(0,d_deg-eyeParams.relaxClassifierAfterNdegs)/10; % relax at a rate of 1/4 deg per degree
                addpoints_n = -round(min(eyeParams.npoints-1, eyeParams.npoints * max(0,d_deg-eyeParams.relaxClassifierAfterNdegs)/20));

                % apply classifier settings
                boxdims_px = IvUnitHandler.getInstance().deg2px(boxdims_deg+addscale_deg, lastKnownViewingDistance_cm);
                myClassifier.setBoxMargins(boxdims_px);
                myClassifier.setCriterion(eyeParams.npoints + addpoints_n);

                % should take at least the number of samples, but some
                % arbitrary offset to respond (see/saccade) to the
                % stimulus. If the trial is shorter than this then probably
                % a calibration/stimulus-placement error, and the trial
                % should be repeated
                minAcceptableTrialDuration_secs = (1/samplingRate_hz) * (eyeParams.npoints + addpoints_n) + (1/3);
                                
                %%%%%%%%%%%%%%%%%% Calibrate Luminance %%%%%%%%%%%%%%%%%%%%
                %
                % Determine luminance calibration for this screen
                % coordinate. Key outcomes:
                %       - myStimulus.setLuminance(stimLuminance_norm);

                % normalise stimulus location coordinate, relative to the
                % calibrated region of the screen
                
                % Get luminance calibration function ----------------------
                % map pixel to proportion (0 <= x <= 1) of calibrated region
                x_norm = (myStimulus.x_px - calib.marginLeft_px) / (calib.marginRight_px - calib.marginLeft_px);
                y_norm = (myStimulus.y_px - calib.marginTop_px)  / (calib.marginBottom_px - calib.marginTop_px);
                % validate normalised location
                if x_norm < 0 || x_norm > 1 || y_norm < 0 || y_norm > 1                  
                    warning('x_norm (%1.2f) and x_norm (%1.2f) should be between 0 and 1.\nIt seems that the target location (%1.2f px, %1.2f px) lies outside of the luminance calibrated regions [%i %i %i %i] of the screen', x_norm, y_norm, myStimulus.x_px, myStimulus.y_px, calib.marginLeft_px, calib.marginTop_px, calib.marginRight_px, calib.marginBottom_px);
                end
                % interpolate luminance calibration matrix (sampled at discrete
                % points around the screen)
                Xi = [repmat([(calib.y_n-1)*y_norm+1 (calib.x_n-1)*x_norm+1], calib.nLevels,1), (1:calib.nLevels)'];
                in = calib.in_CL'; % e.g., [0 .25 .5 .75 1]';
                calib.out_xyY_Y_mu = mean(calib.out_xyY_Y,4);
                out = interpne(calib.out_xyY_Y_mu, Xi); % e.g., [2.6 11.6 39.1 88.3 158]';
                % fit model
                fittedmodel = fit(out,in,'splineinterp'); % 'splineinterp');
        
                % ---------------------------------------------------------
                % Get target luminance, in cdm2 and normalised (0 to 1)
                % units 
                if isEasyCatchTrial || isRefixationTrial
                    targAbs_cdm2 = luxParams.maxAbsLum_cdm2;
                    stimLuminance_norm = 1;
                elseif isBlankCatchTrial
                    targAbs_cdm2 = -999;
                    stimLuminance_norm = 0; % won't actually be shown anyway
                else
                    if targLum_dB < 0
                        warning('Zest requested targLum_dB < 0 (%1.2). Will change to 0 value for actual presentation', targLum_dB)
                    end
                    [~, targAbs_cdm2] = VfUnitHandler.getInstance().db2cd(max(targLum_dB,0));
                    % map to normalised (0 to 1) units
                    stimLuminance_norm = fittedmodel(targAbs_cdm2); %square_luminance_norm = (fittedmodel(targ_luminance) - volts_min) / (volts_max - volts_min)
                end

                % !Set luminance!
                myStimulus.setLuminance(stimLuminance_norm);
                
                %%%%%%%%%%%%%%%%% Compute myStimulus Size %%%%%%%%%%%%%%%%%%%
                %
                % Rescale myStimulus size based on current viewing distance.
                % Key outcomes:
                %       - myStimulus.setDiameter(stimDiameter_px);

                % get desired stimulus size (DVA)
                stimDiameter_deg = myStimulus.diameter_deg;

                % convert to pixels
                stimDiameter_px = IvUnitHandler.getInstance().deg2px(stimDiameter_deg, lastKnownViewingDistance_cm);
                stimDiameter_px = 2*round(stimDiameter_px/2);  % round to nearest even number
                n = stimDiameter_px + 2*myStimulus.PADDING_PX;
                
                % Get subset of the background that surrounds/encorporates
                % the stimulus. Set any pixels outside of screen area to be
                % NaNs  
                yidx = y_px+((-n/2+1):(n/2)); % +1 hack
                xidx = x_px+((-n/2+1):(n/2));
                back = nan(length(yidx), length(xidx));
                iy = yidx>0 & yidx<=screenHeight_px;
                ix = xidx>0 & xidx<=screenWidth_px;
                back(iy,ix) = backgroundMatrix(yidx(iy), xidx(ix));
                
                % initialise figure. Apply warping/smoothing
                myStimulus.initGraphic(winhandle, stimDiameter_px, warper, shader, back, stimParams.useStimRamping, stimParams.useStimWarping, stimParams.useLegacyMode)

                %%%%%%%%%%%%% Pause for a variable duration %%%%%%%%%%%%%%%              
                d = min(paradigm.delayMin_secs + abs(randn)*paradigm.delaySigma_secs, paradigm.delayMax_secs);
                delta = d-(GetSecs()-startTime_secs);  % account for any processing time taken to get to this point from trial onset
                if delta < 0 && (d-(GetSecs()-startTime_secs)) > 0.01 % don't bother warning for small infringements
                    warning('Missed the trial onset deadline (by %1.2f secs)   ::  Processing time was %1.2f\n', d-(GetSecs()-startTime_secs), delta);
                    delta = 0;
                end
                WaitSecs(d-delta);
                
                
                %%%%%%%%%%%% Present stimulus / Get response %%%%%%%%%%%%%%
                
                % set colour (if necessary)
                if luxParams.useBitstealing
                    if myStimulus.IS_COLOUR
                        Screen('HookFunction', winhandle, 'Disable', 'FinalOutputFormattingBlit');
                    else
                        Screen('HookFunction', winhandle, 'Enable', 'FinalOutputFormattingBlit');
                    end
                end
                
                % let's go!
                trialStartTime_secs = GetSecs();
                eyetracker.flush();
                myGraphic.reset(myStimulus.x_px, myStimulus.y_px); % note that this is not the same as "myGraphic.reset(x_px, y_px);", as the stimulus centroid may have shifted during the warping process. Also note that this only affects the classifier, not where the image is drawn
                myClassifier.start();
                myStimulus.start();
                
                % show classifier box, if debugging
                if IN_DEBUG_MODE
                    myClassifier.show();
                end

                % present myStimulus and get response
                while myClassifier.isUndecided()
                    
                    % draw background
                    Screen('DrawTexture', winhandle, backTex);

                    % if in debug mode, annotate the screen with debug info
                    if IN_DEBUG_MODE
                        % print distance to screen
                        Screen('DrawText', winhandle, sprintf('%1.2f',lastKnownViewingDistance_cm), params.graphics.mx, params.graphics.my, [1 1 1]);
                        % print margins
                        Screen('FrameRect', winhandle, 255, validRect_px);
                        Screen('FrameOval', winhandle, 255, [0 0 0 0]'+stimParams.minDistFromTopLeft_px*[-1 -1 1 1]');
                        Screen('FrameOval', winhandle, 205, [screenWidth_px 0 screenWidth_px 0]'+stimParams.minDistFromTopLeft_px*[-1 -1 1 1]');
                        Screen('FrameOval', winhandle, 155, [params.graphics.mx params.graphics.my params.graphics.mx params.graphics.my]' + stimParams.minDistFromCentre_px*[-1 -1 1 1]');
                        % print target location
                        Screen('FillRect', winhandle, [0 1 0], [x_px-5 y_px-5 x_px+5 y_px+5]);
                    end
                    
                    % get user input
                    switch first(InH.getInput())
                        case InH.INPT_SPACE.code
                            break
                     	case InH.INPT_SHOWFIXATION.code
                            showFixationMarker = ~showFixationMarker;
                            if showFixationMarker
                                eyetracker.setFixationMarker('whitedot');
                            else
                                eyetracker.setFixationMarker('none');
                            end
                        case InH.INPT_WRONG.code
                            myClassifier.forceAnswer(0);
                        case InH.INPT_RIGHT.code
                            myClassifier.forceAnswer(1);
                        case InH.INPT_TRIGGER_EYETRACKER_CALIBRATION.code % eyetracker recalibration
                            triggerRecalib = true;
                        case InH.INPT_CALIBRATE_SCREEN.code % monitor calibration
                            fprintf('Target luminance: %1.2f dB  =>  %1.4f cd/m2  =>  %1.6f (norm)\n', targLum_dB, targAbs_cdm2, stimLuminance_norm);
                            ListenChar(0)
                            % Set position
                            x_px = getRealInput('(blank to leave) x_px = ',true);
                            y_px = getRealInput('(blank to leave) y_px = ',true);
                            if ~isempty(x_px) && ~isempty(y_px)
                                myStimulus.setLocation(x_px, y_px);
                            end
                            % Set luminance
                            targLum_dB = getRealInput(sprintf('(blank to leave; max = %1.2f) luminance_db = ',gridParams.dB_max),true);
                            if ~isempty(targLum_dB)
                                x_norm = (myStimulus.x_px - calib.marginLeft_px) / (calib.marginRight_px - calib.marginLeft_px);
                                y_norm = (myStimulus.y_px - calib.marginTop_px)  / (calib.marginBottom_px - calib.marginTop_px);
                                Xi = [repmat([(calib.nRows-1)*y_norm+1 (calib.nCols-1)*x_norm+1], calib.nObs,1), (1:calib.nLevels)'];
                                in = calib.in_CL'; % e.g., [0 .25 .5 .75 1]';
                                out = interpne(calib.out_xyY_Y_mu, Xi); % e.g., [2.6 11.6 39.1 88.3 158]';
                                fittedmodel = fit(out,in,'splineinterp'); % 'splineinterp');
                                [~, targAbs_cdm2] = VfUnitHandler.getInstance().db2cd(targLum_dB);
                                stimLuminance_norm = fittedmodel(targAbs_cdm2); %square_luminance_norm = (fittedmodel(targ_luminance) - volts_min) / (volts_max - volts_min)
                                myStimulus.setLuminance(stimLuminance_norm);
                                fprintf('Target luminance: %1.2f dB  =>  %1.4f cd/m2  =>  %1.6f (norm)\n', targLum_dB, targAbs_cdm2, stimLuminance_norm);
                            end
                            % Set size
                            myStimulus.setDiameter(300);
                            % force stimulus to be displayed constantly
                            myStimulus.forceAlwaysOn();
                            % warn that entering calibration mode (trial
                            % will not proceed without manual input)
                            fprintf('\n\n\n!!!Entering calibration mode. To continue, enter W[rong] or R[ight]\n');
                            inCalibrationMode = true;
                            % restore keyboard lock
                            ListenChar(2);
                    end
 
                    % query eyetracker
                    n = eyetracker.refresh(true); % false to supress logging
                    
                    % if any new data, update classifier
                    if n > 0 && ~inCalibrationMode % update classifier
                        myClassifier.update();
                       	responseLatency_secs= GetSecs() - myStimulus.startTime_secs;
                    end
                    
                    % draw stimulus
                    if ~isBlankCatchTrial
                        myStimulus.draw(winhandle);                      
                    end

                    % update display
                    Screen('Flip', winhandle); % n.b., requires that ivis.broadcaster.* has been imported
                    WaitSecs(1/graphicParams.Fr);           
                end
                
                % record end time
                trialEndTime_secs = GetSecs();
                
                % record average response location
                xy = logs.data.getLastN(min(eyeParams.npoints, logs.data.getN()), 1:2, false); % allow NaNs, get as many xy coordinates (columns 1:2) as we can, up to eyeParams.npoints
                obs_x_px = nanmean(xy(:,1));
                obs_y_px = nanmean(xy(:,2));
                
                % defensive                
                myStimulus.stop();

                % ensure classifier is hidden (e.g., if in debugging mode)
                myClassifier.hide();
                
                
                %%%%%%%%%%%%%%%%%%%% Evaluate Response  %%%%%%%%%%%%%%%%%%%
                
                % evaluate resposne
                resp = myClassifier.interogate().name;
                anscorrect = strcmpi(resp, 'target');
                respDeviatedFromPath = strcmpi(resp, 'nothing'); % actively looked in the wrong region
                nCorrect = nCorrect + anscorrect;
                           
                % check valid
                isTrialValid = true;
                if anscorrect
                    fprintf('Response latency (minus classification): %1.2f\n', responseLatency_secs - (1/samplingRate_hz) * (eyeParams.npoints + addpoints_n))
                end
                if responseLatency_secs < minAcceptableTrialDuration_secs
                    warning('Response latency (%1.2f) below minimum required (%1.2f). Trial will be aborted', responseLatency_secs, minAcceptableTrialDuration_secs);
                    isTrialValid = false;
                end
                
                if isTrialValid
                    % update system
                    if ~isRefixationTrial % latter is defensive
                        % N.B. still update if a catch trial (isBlankCatchTrial, isEasyCatchTrial)
                        Zest.update(x_rel_deg, y_rel_deg, targLum_dB, anscorrect, responseLatency_secs/1000);
                    end
                    
                    % update false positive count if necessary (assume that
                    % refixation points should always be seen)
                    if isRefixationTrial || isEasyCatchTrial
                        falseNegative_nPossible = falseNegative_nPossible + 1;
                        if ~anscorrect
                            falseNegative_n = falseNegative_n + 1;
                        end
                        
                        % compute miss rate
                        if falseNegative_nPossible > 5
                            falseNegative_rate = falseNegative_n / falseNegative_nPossible;
                        end
                        
                        % see whether a recalibration is required
                        if falseNegative_rate > eyeParams.recalib_falseNegativeLim
                            fprintf('False negative rate too high (%i of %i; %1.2f%%). Triggering recalibration\n', falseNegative_n, falseNegative_nPossible, falseNegative_rate);
                            triggerRecalib = true;
                            % reset counters
                            falseNegative_n = 0;
                            falseNegative_nPossible = 0;
                            falseNegative_rate = NaN;
                        end
                    end
                end


                %%%%%%%%%%%%%%%%%%%% Provide Feedback  %%%%%%%%%%%%%%%%%%%%

                % command line feedback
                if IN_DEBUG_MODE
                    if anscorrect
                        fprintf('Hit\n');
                    else
                        fprintf('Miss\n');
                    end
                end
                        
                % some stimuli (e.g., certain fixation grabbers) should not
                % be rewarded
                if myStimulus.IS_REWARDABLE
                    
                    if anscorrect
                        % enable colour
                        if luxParams.useBitstealing && rewarder.isInColour
                            Screen('HookFunction', winhandle, 'Disable', 'FinalOutputFormattingBlit');
                        end
                        
                        % give feedback
                        rewarder.init(myStimulus.x_px, myStimulus.y_px);
                        rewarder.start(paradigm.rewarder_playAudio);
                        
                        % Run
                        if paradigm.rewarder_playGraphics
                            for i = 1:rewarder.nFrames
                                % Query for input (to allow quitting)
                                InH.getInput();
                                % Draw graphic
                                Screen('DrawTexture', winhandle, backTex_fback);  % draw background
                                rewarder.draw(winhandle);
                                % Update eyetracker
                                eyetracker.refresh(true); % logging
                                % pause momentarily
                                Screen('Flip', winhandle);
                                WaitSecs(params.graphics.ifi);
                            end
                        end
   
                        % restore pseudogray
                        if rewarder.isInColour && luxParams.useBitstealing
                            Screen('HookFunction', winhandle, 'Enable', 'FinalOutputFormattingBlit');
                        end
                        
                        % make sure audio finished
                        rewarder.stop();
                    elseif respDeviatedFromPath && IN_DEBUG_MODE
                        % only bother to flag up deviations in debug mode
                        % (though in future versions could consider playing
                        % a stern 'beep' to discourage such behaviour)
                        rewarder.playIncorrect();
                    end
                end               
                
                
                %%%%%%%%%%%%%%%%%%%%%%%% Update experimenter on progress %%%%%%%%%%%%%%%%%%%%%%%
                
                % only print updates to console every Nth trial, to avoid
                % clutter
                if mod(trialNum,50)==0
                    approxPercentComplete = 100 * trialNum ./ 330;
                    fprintf('%i. approx %1.2f%% complete\n', trialNum, approxPercentComplete);
                    Zest.printSummary();
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%% Save Data  %%%%%%%%%%%%%%%%%%%%%%%

                % save trial data
                grid_estimates_db = strtrim(num2str(Zest.thresholds(:)', '%1.2f ')); % remove trailing space
                writeData(trialNum,nTestTrial, isBlankCatchTrial,isEasyCatchTrial,isRefixationTrial, nStimPlacementFails, isCalibrated, lastKnownViewingDistance_cm, x_rel_deg,y_rel_deg, x_px,y_px, x_rel_px,y_rel_px, d_deg, stimDiameter_deg,stimDiameter_px, targLum_dB,targAbs_cdm2,stimLuminance_norm, minAcceptableTrialDuration_secs, responseLatency_secs,resp,anscorrect, grid_estimates_db, trialStartTime_secs,trialEndTime_secs, obs_x_px,obs_y_px, logFn)

            end % end of trials
            
            % save eye tracking data
            IvDataLog.getInstance().save(logFn);
            
            % print final summary of results to console
            fprintf('\n\n\n-------------------------------\nFINAL RESULTS:\n-------------------------------\n\n');
            Zest.printSummary();
            
        %%%%%%%%
        %% 12 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Finish up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % that's it! close open windows and release memory
            Screen('LoadNormalizedGammaTable', winhandle, masterGammaTable);
            IvMain.finishUp();
            
        catch ME
            try
                % attempt to restore previous gamma table
                Screen('LoadNormalizedGammaTable', winhandle, masterGammaTable);
            catch %#ok
                warning('Failed to restore masterGammaTable');
            end
            IvMain.finishUp();
            rethrow(ME);
    end 

    fprintf('All done, thanks for playing. nCorrect = %i\n', nCorrect);
end