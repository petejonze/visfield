function calib=calib_checkSystemVolume(calib,attemptToRecover)
% check stored to current
% if attemptToRecover then, if a mismatch is detected, it will attempt to
% recover by setting the system volume to the volume specified in the calib
% (default==false)

    % init
    calib = calib_load(calib);
    if nargin < 2 || isempty(attemptToRecover)
        attemptToRecover = false;
    end
    
    % extract previous value from calib if one exists
    volCalib = -1;
    if isfield(calib,'systemSettings') && isfield(calib.systemSettings,'volume') && ~isempty(calib.systemSettings.volume)
        volCalib = calib.systemSettings.volume;
    end
    if isempty(volCalib)
        error('calib_checkSystemVolume:InvalidInput','No system volume specified in calib');
    end
    
    % check OS
    if ~IsWin
        error('calib_setSystemVolume:InvalidOS','calib_setSystemVolume only works with Windows XP');
    end  
    
    % get current volume
 	sysVol = SoundVolume();
    
    % store (if necessary)
    if volCalib ~= sysVol
        if attemptToRecover
            calib_setSystemVolume(calib)
            calib = calib_storeSystemVolume(calib);
            calib=calib_checkSystemVolume(calib,false);
        else
            error('calib_checkSystemVolume:MismatchDetected','Volume specified in calib (%1.3f) does not match current system volume (%1.3f)',volCalib,sysVol);
        end
    end

end