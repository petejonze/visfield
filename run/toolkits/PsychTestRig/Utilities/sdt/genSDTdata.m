function [resp, targ] = genSDTdata(dprime, lambda_centre, nTrials)
% from simulating_bias_v7.m


    %% init
    sd = 1; % unit std
    N_mu = 0;
    N_sd = sd;
    S_mu = dprime; % assume same for both here (not necessarily so)
    S_sd = N_sd; % assume equal signal & noise variability

    %% run
    
    % targ
    targ = Shuffle([zeros(floor(nTrials/2),1); ones(nTrials-floor(nTrials/2),1)]);

    % resp
    resp = nan(size(targ));
    for i=1:nTrials % this could be vectorised, but clearer this way

        if targ(i) == 0
            x = normrnd(N_mu,N_sd);
        else
            x = normrnd(S_mu,S_sd);
        end
        
        % make decision
        if x > (dprime/2)+lambda_centre % DID IN A HURRY??
            resp(i) = 1;
        else
            resp(i) = 0;
        end
    end


end