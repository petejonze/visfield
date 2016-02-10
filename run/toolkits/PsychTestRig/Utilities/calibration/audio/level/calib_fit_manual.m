function [fitCoefs,r2,n,nPointsExcluded,excludedIdx]=calib_fit_manual(rms, db)
%get comments format from calib_load
% could be improved by using brushing to select regions of data and/or by
% having lclick turn on nearest, rclick turn off nearest
% db should actually be Leq (SPL) i suspect

%v3:    changed from log/exp to log10/exp10
%       swapped regression axes (all the error is in the db measurement)

% TODO: check for 0 rms (replace with realmin?) - otherwise bad things will
% happen

% smoothness of the fit lines
nExtrapFit = 300;
nFit = 100;
minDB = 0;
maxDB = 110;

    % display operating instruction to the user
    fprintf('Manually fitting calibration..\n')
    fprintf('  r-square represents the proportion of variance explained by the fitted model\n\n')
    fprintf('  Left-click to include/exclude the nearest point\n')
    fprintf('  Right-click to similarly toggle all the points below the nearest one\n')
    fprintf('  Left/Right click on axes labels for more\n')
    fprintf('  Press any key or close the window to finish\n\n')
    
    % open up our interactive fitting window
	hFig = figure();
       
    % get automatic fit for our starting point
    [fitCoefs,r2,n,nPointsExcluded,excludedIdx]=calib_fit_auto(rms, db);
    % initialise on/off data points accordingly
    isOn = 1==(ones(1,length(rms)));
    isOn(excludedIdx) = 0;
    
    
    
	% summary plot
    fitX = linspace( min(log10(rms(isOn))),max(log10(rms(isOn))),nFit);
    fitY = polyval(fitCoefs,fitX);

    
    minRMS = ((minDB - fitCoefs(2)) / fitCoefs(1));
    extrap_fitX = linspace(minRMS, min(log10(rms(isOn))), nExtrapFit);
    extrap_fitY = polyval(fitCoefs,extrap_fitX);  
    
    maxRMS = ((maxDB - fitCoefs(2)) / fitCoefs(1));
    extrap_fitX_hi = linspace(max(log10(rms(isOn))), maxRMS, nExtrapFit);
    extrap_fitY_hi = polyval(fitCoefs,extrap_fitX_hi);   
    hold on;
        if nPointsExcluded<1
            hPointsOff = plot(NaN,NaN,'rx');
        else
            hPointsOff = plot(db(~isOn),log10(rms(~isOn)),'rx'); %won't actually plot if x/y empty
        end
        hPointsOn = plot(log10(rms(isOn)),db(isOn),'go');
%         hFit = plot(db(isOn),fitY,'-k');
        hFit = plot(fitX,fitY,'-k');
        hFitExtrap = plot(extrap_fitX,extrap_fitY,':k');
        hFitExtrap_hi = plot(extrap_fitX_hi,extrap_fitY_hi,':k');
        hText = text(minRMS,maxDB, sprintf('r^{ 2} = %1.7f',r2) );
    hold off;

    % some simple formatting
    xlabel('log10(RMS)');
    ylabel('db');
    set(hFig,'Name','Calibration fit editor'); %window title
    set(hFig,'color',[1 1 1]); %canvas colour
    % set(gca,'dataaspectratio',[1 1 1])
    axis(axis); %ALT: axis(axis); [ sets the XLimMode, YLimMode, and ZLimMode properties to manual ]
