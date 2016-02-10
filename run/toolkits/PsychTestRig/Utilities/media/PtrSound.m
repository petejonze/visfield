classdef PtrSound < handle
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
    % @Todo:            lots
    
    properties (GetAccess = 'public', SetAccess = 'private')
        soundwave
        Fs
        d
        pahandle
    end
    
    %% ====================================================================
    %  -----CONSTRUCTOR/DESTRUCTOR METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')
        
        function obj = PtrSound(SoundOrFullFn, Fs, rms, testChans, outChans, levelAdjust, pahandle)
            
            obj.Fs = Fs;
            
            if ischar(SoundOrFullFn)
                [obj.soundwave, obsFs] = wavread(char(SoundOrFullFn));
                if obsFs ~= obj.Fs
                    warning('ptr_loadSound:SamplingFrequencyMismatch', 'Sampling rate mismatch.\n          Specified file (%s) had a detected sampling rate (%i) that differed from that specified/expected (%i)', SoundOrFullFn, obsFs, Fs);
                    obj.soundwave = resample(obj.soundwave, obsFs, obj.Fs);
                end
                
            else
                obj.soundwave = SoundOrFullFn;
            end
            
            if nargin > 2 && ~isempty(rms)
                obj.soundwave = calib_setRMS(obj.soundwave', rms ); %transpose to make compatible with psychportaudio (later) and set volume [i.e. portaudio expects row vectors, but soundwave is read in as columns]
            end
            
            if nargin > 3 && ~isempty(testChans)
                obj.soundwave = padChannels(obj.soundwave, testChans, outChans);
            end
            
            if nargin > 5 && ~isempty(levelAdjust)
                obj.soundwave = obj.soundwave * levelAdjust;
            end
            
            if nargin > 6 && ~isempty(pahandle)
                obj.pahandle = pahandle;
            end
            
            % calc duration
            obj.d = size(obj.soundwave,2)/obj.Fs;
        end
        
        function obj = delete(obj)
        end
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')
        
        function [] = play(obj, pahandle, repetitions, block)
            if nargin < 2 || isempty(pahandle)
                pahandle = obj.pahandle;
            end
            if nargin < 3 || isempty(repetitions)
                repetitions = 1;
            end
            if nargin < 4 || isempty(block)
                block = false;
            end
            
%             status = PsychPortAudio('GetStatus', pahandle)
%             if status.Active == 1 % if active..
%                 t = GetSecs();
%                 PsychPortAudio('Stop', pahandle, 2); % ..immediately stop any playing sounds
%                 whcleaile status.Active == 1 % if active..
%                     if (GetSecs() - t) > 3
%                         error('PtrSound:Timeout', 'a timeout occured while waiting for audio to terminate ( > 3 seconds elapsed)');
%                     end
%                     PsychPortAudio('GetStatus', pahandle)
%                     WaitSecs(0.01);
%                     status = PsychPortAudio('GetStatus', pahandle);
%                     
%                 end
%             end
            
            
            PsychPortAudio('Stop', pahandle, 2, 1); % just in case
%             WaitSecs(0.001);
            
            
            PsychPortAudio('FillBuffer', pahandle, obj.soundwave);
            WaitSecs(0.001);
            PsychPortAudio('Start', pahandle, repetitions);
            
            if block
                WaitSecs(obj.d);
                PsychPortAudio('Stop', pahandle); % just in case
            end
            
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