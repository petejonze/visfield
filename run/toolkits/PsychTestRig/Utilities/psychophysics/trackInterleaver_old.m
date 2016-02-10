classdef trackInterleaver < handle
% Requires setfigdocked.m if plotting
%
% EXAMPLE:
% close all
% clear all
% 
% a = adaptiveTrack(adaptiveTrack.getDummyParams());
% b = adaptiveTrack(adaptiveTrack.getDummyParams());
% c = adaptiveTrack(adaptiveTrack.getDummyParams());
% tInterleaver = trackInterleaver([a b c],'pseudorandom'); % or 'random', 'sequential'
% 
% for i = 1:100
%     trk = tInterleaver.selectTrack;
%     if isempty(trk)
%         break
%     end
%     trk.Update(true);
%     pause(.15);
% end

    properties (GetAccess = 'public', SetAccess = 'private')
        currentTrack
        currentTrackIdx
        selectionMethod
        selectionHistory
        figcontainer
    end
    properties (GetAccess = 'private', SetAccess = 'private')
        tracks
        activeTrackIndices
        completedTrackIndices 
        currentTrackBatch % used to keep track when running in sequential or pseudorandom order
    end
    
    methods (Access = 'public')
        %Constructor
        function obj=trackInterleaver(tracks, selectionMethod) 
            % validate
            if ~strcmpi(class(tracks),'adaptiveTrack')
                error('trackInterleaver:invalidInput','tracks must be an array of adaptiveTrack objects');
            end
            validSelectionMethods = {'random','sequential','pseudorandom'};
            if ~ismember(selectionMethod,validSelectionMethods)
                error('trackInterleaver:invalidInput','selectionMethod must be one of: %s', strjoin(', ',validSelectionMethods{:}));
            end
            
            % init parameter values
            obj.tracks = tracks;
            obj.activeTrackIndices = 1:length(tracks);
            obj.completedTrackIndices = [];
            obj.currentTrackBatch = [];
            obj.selectionMethod = selectionMethod;
            
             % if any plots, merge into one composite
            if ~isempty(tracks(1).figHandles) % use first as arbitrary exemplar
                obj.dockFigures()
            end
        end
        
        % Update with new results
        function track = selectTrack(obj)
            
            track = [];
            obj.currentTrack = [];
            
            while ~isempty(obj.activeTrackIndices)
                
                switch lower(obj.selectionMethod)
                    case {'random'}
                        % randomly pick a track from the active list
                        r = Randi(length(obj.activeTrackIndices));
                        obj.currentTrackIdx = obj.activeTrackIndices(r);
                    case 'sequential'
                        if isempty(obj.currentTrackBatch)
                            obj.currentTrackBatch = obj.activeTrackIndices;
                        end
                        % pop the next track off the batch stack
                        obj.currentTrackIdx = obj.currentTrackBatch(1);
                        obj.currentTrackBatch(1) = [];
                    case 'pseudorandom'
                        if isempty(obj.currentTrackBatch)
                            obj.currentTrackBatch = Shuffle(obj.activeTrackIndices);
                        end
                        % pop the next track off the batch stack
                        obj.currentTrackIdx = obj.currentTrackBatch(1);
                        obj.currentTrackBatch(1) = [];
                    otherwise
                        error('selectTrack:unknownMethod', 'Unknown method.')
                end
                
                
                if obj.tracks(obj.currentTrackIdx).isFinished
                    % mark as completed
                    obj.activeTrackIndices(obj.activeTrackIndices == obj.currentTrackIdx) = [];
                    obj.completedTrackIndices(obj.currentTrackIdx) = obj.currentTrackIdx;
                else
                    % set and break loop
                    track = obj.tracks(obj.currentTrackIdx);
                    obj.currentTrack = track; % store
                    break
                end 
            end
        end
    end
    
    
    methods (Access = 'private')
        
        function [] = dockFigures(obj)
            % params
            dockFlag = 0;
            guiName = 'Interleaved Tracks';
            nTracks = length(obj.tracks);
            
            % create shell
            setfigdocked('GroupName',guiName,'GridSize',[1 nTracks]);
            
            % get handle to the Matlab desktop
            try
                desktop = com.mathworks.mde.desk.MLDesktop.getInstance;      % Matlab 7+
            catch ME %#ok
                desktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;  % Matlab 6
            end
            if isempty(desktop)
                error('a:b','c');
            end
            
            % undock
            try
                javaMethod('setGroupDocked',guiName,dockFlag==1)
            catch ME %#ok
                desktop.setGroupDocked(guiName,dockFlag==1)
            end
            
            % plot a dummy figure so we have a container to play with
            hFig = figure('visible','off', 'Name','null','NumberTitle','off');
            setfigdocked('GroupName',guiName,'Figure',hFig,'Figindex',1);
            
            % get handle
            obj.figcontainer = desktop.getGroupContainer(guiName).getTopLevelAncestor;
            
            % set size &  position(/monitor)
            obj.figcontainer.setMaximized(false);
            obj.figcontainer.setLocation(1,1);
            obj.figcontainer.setSize(1000,600);
            
            % dock each figure
            for i = 1:nTracks
                hFig = obj.tracks(i).figHandles.hFig;
                set(hFig,'Name',sprintf('t %i',i));
                setfigdocked('GroupName',guiName,'Figure', hFig,'Figindex',i-1);
            end
            
        end
        
    end
    
end