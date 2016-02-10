classdef (Abstract) VfStimulus < handle
	% ########.
    %
    % VfStimulus Methods:
    %   * VfStimulus  	- Constructor.
    %   * ######  	- ######.
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
    
    properties (Abstract, Constant, GetAccess = public)
        IS_COLOUR
        IS_REWARDABLE
    end

       
    %% ====================================================================
    %  -----ABSTRACT METHODS-----
    %$ ====================================================================
    
     
    methods (Abstract, Access = public)
        
        
        % #######.
        %
        % @param   	########    ########
        %
        % @date     23/07/14
        % @author   PRJ
        %
        setLocation(x_px, y_px)
        
        % #######.
        %
        % @param   	########    ########
        %
        % @date     23/07/14
        % @author   PRJ
        %
        setLuminance(stimLuminance_norm)
        
        % #######.
        %
        % @param   	########    ########
        %
        % @date     23/07/14
        % @author   PRJ
        %
        initGraphic(stimDiameter_px)
        
    end
    
    
    %% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
  
    methods (Access = protected)
        
     	%% == CONSTRUCTOR =================================================

        function obj = VfStimulus()
            % VfStimulus Constructor.
            %
            % @return   obj  VfStimulus object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
        end
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
  
    methods (Access = public)
    end
    
end