%     axis manual
%     ylim([minDB maxDB])
%     myXlim = xlim;
axis([minRMS maxRMS, minDB, maxDB]);
    log10Axis = 1;
    
    while (1)
        try
            [x,y,but] = ginput(1);  % Select a point with the mouse
        catch ME %#ok e.g. if user closes the window
            break
        end
        
        % finish up if not left or right click
        if ~isempty(but) % i.e. if not key stroke
            if ~(but == 1 || but == 3)
                break
            end
        end
        
        curXLim = xlim;
        if y < 0 % toggle axis
            log10Axis = 1-log10Axis;
            axis auto
        elseif x < curXLim(1) % toggle axis
            if but == 1
                maxDB = maxDB + 10;
            else
                maxDB = maxDB - 10;
            end
            axis auto
            
            % replot hi if necessary
            maxRMS = ((maxDB - fitCoefs(2)) / fitCoefs(1));
            extrap_fitX_hi = linspace(max(log10(rms(isOn))), maxRMS, nExtrapFit);
            extrap_fitY_hi = polyval(fitCoefs,extrap_fitX_hi);

        else  % toggle data point(s)
            % find smallest euclidean distance: edist = sqrt((x2-x1).^2 + (y2-y1).^2)
            edist = sqrt((log10(rms)-x).^2 + (db-y).^2); % should this be diff depending on whether axis is logged?
            [temp,idx]=min(abs(edist));
            isOn(idx) = 1-isOn(idx); %toggle on/off
            if but==3 %right-click, set all lower points to this value also
                isOn(1:idx) = isOn(idx);
            end

            % recalc model
            fitCoefs = polyfit(log10(rms(isOn)),db(isOn),1);

            Correlation = corrcoef(db(isOn), polyval(fitCoefs,log10(rms(isOn))));
            r2 = Correlation(1,end)^2; %ALT: 1 - sum((log10(rms)-fitY).^2) / sum((log10(rms)-mean(log10(rms))).^2)

            
            if isnan(r2)
                fitX = NaN;
                fitY = NaN;
                extrap_fitX = NaN;
                extrap_fitY = NaN;
                extrap_fitX_hi = NaN;
                extrap_fitY_hi = NaN;
            else
                fitX = linspace( min(log10(rms(isOn))),max(log10(rms(isOn))),nFit);
                fitY = polyval(fitCoefs,fitX);   

                minRMS = ((minDB - fitCoefs(2)) / fitCoefs(1));
                extrap_fitX = linspace(0, minRMS, nExtrapFit);
                extrap_fitY = polyval(fitCoefs,extrap_fitX);

                maxRMS = ((maxDB - fitCoefs(2)) / fitCoefs(1));
                extrap_fitX_hi = linspace(max(log10(rms(isOn))), maxRMS, nExtrapFit);
                extrap_fitY_hi = polyval(fitCoefs,extrap_fitX_hi); 
            end
        end
        

        % update plot
        if log10Axis
            set(hPointsOn, 'xdata', log10(rms(isOn)), 'ydata', db(isOn));
            set(hPointsOff, 'xdata', log10(rms(~isOn)), 'ydata', db(~isOn));
            set(hFit, 'xdata', fitX, 'ydata', fitY);
            set(hFitExtrap, 'xdata', extrap_fitX, 'ydata', extrap_fitY);
            set(hFitExtrap_hi, 'xdata', extrap_fitX_hi, 'ydata', extrap_fitY_hi);
            xlabel('log10(RMS)');
            ylim([minDB, maxDB]);
            axis(axis)
            set(hText,'Position',[minRMS,maxDB])
        else
            set(hPointsOn, 'xdata', rms(isOn), 'ydata', db(isOn));
            set(hPointsOff, 'xdata', rms(~isOn), 'ydata', db(~isOn));
            set(hFit, 'xdata', exp10(fitX), 'ydata', fitY);
            set(hFitExtrap, 'xdata', exp10(extrap_fitX), 'ydata', extrap_fitY);
            set(hFitExtrap_hi, 'xdata', exp10(extrap_fitX_hi), 'ydata', extrap_fitY_hi);
            xlabel('RMS');
            ylim([minDB, maxDB]);
            axis(axis)
            set(hText,'Position',[exp10(minRMS),maxDB])
        end
        set(hText,'String',sprintf('r^{ 2} = %1.7f',r2));

    end

    % close fitting window (if not closed already)
    try
        close(hFig);
    catch ME %#ok e.g. if closed already
    end
    
    % calc additional return variables
    n = sum(isOn);
    nPointsExcluded = sum(isOn==0);
    excludedIdx = find(isOn==0);
    
    % check that valid
    if isnan(r2)
        if getlog10icalInput('Manually selected model is invalid. Use auto fit instead? (y/n): ')
            [fitCoefs,r2,n,nPointsExcluded,excludedIdx]=calib_fit_auto(rms, db);
        else
            error('calib_fit_manual:modelFitFailure','Manual fit failed.')
        end
    end
    
end