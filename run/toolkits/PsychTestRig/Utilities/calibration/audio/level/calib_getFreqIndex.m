function [freqIndex, nearestFreq]=calib_getFreqIndex(calib,chanIdx,freq,tolerance,logScale)
% get index to this freq in the calib.channel struct
% n.b. takes chanIdx not channel ID!!
    % with tolerance, 1 = 100%
    
    if nargin<4 || isempty(tolerance) || ~isnumeric(tolerance)
        tolerance = 0; % default
    end
    tolerance = freq*tolerance; % convert to hertz
    
    
    if nargin<5 || ~isempty(logScale)
        logScale = true; % default
    else
        logScale = logical(logScale); %ensure logical
    end
    
    try %#ok  field won't exist in empty calibrations
        vals = [calib.channels(chanIdx).freqs(:).val];
    catch %#ok
        warning('calib_getFreqIndex:noCalibFound','Ill-formed calibration file? [Failed to retrieve frequency values]');
        freqIndex = []; nearestFreq = [];
        return % return empty handed
    end

    if logScale
        diff = abs(log(freq) - log(vals)); % e.g. 949 is nearer 1000 than 900
    else
        diff = abs(freq - vals);
    end
    

    smallestDiff = min(diff);
    nearestFreq = vals(find(diff==smallestDiff,1)); % find() is necessary to resolve (unlikely) instances of tie-breaks     
    if smallestDiff <= tolerance
       freqIndex = find(vals==nearestFreq);
    else
        warning('calib_getFreqIndex:noCalibFound','Did not find a suitable value for freq==%1.3f [closest value==%1.3f]', freq, vals(find(vals==nearestFreq)));
        freqIndex = [];
        return % return empty handed
    end
    
    if length(freqIndex) > 1
        error('calib_getFreqIndex:multipleCalibFound','Found multiple values for freq==%1.3f (??)', freq);
    end
    
end
                            