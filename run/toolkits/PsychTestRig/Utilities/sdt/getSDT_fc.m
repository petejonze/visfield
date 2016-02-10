function [dprime, lambda_centre] = getSDT_fc(respInt, targInt, adjustIfInf, adjustmentAmount)
%GETSDT shortdesc.
%
%   compute sdt params for 2AFC paradigm
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
% @Todo:            allow user to specify hit/false alarm proportions
% directly?
%
% v1    :   basic
% v2    :   adjustmentMethod
% v3    :   modified to take matrix instead of just vector

    % init
    if nargin < 3 || isempty(adjustIfInf)
        adjustIfInf = false;
    end
    if nargin < 4 || isempty(adjustmentAmount)
        adjustmentAmount = .5; % equivalent to changing proportion by 1/(2N), where N is the number of trials (i.e. number of noise trials, or number of signal trials)
    end
    
    % adjust to [0 1] if 1's and 2's
    if all(ismember(unique(targInt),[1 2]))
        targInt = targInt-1;
    end
    if all(ismember(unique(respInt),[1 2]))
        respInt = respInt-1;
    end

    % count absolute numbers 
    correctInt1 = respInt == targInt & targInt == 0;
    correctInt2 = respInt == targInt & targInt == 1;
    nCorrectInt1 = sum(correctInt1);
    nCorrectInt2 = sum(correctInt2);
    nInt1Trials = sum(targInt == 0); % <S,N>
    nInt2Trials = sum(targInt == 1); % <N,S>
    
    % Adjust counts if necessary (M&C p8)
    if adjustIfInf
        % Int1 [<S,N>]
        if any(nCorrectInt1 == nInt1Trials)
            i = nCorrectInt1 == nInt1Trials;
            nCorrectInt1(i) = nCorrectInt1(i) - adjustmentAmount;
        elseif any(nCorrectInt1 == 0)
            i = nCorrectInt1 == 0;
            nCorrectInt1(i) = 0 + adjustmentAmount;
        end
        % Int2 [<S,N>]
        if any(nCorrectInt2 == nInt2Trials)
            i = nCorrectInt2 == nInt2Trials;
            nCorrectInt2(i) = nCorrectInt2(i) - adjustmentAmount;
        elseif any(nCorrectInt2 == 0)
            i = nCorrectInt2 == 0;
            nCorrectInt2(i) = 0 + adjustmentAmount;
        end
    end

    % calc proportions
    SN_pc = nCorrectInt1./nInt1Trials; % <S,N> percent correct
    NS_pc = nCorrectInt2./nInt2Trials; % <N,S> percent correct

    % dprime
    dprime = norminv(SN_pc) + norminv(NS_pc);
    dprime = dprime / sqrt(2); % adjust to make comparable with yes/no
    
    % lambda / bias
    % NS - SN is from wickens. It means that a bias towards interval one
    % (SN_pc) is reflected by a NEGATIVE value, whilst a bias in favour of
    % responding 'interval two' (NS) will be reflected by a POSITIVE value.
    %
    % "The negative values imply a shift of the criterion toward the left
    % and an apparent preference for FIRST responses" [p102]
    lambda_centre = 0.5 * (norminv(NS_pc) - norminv(SN_pc)); % (norminv(NS_pc) - norminv(SN_pc)); % (norminv(SN_pc) - norminv(NS_pc)); ?
    lambda_centre = lambda_centre * sqrt(2); % adjust as above
    % n.b. the textbooks are quite quiet on whether to adjust bias in 
    % 2AFC to make comparable with yes/no (as is done in the sensitivity
    % case). Seems sensible to do so though, and multiplication seems to be
    % the appropriate method (e.g. see simulating_bias_v3.m for an
    % empirical demonstration of this point)
    
%     % ALT: (but more natural to do as above)
%     H = respInt_2afc_bi == 1 & targInt == 1; H = sum(H)/sum(targInt == 1);
%     F = respInt_2afc_bi == 1 & targInt == 0; F = sum(F)/sum(targInt == 0);
%     dprime_2AFC_bi_alt = norminv(H) - norminv(F);
%     dprime_2AFC_bi_alt = dprime_2AFC_bi_alt / sqrt(2);
%     c_2AFC_bi_alt = -0.5 * (norminv(F) + norminv(H));
%     c_2AFC_bi_alt = c_2AFC_bi_alt * sqrt(2);

end


%     % <S,N> percent correct
%     SN_pc = respInt == targInt & targInt == 0;
%     SN_pc = sum(SN_pc)/sum(targInt == 0);
%     
%     % <N,S> percent correct
%     NS_pc = respInt == targInt & targInt == 1;
%     NS_pc = sum(NS_pc)/sum(targInt == 1);
%     
%     % M&C (p8)
%     if adjustIfInf
%         nSamples = sum(targInt == 0);
%         switch lower(adjustmentMethod)
%             case 'proportion'
%                 adjustmentAmount = 1/nSamples; % equivalent to 
%             otherwise
%                 adjustmentAmount = str2double(adjustmentMethod); % e.g. '0.5'
%         end
%         if SN_pc == 1
%             SN_pc = 1 - adjustmentAmount;
%         elseif SN_pc == 0
%             SN_pc = adjustmentAmount;
%         end
%         %
%         nSamples = sum(targInt == 1);
%         switch lower(adjustmentMethod)
%             case 'proportion'
%                 adjustmentAmount = 1/nSamples;
%             otherwise
%                 adjustmentAmount = str2double(adjustmentMethod); % e.g. '0.5'
%         end
%         if NS_pc == 1
%             NS_pc = 1 - adjustmentAmount;
%         elseif NS_pc == 0
%             NS_pc = adjustmentAmount;
%         end
%     end