function db=calib_rms2dB(calib,rms,outChans,freq,tolerance,devID,devName,headID)
% CALIB_GETDBLEVEL Converts a specified RMS power level to an Leq (SPL) value, 
%   given a previously obtained calibration file.
%
%   Uses a linear regression (Leq regressed onto log10(rms)) backwards.
%
%   Currently if freq is -1 then it will attempt to find a whitenoise
%   calibration
%
% @Parameters:             
%
%     	calib                   Struct/Char    	Either calib structure or name of file to load (including relative or absolute path if not in current directory)
%                                e.g. './calibrations/calib-1234.mat'
%     	rms                     Real         	rms power to convert
%                                e.g. 64
%     	outChans                 Int             #####
%                                e.g. 0
%     	freq                    Real            Expected headphone ID
%                                e.g. 1000
%     	[tolerance]             Real            see calib_getFreqIndex()
%                                e.g.
%     	[devID]                 Int             Expected device ID
%                                e.g. 1
%     	[devName]               Char            Expected device name
%                                e.g. 'C-Media USB Headphone Set'
%     	[headID]                Char            Expected headphone name
%                                e.g. 'Sen-ME4'
% @Returns:  
%
%    	db       	Real      The db value corresponding to the specified rms value.
%
%
% @Usage:           db=calib_getTargRMS(calib, myRMSpower, outChans, freq, [tolerance], [devID], [devName], [headID])   
% @Example:         #####
%
% @Requires:        PsychTestRig2
%   
% @See also:        #####
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	02/06/2011
% @Last Update:     02/06/2011
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	02/06/2011    Initial build.
%
% @Todo:            Lots!
%
%                	additional input validation
%                   change name to getLeq ? or just 'get' ?


%   	%%%%%%%%%
%     %%% -1 %%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%% If dummy calib %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         % dummy calibrations are useful if you are just developing a script
%         % (e.g. on a random computer), and don't want all the hastle of having
%         % to actually perform a proper calibration. See calib_dummy.m
%         if isstruct(calib) && isfield(calib,'isDummy') && calib.isDummy
%             Xrms = exp10( (targLeq - calib.coefs(2) ) / calib.coefs(1) );
%             return
%         end
        
    %%%%%%%%%
    %%% 0 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialise variable %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % necessary params
        if nargin < 1 || isempty(calib)
            fprintf('USAGE: db=calib_getTargRMS(calib, rms, outChans, freq, [tolerance], [devID], [devName], [headID])\n');
            error('calib_rms2dB:invalidInput','No calibration specified');
        elseif nargin < 2 || isempty(rms)
            error('calib_rms2dB:invalidInput','No rms specified');
        elseif nargin < 3 || isempty(outChans)
            error('calib_rms2dB:invalidInput','No channel specified');    
        elseif nargin < 4 || isempty(freq)
            error('calib_rms2dB:invalidInput','No freq specified');
        end

        % optional params
        if nargin < 5
            tolerance = [];
        end
        if nargin < 6
            devID = [];
        end
        if nargin < 7
            devName = [];
        end
        if nargin < 8
            headID = [];
        end

        % extra
        isWNoise = false;
        if freq == -1
            isWNoise = true;
            freq = [];
        end

    %%%%%%%%%
    %%% 1 %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Load/validate calib %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        calib = calib_load(calib,devName,devID,headID,outChans,isWNoise,freq,tolerance);
    
        
        i = 1;
        nChans = length(outChans);
        db = nan(nChans,1);
        
        for outChan=outChans    

            %%%%%%%%%
            %%% 2 %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Get appropriate fit coeficients %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

                chanIdx = calib_getChanIndex(calib,outChan);
                SLM = [];
                
%                 if isWNoise
%                     coefs =  calib.channels(chanIdx).whitenoise.fit.coefs;
%                 else % pure tone
%                     targFreqIdx = calib_getFreqIndex(calib,chanIdx,freq,tolerance,true);
%                     coefs = calib.channels(chanIdx).freqs(targFreqIdx).fit.coefs;
%                 end
%                 if isWNoise
%                     error('calib_getTargRMS:NotYetComplete','Sorry whitenoise SLM support not yet written.\n');
%                     SLM =  calib.channels(chanIdx).whitenoise.fit.SLM;
%                 else % pure tone
%                     targFreqIdx = calib_getFreqIndex(calib,chanIdx,freq,tolerance,true);
%                     SLM = calib.channels(chanIdx).freqs(targFreqIdx).fit.SLM;
%                 end

                if isWNoise
                    if isfield(calib.channels(chanIdx).whitenoise.fit, 'SLM')
                        error('calib_getTargRMS:NotYetComplete:whitenoise','Sorry whitenoise SLM support not yet written.\n');
                    else
%                         warning('calib_getTargRMS:Legacy:whitenoise','NO SLM calib found, extracting regression coefs instead.\n');
                        coefs =  calib.channels(chanIdx).whitenoise.fit.coefs;
                    end
                else % pure tone
                    targFreqIdx = calib_getFreqIndex(calib,chanIdx,freq,tolerance,true);
                    if isfield(calib.channels(chanIdx).freqs(targFreqIdx).fit, 'SLM')
                        SLM = calib.channels(chanIdx).freqs(targFreqIdx).fit.SLM;
                    else
%                         warning('calib_getTargRMS:Legacy','NO SLM calib found, extracting regression coefs instead.\n');
                        coefs = calib.channels(chanIdx).freqs(targFreqIdx).fit.coefs;
                    end
                end
            

            
            %%%%%%%%%
            %%% 3 %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Convert log10(RMS) to dB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

                % log10 since we fitted a straight line by log(10)ing the RMS
                % values
%                 m = coefs(1);
%                 c = coefs(2);
%                 x = rms(i);
%                 db(i) = m*log10(x) + c;
                
                % now using SLM toolbox for advance fits:
                if ~isempty(SLM)
                    db(i) = slmeval(log10(rms(i)),SLM,0); % 1, using in forwards mode [NO??? SHOULD BE 0???? <CHANGED>]
                else
%                     warning('calib_rms2dB:Legacy','NO SLM structure found, reverting to regression.\n');
                    m = coefs(1);
                    c = coefs(2);
                    x = rms(i);
                    db(i) = m*log10(x) + c;
                end
            

            i = i + 1;
        end
	
end