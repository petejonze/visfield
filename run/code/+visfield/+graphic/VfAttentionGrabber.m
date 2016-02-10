classdef (Abstract) VfAttentionGrabber < handle
	% ########.
    %
    % VfAttentionGrabber Methods:
    %   * VfAttentionGrabber  	- Constructor.
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
        init(x_px, y_px)
        
        % #######.
        %
        % @param   	########    ########
        %
        % @date     23/07/14
        % @author   PRJ
        %
        start()
        
        % #######.
        %
        % @param   	########    ########
        %
        % @date     23/07/14
        % @author   PRJ
        %
        draw(winhandle)
        
       	% #######.
        %
        % @param   	########    ########
        %
        % @date     23/07/14
        % @author   PRJ
        %
        stop()
        
    end
    
    
    %% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
  
    methods (Access = protected)
        
     	%% == CONSTRUCTOR =================================================

        function obj = VfAttentionGrabber()
            % VfAttentionGrabber Constructor.
            %
            % @return   obj  VfAttentionGrabber object
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
        
        function playIncorrect(obj)
            % #####
            %
            % @date     26/06/14
            % @author   PRJ
            %  
            ivis.audio.IvAudio.getInstance().play(ivis.audio.IvAudio.getInstance().BAD_SND);
        end
 
    end
    
end