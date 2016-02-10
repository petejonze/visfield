function []=calib_plot(calib,varargin)

% todo: yes, show all data points, but ones not used for the fit should be
% delineated from the rest (i.e. diff colour/symbol)
    close all

    if ischar(calib)
        calib = calib_load(calib);
    end

    plotNoise = true;
    if nargin>1; plotNoise=varargin{1}; end;
    plotTones = true;
    if nargin>2; plotTones=varargin{2}; end;
    isSemilogY = true;
    if nargin>3; isSemilogY=varargin{3}; end;
    
    nChannels = length(calib.channels);
    dimN = ceil(sqrt(nChannels));
    
    if plotNoise
        figure(1)
        for i=1:nChannels
            if isfield(calib.channels(i),'whitenoise') && isstruct(calib.channels(i).whitenoise) && ~isempty(fieldnames(calib.channels(i).whitenoise))
                subplot(dimN,dimN,i);
                hold on
                    % init vars
                    db = calib.channels(i).whitenoise.raw.db;
                    rms = calib.channels(i).whitenoise.raw.rms;
                    coefs = calib.channels(i).whitenoise.fit.coefs;
                    r2 = calib.channels(i).whitenoise.fit.r2;
                    fitRMS = polyval(coefs,db);
                    % plot raw
                    plot(db,log(rms),'*')                
                    % plot fit
                    plot(db,fitRMS,'-')
                    text(db(end),fitRMS(end),num2str(r2));
                hold off

                xlabel('meas. db'); ylabel('LOG matlab  r.m.s. pow'); title(sprintf('Channel %i',calib.channels(i).id));
            end
            title('*****WHITE NOISE*****');
        end
    end

    if plotTones
        figure(2)
        for i=1:nChannels
            if isfield(calib.channels(i),'freqs') && isstruct(calib.channels(i).freqs) && ~isempty(fieldnames(calib.channels(i).freqs))
                nFreqs = length(calib.channels(i).freqs)
                legendText = cell(1,nFreqs);
                legendHandles = zeros(1,nFreqs);
                myColors = lines(nFreqs); %winter is quite nice also
                subplot(dimN,dimN,i);
                hold on
                    for j=1:nFreqs
                        % init vars
                        db = calib.channels(i).freqs(j).raw.db;
                        rms = calib.channels(i).freqs(j).raw.rms;
                        coefs = calib.channels(i).freqs(j).fit.coefs;
                        r2 = calib.channels(i).freqs(j).fit.r2;
                        fitRMS = exp(polyval(coefs,db));
                        % plot
                        if isSemilogY
                            % plot raw
                            h = plot(db,log(rms),'o','color',myColors(j,:));
                            % plot fit
                            plot(db,log(fitRMS),'-','color',myColors(j,:))
                            yLabelText = 'matlab  LOG(r.m.s. pow)';
                        else
                            h = plot(db,rms,'o','color',myColors(j,:));
                            plot(db,fitRMS,'-','color',myColors(j,:))
                            yLabelText = 'matlab  r.m.s. pow';
                        end
                        text(db(end),fitRMS(end),num2str(r2));
                        % add to legend
                        legendHandles(j) = h;
                        legendText{j} = num2str(calib.channels(i).freqs(j).val);
                    end
                hold off
                if dimN==1 || rem(i,dimN)==1 %if on left
                    ylabel(yLabelText);
                end
                if i > (dimN^2-dimN) %bottom row
                    xlabel('meas. db');
                end
                title(sprintf('Channel %i',calib.channels(i).id));
                legend(legendHandles,legendText,'Location','SouthEast');
                legend boxoff
            end
        end
        suplabel('*****PURE TONES*****','t');
    end

end


    % calib.channels(1).id = 0;
    % calib.channels(1).freqs(1).val = 500;
    % calib.channels(1).freqs(1).raw.db = [0 10 20 30 40 50 60];
    % calib.channels(1).freqs(1).raw.rms = [0 5 10 15 20 25 30];
    % calib.channels(1).freqs(1).fit.coefs = [1 0];
    % calib.channels(1).freqs(2).val = 1000;
    % calib.channels(1).freqs(2).raw.db = [0 10 20 30 40 50 60];
    % calib.channels(1).freqs(2).raw.rms = [10 15 20 25 30 35 40];
    % calib.channels(1).freqs(2).fit.coefs = [1 0];
    % calib.channels(1).freqs(3).val = 2000;
    % calib.channels(1).freqs(3).raw.db = [0 10 20 30 40 50 60];
    % calib.channels(1).freqs(3).raw.rms = [5 10 15 20 25 30 35];
    % calib.channels(1).freqs(3).fit.coefs = [1 0];
    % calib.channels(2).id = 1;
    % calib.channels(2).freqs(1).val = 1050;
    % calib.channels(2).freqs(1).raw.db = [0 10 20 30 40 50 60];
    % calib.channels(2).freqs(1).raw.rms = [0 5 10 15 20 25 30];
    % calib.channels(2).freqs(1).fit.coefs = [1 0];
    % calib.channels(3).id = 5;
    % calib.channels(3).freqs(1).val = 3000;
    % calib.channels(3).freqs(1).raw.db = [0 10 20 30 40 50 60];
    % calib.channels(3).freqs(1).raw.rms = [0 5 10 15 20 25 30];
    % calib.channels(3).freqs(1).fit.coefs = [1 0];
    %
    % calib.channels(2).whitenoise.raw.db = [0 10 20 30 40 50 60];
    % calib.channels(2).whitenoise.raw.rms = [0 5 10 15 20 25 30];
    % calib.channels(2).whitenoise.fit.coefs = [1 0];
    %