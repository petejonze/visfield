classdef TrackInterleaver < handle
    %#####
    %
    %   #####
    %
    % @Requires the following toolkits: <none>
    %
    % @Constructor Parameters:
    %
    %     	######
    %
    %
    % @Example:         cs = ConstantStimuli(1:2:7, 10)
    %                   cs.Update(true);
    %
    % @See also:        ConstantStimuli_example.m
    %
    % @Earliest compatible Matlab version:	v2008
    %
    % @Author:          Pete R Jones
    %
    % @Creation Date:	05/07/10
    % @Last Update:     27/03/13
    %
    % @Current Verion:  1.0.0
    % @Version History: v1.0.0	PJ 19/09/2013    Initial build.
    %
    % @Todo:            lots
    
    properties (GetAccess = 'public', SetAccess = 'private')
        % user specified parameters
        tracks
        selectionMethod
        %
        activeTrackNums
        currentStack
        currentTrackNum
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')
        
        %% == CONSTRUCTOR =================================================
        
        function obj=TrackInterleaver(tracks, selectionMethod)
            % validate
            if ~ismember(lower(selectionMethod), {'random','sequential','pseudorandom'})
                error('a:b','c');
            end
            
            % set specified parameter values ------------------------------
            obj.tracks          = tracks;
            obj.selectionMethod = selectionMethod;

            % init
            obj.activeTrackNums = 1:length(tracks);
        end
        
        %% == METHODS =====================================================
        
        % ####
        function [delta, trackNum] = getValue(obj)
            % check at least 1 track still active
            if obj.isFinished()
                error('a:b','is finished?');
            end
            
            % get/update currentTrackNum
            switch lower(obj.selectionMethod)
                case {'random'}
                    % randomly pick any active track
                    tmp = Shuffle(obj.activeTrackNums);
                    trackNum = tmp(1);
                case 'sequential'
                    if isempty(obj.currentStack)
                        obj.currentStack = obj.activeTrackNums;
                    end
                    % pop the next track off the batch stack
                    trackNum = obj.currentStack(1);
                    obj.currentStack(1) = [];
                case 'pseudorandom'
                    if isempty(obj.currentStack)
                        obj.currentStack = Shuffle(obj.activeTrackNums); % n.b., shuffled
                    end
                    % pop the next track off the batch stack
                    trackNum = obj.currentStack(1);
                    obj.currentStack(1) = [];
                otherwise
                    error('selectTrack:unknownMethod', 'Unknown method.')
            end
            
            % store
            obj.currentTrackNum = trackNum;
            
            % get val
            delta = obj.tracks{trackNum}.getDelta();
        end

        % ####
        function fin = isFinished(obj)
            fin = isempty(obj.activeTrackNums);
        end

        % update with new results
        function [] = update(obj, wasCorrect)
            
            track = obj.tracks{obj.currentTrackNum};
            
            % update
            track.update(wasCorrect);
            
            % check if finished
            if track.isFinished()
                obj.activeTrackNums(obj.activeTrackNums==obj.currentTrackNum) = []; % remove track number from list of active tracks
            end

        end
        
    end
    
end