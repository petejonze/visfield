function [dprime, lambda_centre, lambda, H, F] = getSDT(resp, targ, adjustIfInf, adjustmentAmount)
%GETSDT shortdesc.
%
%   compute sdt params for yes/no paradigm
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	23/11/11
% @Last Update:     23/11/11
%
% @Todo:            <blank>
%
% v1    :   basic
% v2    :   modified to take matrix instead of just vector
% v3    :   now returns lambda also
%
% NEGATIVE c == criterion nearer to the noise distribution / bias to say
% "yes"
% POSITIVE c == bias to say "no"    

    % init
    if nargin < 3 || isempty(adjustIfInf)
        adjustIfInf = false;
    end
    if nargin < 4 || isempty(adjustmentAmount)
        adjustmentAmount = .5; % equivalent to changing proportion by 1/(2N), where N is the number of trials (i.e. number of noise trials, or number of signal trials)
    end
    
    % adjust to [0 1] if 1's and 2's
    if all(ismember(unique(targ),[1 2]))
        targ = targ-1;
    end
    if all(ismember(unique(resp),[1 2]))
        resp = resp-1;
    end
    
    % count absolute numbers 
    falseAlarms = resp == 1 & targ == 0;
    hits = resp == 1 & targ == 1;
    Nf = sum(falseAlarms);
    Nh = sum(hits);
    nNoiseTrials = sum(targ == 0);
    nSignalTrials = sum(targ == 1);
    
    % Adjust counts if necessary (M&C p8)
    if adjustIfInf
        % F
        if Nf == nNoiseTrials
            Nf = Nf - adjustmentAmount;
        elseif Nf == 0
            Nf = 0 + adjustmentAmount;
        end
        % H
        if Nh == nSignalTrials
            Nh = Nh - adjustmentAmount;
        elseif Nh == 0
            Nh = 0 + adjustmentAmount;
        end
    end
    
    % calc proportions
    F = Nf./nNoiseTrials; %./ in case a vector
    H = Nh./nSignalTrials;
        
    % calculate stats
    dprime = norminv(H) - norminv(F);
    lambda_centre = -0.5 * (norminv(F) + norminv(H)); % n.b. lambda CENTRE!
    lambda = -norminv(F);
    
end