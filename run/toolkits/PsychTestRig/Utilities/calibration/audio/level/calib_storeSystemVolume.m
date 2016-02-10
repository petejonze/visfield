function calib=calib_storeSystemVolume(calib, sysVol, overwrite)
% sysVol is optional. If not specified will get current value.

    % init
    calib = calib_load(calib);
    
    % extract previous value from calib if one exists
    oldVolCalib = -1;
    if isfield(calib,'systemSettings') && isfield(calib.systemSettings,'volume') && ~isempty(calib.systemSettings.volume)
        oldVolCalib = calib.systemSettings.volume;
    end
    
    % check OS
    if ~IsWin
        error('calib_setSystemVolume:InvalidOS','calib_setSystemVolume only works with Windows XP');
    end % just have to hope not running another flavour of windows..   
    
    % validate
    if nargin<2 || isempty(sysVol)
        sysVol = SoundVolume(); % get
    end
    if nargin<3 || isempty(overwrite)
        overwrite = true;
    end
    
    % store (if necessary)
    if oldVolCalib ~= sysVol
        calib.systemSettings.volume = sysVol;
        calib_save(calib,[],overwrite); % save
    end

end