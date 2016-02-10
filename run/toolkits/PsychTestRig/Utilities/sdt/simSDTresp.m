function [resp, targ, strength] = simSDTresp(d,n)
%GETSDT shortdesc.
%
%   simulate 2AFC SDT responses for a vector of t trials, given unit variance and an
%   internal response seperation of d (dprime). Each item in t is a signal
%   strength
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         [resp, targ] = simSDTresp(1,repmat(10,50,1))
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	15/05/12
% @Last Update:     15/05/12
%
% @Todo:            <blank>
%
% v1    :   15/05/12    Basic

    % process inputs
%     if nargin < 1 || isempty(d)
%         error('simSDTresp:missingInput','Must specify drime [Arg1]')
%     end
%     if nargin < 2 || isempty(t)
%         error('simSDTresp:missingInput','Must specify trial vector [Arg2]')
%     end
    
    if nargin < 2 || isempty(n)
        n = length(d);
    else
        d = repmat(d,n,1);
    end

    % init
    
    resp = nan(n, 1);
    targ = nan(n, 1);
    strength = nan(n, 1);
    
    % generate resposnes for each trial
    for i = 1:n
        targInt = randi(2);
        s = [0 0]; s(targInt) = d(i);
        x1 = randn() + s(1);
        x2 = randn() + s(2);
        x = [x1 x2];
        %
        resp(i) = find(x==max(x));
        targ(i) = targInt;
        strength(i) = abs(x1-x2);
    end
end