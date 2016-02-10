classdef MyInputHandler < InputHandler
    % Example InputHandler subclass, with added mappings for the "a" and
    % "b" key
    %
    % MyInputHandler Methods:
    %   * MyInputHandler - Constructor.
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
    %   1.0 PJ 07/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        INPT_WRONG = struct('key','w', 'code',3)
        INPT_RIGHT = struct('key','r', 'code',4)
        
        INPT_CALIBRATE_SCREEN = struct('key','c', 'code',5)
        
        INPT_SHOWFIXATION = struct('key','f', 'code',6)
        
        INPT_TRIGGER_EYETRACKER_CALIBRATION = struct('key','t', 'code',7)
        
        INPT_LEFTARROW   = struct('key','LeftArrow', 'code',8)
        INPT_RIGHTARROW  = struct('key','RightArrow', 'code',9)
        INPT_UPARROW     = struct('key','UpArrow', 'code',10)
        INPT_DOWNARROW   = struct('key','DownArrow', 'code',11)
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = MyInputHandler(isAsynchronous, customQuickKeys, warnUnknownInputsByDefault, winhandle)
            if nargin < 1, isAsynchronous = []; end
            if nargin < 2, customQuickKeys = []; end
            if nargin < 3, warnUnknownInputsByDefault = []; end
            if nargin < 4, winhandle = []; end
            obj = obj@InputHandler(isAsynchronous, customQuickKeys, warnUnknownInputsByDefault, winhandle);
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