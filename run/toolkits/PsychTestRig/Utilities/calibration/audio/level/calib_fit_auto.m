function [fitCoefs,r2,n,nPointsExcluded,excludedIdx]=calib_fit_auto(rmsVals, dbMeas)
%get comments format from calib_load
% It may seem counter-intuitive that noise in the predictor variable x induces a bias, but noise in the outcome variable y does not. Recall that linear regression is not symmetric: the line of best fit for predicting y from x (the usual linear regression) is not the same as the line of best fit for predicting x from y (see, for example, Draper & Smith, "Applied Regression Analysis"; page 5 of the 1966 edition


    criterion = .0001;

  	db = dbMeas;
   	rms = rmsVals;
    indices = 1:length(db);
    included = logical(ones(1,length(db)));
    
    % make initial fit
    fitCoefs = polyfit(log10(rms),db,1);
    fitY = polyval(fitCoefs,log10(rms));
    Correlation = corrcoef(db, fitY);
    r2 = Correlation(1,end)^2; %ALT: 1 - sum((log10(rms)-fitY).^2) / sum((log10(rms)-mean(log10(rms))).^2)
        
    while(1)
        
    	nDataPointsRemaining = sum(included);
        if nDataPointsRemaining <= 3 %requires 3 mininmum
            break;
        end

        % we expect that the higher values will be more trust-worthy than the
        % lower ones, so we will weight the errors accordings
        %weight = linspace(1,.1,length(db));
        weight = logspace(log10(1),log10(.1),length(db));

        % Find the biggest/most-distal outlie
        err = abs(db-fitY); % work out RMS errors
        err = err .* weight; %weight
        idx = ismember(err,max(err));
        idx2 = indices(idx);
        indices(idx) = [];
        included(idx2) = 0;

        % remove outlier and try reffiting
        rms = rmsVals(included);
     	db = dbMeas(included);
        fitCoefs = polyfit(log10(rms),db,1);
        fitY = polyval(fitCoefs,log10(rms));
        Correlation = corrcoef(db, fitY);
        new_r2 = Correlation(1,end)^2; %ALT: 1 - sum((log10(rms)-fitY).^2) / sum((log10(rms)-mean(log10(rms))).^2)

        % check for improvement
        if (new_r2 - r2) / r2 < criterion
            included(idx2) = 1; % reinstate point
            break % quit the loop
        else
            r2 = new_r2;
            % else is a big enough improvement, so continue
        end
    end

	% calc final model
	rms = rmsVals(included);
	db = dbMeas(included);
	fitCoefs = polyfit(log10(rms),db,1);
  	fitY = polyval(fitCoefs,log10(rms));
	Correlation = corrcoef(db, fitY);
 	r2 = Correlation(1,end)^2; %ALT: 1 - sum((log10(rms)-fitY).^2) / sum((log10(rms)-mean(log10(rms))).^2)
        
    n = length(db);
    excludedIdx = find(included==0);
    nPointsExcluded = length(excludedIdx);
    
    
%     % summary plot
%    	fitY = polyval(fitCoefs,db);
%     extrap_fitY = polyval(fitCoefs,[0 min(log10(rms))])
%     figure()    
%     hold on;
%         plot(log10(dbMeas(excludedIdx)),rmsVals(excludedIdx),'rx')
%         plot(log10(rms),db,'go')
%         plot(db,fitY,'-k')
%         plot([0 min(log10(rms))],extrap_fitY,':k')
%     hold off;

end