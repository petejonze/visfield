function calib=calib_importData(calib, fn, autoReplace, supressWarnings)
%CALIB_IMPORTDATA Read calibration data from a csv file, include in existing
%calib structure
%
%  	####
%
% @Parameters:             
%
%    	calib       Struct      A calibration structure
%
%     	fn          Char        File name
%                                e.g. './spreadsheets/myCalibDetails.csv'
% @Returns:  
%
%    	calib       Struct      Updated calibration structure
%
%
% @Usage:           [calib]=calib_importData(calib, fn)   
% @Example:         calib=calib_importData(calib, 'posthoc_measures.xls');
%
% @Requires:        csv2struct.m
%   
% @See also:        #####
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	11/06/11
% @Last Update:     11/06/11
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	11/06/11    Initial build.
%                   v1.0.1	11/06/11    ######
%
% @Todo:            Lots!
%
    
    %% Init
    if nargin < 3 || isempty(autoReplace)
        autoReplace = 0;
    end
    if nargin < 4 || isempty(supressWarnings)
        supressWarnings = false;
    else
        supressWarnings = logical(supressWarnings);
    end    
    
    preexistingWarningBacktrace = warning('query', 'backtrace');
    warning('off','backtrace'); % disable backtraces

    %% Run!
    try

        %% Read in data
        data = csv2struct(fn);

        %% Validate
        if ~isfield(data, 'rms')
            error('a:b', 'No rms column detected');
        end

        %% Strip out data & insert into calib structure

        % Get RMS values
        rms = data.rms;
        data = rmfield(data,'rms');

        % Insert RMS/Level values into the calib
        field = fieldnames(data);
        for i=1:length(field)
            tmp = regexp(field{i},'_','Split');
            channel = tmp{1}; channel = channel(2:end); channel = str2num(channel); %#ok - remove intro filler text & convert
            freq = tmp{2}; freq = str2num(freq); %#ok

            % check if data already exists, and if so whether to replace
            skipThisData = false;
            if autoReplace ~= -1 % not NEVER
                cid = calib_getChanIndex(calib, channel);
                if ~isempty(cid)
                    fid = calib_getFreqIndex(calib,cid,freq,[],true);
                    if ~isempty(fid)
                        if ~supressWarnings
                            warning('a:b','Data already exists for channel %i, freq %1.4f', channel, freq);
                        end
                        if autoReplace ~= 1 % not ALWAYS
                            switch get1ofMInput('Replace values? [yes(y), no(n), always(a), never(z)] : ',{'y','n','a','z'});
                                case 'y'
                                    skipThisData = false;
                                case 'n'
                                    skipThisData = true;
                                case 'a'
                                    skipThisData = false;
                                    autoReplace = 1; % ALWAYS
                                case 'z'
                                    skipThisData = true;
                                    autoReplace = -1; % NEVER
                                otherwise
                                    error('a:b','c')
                            end
                        end

                    end
                end
            end


            % insert data
            if ~skipThisData
                cid = calib_getChanIndex(calib, channel);
                if isempty(cid) % create new channel
                    cid = length(calib.channels)+1;
                    fid = 1;
                    % init channel
                    calib.channels(cid).id = channel;
                    calib.channels(cid).freqs = struct();
                    calib.channels(cid).whitenoise = struct();
                else
                    fid = calib_getFreqIndex(calib,cid,freq,[],true);
                    if isempty(fid) % create new channel
                        fid = length(calib.channels(cid).freqs)+1;
                    end
                end

                % insert values
                calib.channels(cid).freqs(fid).val = freq;
                calib.channels(cid).freqs(fid).raw.rms = rms';
                calib.channels(cid).freqs(fid).raw.db = data.(field{i})';
            end

        end

    catch ME
        warning(preexistingWarningBacktrace.state, preexistingWarningBacktrace.identifier) % restore backtraces
        rethrow(ME);
    end

end