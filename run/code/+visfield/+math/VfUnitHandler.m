classdef (Sealed) VfUnitHandler < Singleton
    % Utility for converting between units
    %
    % VfUnitHandler Methods:
	%   * VfUnitHandler	- Constructor.
    %   * #####         - ######.   
    %
    % See Also:
    %   <none>
    %
    % Example:
    %   runtests infantvision.tests -verbose
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 07/2014 : first_build
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
       
    properties (GetAccess = public, SetAccess = private)
        screen_min_cdm2
        screen_max_cdm2
        bkgd_cdm2
        delta_min_cdm2
        delta_max_cdm2
        dynamicRange_db
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
        
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = VfUnitHandler(screen_min_cdm2, screen_max_cdm2, bkgd_cdm2, delta_min_cdm2, delta_max_cdm2)
            % VfUnitHandler Constructor.
            %
            % @param    bkgd_cdm2        	#####
            % @param    delta_max_cdm2   #####
            % @return   obj             VfUnitHandler object
            %
            % @date     17/07/14
            % @author   PRJ
            %
            
            obj.screen_min_cdm2 = screen_min_cdm2;
            obj.screen_max_cdm2 = screen_max_cdm2;
            obj.bkgd_cdm2 = bkgd_cdm2;
            obj.delta_min_cdm2 = delta_min_cdm2;
            obj.delta_max_cdm2 = delta_max_cdm2;
            obj.dynamicRange_db = 10*log10(delta_max_cdm2/delta_min_cdm2);
        end
        
        %% == METHODS =====================================================

        function delta_db = cd2db(obj, delta_cdm2, suppressValidation)
            % Convert candela/meter-square to db.
            %
            % @param    delta_cdm2
            % @return   delta_db
            %
            % @date     17/07/14
            % @author   PRJ
            %    
            if nargin < 3 || isempty(suppressValidation)
                suppressValidation = false;
            end
            
            delta_db = 10*log10(obj.delta_max_cdm2/delta_cdm2); %e.g., 10*log10(155/20)
            
            % ALT: if specified in terms of targAbs_cdm2
            % delta_db = 10*log10(delta_max_cdm2/(targAbs_cdm2-bkgd_cdm2))
            
            % validate
            if ~suppressValidation
                if delta_db > obj.dynamicRange_db || delta_db < 0
                    error('delta_db (%1.6f) outside dynamic range', delta_db);
                end
            end
        end
                
        function [delta_cdm2, targAbs_cdm2] = db2cd(obj, db, doValidation)
            % Convert db to candela/meter-square.
            %
            % @param    db
            % @return   delta_cdm2
            % @return   targAbs_cdm2
            %
            % @date     17/07/14
            % @author   PRJ
            %              
            
            % parse inputs
            if nargin < 3 || isempty(doValidation)
                doValidation = true;
            end
            
            % compute
            delta_cdm2 = obj.delta_max_cdm2./exp10(db./10);
            targAbs_cdm2 = delta_cdm2 + obj.bkgd_cdm2;
            
            % validate
            if doValidation
                if any(targAbs_cdm2 < obj.screen_min_cdm2) || any(targAbs_cdm2 > obj.screen_max_cdm2)
                    idx = targAbs_cdm2 < obj.screen_min_cdm2 || targAbs_cdm2 > obj.screen_max_cdm2;
                    error('User requested dB = %1.2f\nThis would correspond to a targAbs_cdm2 value of: %1.2f\nBut this targAbs_cdm2 outside displayable range: %1.2f - %1.2f', db(idx), targAbs_cdm2(idx), obj.screen_min_cdm2, obj.screen_max_cdm2);
                end
            end
        end
        
        function weberContrast = cd2contrast(obj, delta_cdm2)
            % Convert candela/meter-square to contrast.
            %
            % @param    delta_cdm2
            % @return   weberContrast
            %
            % @date     17/07/14
            % @author   PRJ
            %
            weberContrast = delta_cdm2 / obj.bkgd_cdm2; % MP1 handbook: (Weber) Contrast is defined as the ratio of the differential luminance to background luminance. % ALT: weberContrast = (targLum_cdm2 - bkgd_cdm2) / bkgd_cdm2
            %michelsonContrast = (targAbs_cdm2 - obj.bkgd_cdm2) / (targAbs_cdm2 + bkgd_cdm2) % not 100% sure if targAbs_cdm2 is correct here
        end
    end
 

  	%% ====================================================================
    %  -----SINGLETON BLURB-----
    %$ ====================================================================

    methods (Static, Access = ?Singleton)
        function obj = getSetSingleton(obj)
            persistent singleObj
            if nargin > 0, singleObj = obj; end
            obj = singleObj;
        end
    end
    methods (Static, Access = public)
        function obj = getInstance()
            obj = Singleton.getInstanceSingleton(mfilename('class'));
        end
        function [] = finishUp()
            Singleton.finishUpSingleton(mfilename('class'));
        end
    end
    
end