%% 1. compile
%
% Instructions for compiling "myex.c"
% -------------------------------
% Compiling is needed to turn "myex.c" into "myex.mexw32" (or myex.mexw64).
% When compiling, the compiler needs to be able to see the .dll and .lib
% file, and the .h files contained within "./eyex/". When running, the .mex
% file will still need to be able to see the .dll and .lib file (e.g., put
% them in the same local directory).
%
% - Compiling only needs to be done once, on first usage.
% - Must be run in a directory containing:
%       ./eyex (subdirectory containing EyeX.h, EyeXActions.h, etc.)
%       myex.c
%       Tobii.EyeX.Client.dll
%       Tobii.EyeX.Client.lib
% - Note that the .dll and .lib file are found inside the Tobii EyeX SDK
%   E.g., inside: TobiiEyeXSdk-Cpp-0.23.325\lib\x64
%       - Remember that you must use the appropriate .dll/.lib files (x64
%         if compiling for 64bit Matlab, x86 if compiling for 32bit Matlab
%         [even on a  64bit machine])
%       - Remember that the EyeX SDK is not the same as the Tobii SDK for
%         their other ('research grade') eye-trackers.
%
% 32 vs 64 bit
% -------------------------------
% - Note for 32-bit Matlab users:
%       This compiler *did* work: Microsoft Software Development Kit (SDK) 7.1 in C:\Program Files (x86)\Microsoft Visual Studio 10.0
%       The default compiler did *not* work: Lcc-win32 C 2.4.1 in C:\PROGRA~2\MATLAB\R2012b\sys\lcc 
%       (this is because the lcc compiler does not permit variable definition/initialisation on same line)
%       - You can change compiler using mex -setup
%       - You can download the visual studio compiler as part of the
%         Microsoft .Net dev kit (if my memory serves)
% - Note for 64-bit Matlab users:
%       If when you compile you get an error like this:
%           myex.obj : error LNK2019: unresolved external symbol __imp_txFormatObjectAsText referenced in function __txDbgObject 
%       Then you are trying to compile against the 32bit .dll/.lib files.
%       Replace these with the appropriate versions from the x64 SDK
%       directory (see above).
%
% Tobii EyeX engine number
% -------------------------------
% Both the Tobii EyeX Engine and the SDK are regularly updated. This can
% lead to various errors. For example, if you update the EyeX Engine, you
% may start to get this error:
%
%   The connection state is now SERVER_VERSION_TOO_HIGH: this application requires an older version of the EyeX Engine to run.
%
% Or if you try to compile "myex.c" against newer/older-than-expected
% versions of the SDK, you may get various "undeclared identifier errors".
% For example, between SDK_0.23 and SDK_1.3 the following things changed:
%
%   All variables starting "TX_INTERACTIONBEHAVIORTYPE_" now start "TX_BEHAVIORTYPE_"
%   "txInitializeSystem" => "txInitializeEyeX"
%   "TX_SYSTEMCOMPONENTOVERRIDEFLAG_NONE" => "TX_EYEXCOMPONENTOVERRIDEFLAG_NONE"
%
% In the "__precompiled_versions/" directory I include versions compiled
% using the following setups:
%
%   Tobii EyeX Engine (0.8.17.1196), Tobii EyeX Cpp SDK (0.23.325)
%   Tobii EyeX Engine (1.2.0.4583),  Tobii EyeX Cpp SDK (1.3.443)
%
% But as Tobii update their software, you may have to update "myex.c" and
% recompile it accordingly


% % compile - only need to do this once
% mex myex.c % compile to generate myex.mexw32 / myex.mexw64
% WaitSecs(.1);

%% 2. run
% This requires Psychtoolbox to run: http://psychtoolbox.org/

% connect to EyeX Engine
myex('connect') 

% clear any data in buffer
myex('getdata');

% allow to track until key press
x_all = [];
while ~KbCheck();
    x = myex('getdata');
    if ~isempty(x)
        % display distance
        z_mm = x(end,[8 11]);
        isvalid = x(end,[4 5])==1;
        isvalid = isvalid & (z_mm>0.001); % defensive (shouldn't be necessary)
        z_mm = z_mm(isvalid);
        z_mm = nanmean(z_mm);
        fprintf('Distance = %1.2f\n', z_mm)
        % add to store
        x_all = [x_all; x]; %#ok<AGROW> This is innefficient memory-allocation, but ok for present purposes
    end
    WaitSecs(1/300);
end

% disconnect from EyeX Engine
WaitSecs(.1);
myex('disconnect')

 
%% 3. show results
close all
plot(x_all(:,1:2))
% print data to console
fprintf('%s   %s   %s   %s %s   %s  %s  %s   %s  %s  %s   %s\n','GazeX_px','GazeY_px','GazeTimestamp','L','R','LeyeX_mm','LeyeY_mm','LeyeZ_mm','ReyeX_mm','ReyeY_mm','ReyeZ_mm','EyePosTimestamp');     
fprintf('%-9.2f  %-9.2f  %-12.2f    %i %i   %-9.2f %-9.2f %-9.2f  %-9.2f %-9.2f %-9.2f  %-12.2f\n',x_all')

% Example console output:
%     GazeX_px   GazeY_px   GazeTimestamp   L R   LeyeX_mm  LeyeY_mm  LeyeZ_mm   ReyeX_mm  ReyeY_mm  ReyeZ_mm   EyePosTimestamp
%     -434.03    1072.27    4960162.84      1 1   -9999.99  152.43    643.01     -71.12    151.77    655.96     4960148.65  
%     -432.16    1071.33    4960177.23      1 1   -132.36   152.81    643.55     -71.33    152.01    656.17     4960163.61  
%     -429.65    1073.21    4960191.83      1 1   -132.53   153.08    643.95     -71.40    152.20    656.30     4960179.43  
%     -431.86    1073.59    4960207.99      1 1   -132.60   153.24    644.14     -71.43    152.32    656.25     4960193.61  
%     -437.36    1075.82    4960222.27      1 1   -132.74   153.36    644.21     -71.51    152.35    656.15     4960208.62  
%     -437.83    1075.68    4960236.55      1 1   -132.70   153.42    644.25     -71.45    152.33    656.01     4960224.43  
%     -436.64    1071.04    4960252.17      1 1   -132.61   153.40    644.19     -71.35    152.25    655.78     4960238.65  
%     -438.34    1062.34    4960282.48      1 1   -132.61   153.40    644.19     -71.35    152.25    655.78     4960238.65  
%     -438.57    1059.38    4960297.57      1 1   -132.51   153.34    643.97     -71.21    152.05    655.36     4960270.62  
%     -438.39    1059.00    4960312.23      1 1   -132.38   153.24    643.80     -71.10    151.93    655.11     4960283.55  
%     ...



%% FPS check

% z = x_all(:,3)
% zz = double(z)/1000;
% zzz = zz - (zz(end)-GetSecs())
% GetSecs()
% 
% fprintf('%1.6f\n',zzz)
% fprintf('\n%1.6f\n',GetSecs())