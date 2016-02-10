classdef ConstantStimuli < handle
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
        values
        nTrialsPerValue
        nTrialsTotal
        anscorrect
        trialval
        trialN = 1;
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')
        
        %% == CONSTRUCTOR =================================================
        
        function obj=ConstantStimuli(values, nTrialsPerValue)
            % set specified parameter values ------------------------------
            obj.values          = values;
            obj.nTrialsPerValue	= nTrialsPerValue;
            
            % init
            obj.nTrialsTotal = length(values)*nTrialsPerValue;
            obj.trialval = repmat(values, nTrialsPerValue, 1);
            obj.trialval = Shuffle(obj.trialval(:));
            obj.anscorrect = nan(obj.nTrialsTotal, 1);
        end
        
        %% == METHODS =====================================================
        
        % ####
        function val = getDelta(obj)
            val = obj.trialval(obj.trialN);
        end

        % ####
        function fin = isFinished(obj)
            fin = (obj.trialN > obj.nTrialsTotal);
        end

        % update with new results
        function [] = update(obj, wasCorrect)
            obj.anscorrect(obj.trialN) = wasCorrect;
            obj.trialN = obj.trialN + 1;
        end
        
        % ####
        function [pc, trialval, anscorrect] = getPC(obj)
            [trialval,idx] = sort(obj.trialval);
            anscorrect = obj.anscorrect(idx);
            
            trialval = reshape(trialval, [], length(obj.values));
            anscorrect = reshape(anscorrect, [], length(obj.values));
            pc = nanmean(anscorrect);
        end
        
    end
    
end