function calib=calib_save(calib,fileName,overwrite)

    % init
    if nargin<2 || isempty(fileName)
        if isfield(calib,'metaInfo') ...
                && isfield(calib.metaInfo,'fileName') ...
                && ~isempty(calib.metaInfo.fileName) ...
                && ischar(calib.metaInfo.fileName) % try to get filename from metainfo% try to get filename from metainfo
            fileName = calib.metaInfo.fileName;
        else
            fileName = getStringInput('Enter file name : ',false);
            affix = ['_' regexprep(datestr(now(),20),'/','-')];
            fileNameAppended = [fileName affix];
            appendDate = getLogicalInput(['Append today''s date? [' fileNameAppended ']  (y/n): ']);
            if appendDate
                fileName = fileNameAppended;
            end
        end
    end
    % add file extension if not there already
    if length(fileName) <= 4 || ~strcmpi(fileName(end-3:end),'.mat')
        fileName = [fileName '.mat'];
    end

    % check doesn't already exist
    if exist(fileName,'file')
        if nargin<3 || isempty(overwrite)
            overwrite = getLogicalInput([fileName ' already exists. Overwrite?  (y/n): ']);
        end
        if ~overwrite
            ME = MException('myCalibration:InvalidInput', 'Specified output file already exists and overwrite==false');
            throw(ME);
        end
    end

    % update meta info
    calib.metaInfo.fileName = fileName;
    calib.metaInfo.lastUpdate = datestr(now(),0);
    
    % save
    save(fileName,'calib');
    disp(['file successfully saved: ' fileName]);

end