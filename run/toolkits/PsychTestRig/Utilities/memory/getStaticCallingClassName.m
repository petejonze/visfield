function className = getStaticCallingClassName
%GETSTATICCALLINGCLASSNAME finds the classname used when invoking an (inherited) static method.
%
% SYNOPSIS: className = getStaticCallingClassName
%
% INPUT none
%
% OUTPUT className: name of class that was used to invoke an (inherited) static method
%
% EXAMPLE
%
%   Assume you define a static method in a superclass
%       classdef super < handle
%       methods (Static)
%           doSomething
%               % do something here
%           end
%       end
%       end
%
%   Also, you define two subclasses
%       classdef sub1 < super
%       end
%
%       classdef sub2 < super
%       end
%
%   Both subclasses inherit the static method. However, you may be
%   interested in knowing which subclass was used when calling the static
%   method. If you call the subclass programmatically, you can easily pass
%   the name of the subclass as an input argument, but you may want to be
%   able to call the method from command line without any input and still
%   know the class name.
%   getStaticCallingClassName solves this problem. Calling it in the above
%   static method 'doSomething', it returns 'sub1' if the static method was
%   invoked as sub1.doSomething. It also works if you create an instance of
%   the subclass first, and then invoke the static method from the object
%   (e.g. sc = sub1; sc.doSomething returns 'sub1' if .doSomething calls
%   getStaticCallingClassName)
%   
%   NOTE: getStaticCallingClassName reads the last workspace command from
%         history. This is an undocumented feature. Thus,
%         getStaticCallingClassName may not work in future releases.
%   
% created with MATLAB ver.: 7.9.0.3470 (R2009b) on Mac OS X  Version: 10.5.7 Build: 9J61 
%
% created by: Jonas Dorn
% DATE: 16-Jun-2009
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the last entry of the command line from the command history
javaHistory=com.mathworks.mlservices.MLCommandHistoryServices.getSessionHistory;
 global lastCommand
lastCommand = javaHistory(end).toCharArray';%'# SO formatting
% find string before the last dot.
tmp = regexp(lastCommand,'(?:=|\.)?(\w+)\.\w+\(?(?:.*)[;,]*\s*$','tokens')
try
    className = tmp{1}{1};
catch me
    className = [];
end
% if you assign an object, and then call the static method from the
% instance, the above regexp returns the variable name. We can get the
% className through getting the class of xx.empty.
if ~isempty(className)
    className = evalin('base',sprintf('class(%s.empty);',className));
end
