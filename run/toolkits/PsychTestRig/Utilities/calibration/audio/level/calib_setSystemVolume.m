function calib_setSystemVolume(calibOrVol)


    % init, get newVol value
    newVol = [];
    if isnumeric(calibOrVol)
        newVol = calibOrVol;
    else
        calib = calib_load(calibOrVol);
        
        % extract previous value from calib if one exists
        if isfield(calib,'systemSettings') && isfield(calib.systemSettings,'volume') && ~isempty(calib.systemSettings.volume)
            newVol = calib.systemSettings.volume;
        end
    end
    
    % validate
    if isempty(newVol)
        error('calib_setSystemVolume:InvalidInput','No new volume specified / none found in calib');
    end
    
    % check OS
    if ~IsWin
        warning('calib_setSystemVolume:InvalidOS','calib_setSystemVolume only works with Windows XP');
    end % just have to hope not running another flavour of windows..

    % set
    SoundVolume(newVol);

end