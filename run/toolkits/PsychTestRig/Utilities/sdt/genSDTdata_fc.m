function [resp, targ, DV] = genSDTdata_fc(dprime_fc, lambda, nTrials, lambda_std)
% from simulating_bias_v7.m


    if nargin < 4 || isempty(lambda_std)
        lambda_std = 0; % else jitter lambda by 0-mean normal pdf with std of lambda_std
    end
    
    %% init
    sd = 1; % unit std
    X1_N_mu = 0;
    X1_N_sd = sd;
    X1_S_mu = dprime_fc; % assume same for both here (not necessarily so)
    X1_S_sd = X1_N_sd; % assume equal signal & noise variability
    X2_N_mu = 0;
    X2_N_sd = sd;
    X2_S_mu = dprime_fc;
    X2_S_sd = X2_N_sd;
    

    %% run
    
    % targ
    targ = Shuffle([zeros(floor(nTrials/2),1); ones(nTrials-floor(nTrials/2),1)]);

    % resp
    resp = nan(size(targ));
    DV = nan(size(targ));
    for i=1:nTrials % this could be vectorised, but clearer this way

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 2AFC
        % bivariate derivation
        % draw a variable from each distribution
        if targ(i)==1 % take this to mean signal in 2nd interval
            x1 = normrnd(X1_N_mu,X1_N_sd);
            x2 = normrnd(X2_S_mu,X2_S_sd);
        else
            x1 = normrnd(X1_S_mu,X1_S_sd);
            x2 = normrnd(X2_N_mu,X2_N_sd);
        end
        % make decision
        c =  normrnd(-lambda,lambda_std); % a bias towards interval one will be reflected by a NEGATIVE value (following Wickens convention?)
        if (x2 - x1) > c 
            resp(i) = 1;
        else
            resp(i) = 0;
        end
        
        % record DV
        DV(i) = x2 - x1;
    end


end