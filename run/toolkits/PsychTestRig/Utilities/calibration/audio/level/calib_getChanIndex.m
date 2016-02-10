function chanIndex=calib_getChanIndex(calib,chanID)
% get index to this channel in the calib struct
    ids = [];
    try %#ok field won't exist in empty calibrations
        ids = [calib.channels(:).id];
    end

	chanIndex = [];
    if ~isempty(ids) && any(ids==chanID)
        chanIndex = find(ids==chanID);
    end
end