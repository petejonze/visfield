%% init
clear all
close all
clc
import visfield.zest.*

% -------------------------------------------------------------------------
%% run tests
ThresholdPriors.runTests();
ZestState.runTests();
Zest.runTests();
myZestWrapper.runTests();
ZestPlot.runTests();

% -------------------------------------------------------------------------
%% run an example vanilla Zest routine ( see also Zest.runTests() )

% initialise prior
prior = ThresholdPriors(1, 155, false);
Z = Zest(1, prior, 0:30);

% initialise observer parameters
trueThresh = [
    NaN, NaN, NaN,  15,  15,  12,  9,  NaN,  NaN,  NaN
    NaN, NaN,  15,  14,  15,  15,  14,  13,  NaN,  NaN
    NaN,  14,  17,  20,  18,  20,  20,  17,   12,  NaN
    10,   12,  18,  20,  19,  20,  19, NaN,   12,  NaN
    11,   16,  18,  18,  17,  20,  17, NaN,   11,  NaN
    NaN,  14,  17,  20,  18,  20,  20,  15,   12,  NaN
    NaN, NaN,  15,  16,  14,  15,  17,  13,  NaN,  NaN
    NaN, NaN, NaN,  9,   11,  9,   7,  NaN,  NaN,  NaN
    ];
inoise = 3; % std/slope of psychometric function, in dB

% run loop
while ~Z.isFinished()
    % pick a state
    [x_deg, y_deg, targLum_dB, i, j] = Z.getTarget();
    % test the point
    anscorrect = (targLum_dB+randn()*inoise) < trueThresh(i, j); % based on above matrix
    % update the state, given observer's response
    Z.update(x_deg, y_deg, targLum_dB, anscorrect, 400);
end

% report summary
fprintf('\nTrue Thresholds:\n');
disp(trueThresh)
fprintf('Estimated Thresholds:\n');
disp(Z.thresholds)
fprintf('Total n stimulus presentations: %i\n', sum(Z.nPresentations(~isnan(Z.nPresentations))));

% -------------------------------------------------------------------------
%% run a more advanced routine using the ZestManager class
%  myZestManager specifies a custom grid and adds blindspot testing
%  see also myZestManager.runTests()

% initialise grid
Z = myZestWrapper(1, 155, 0:30, true);

% initialise observer parameters
trueThresh = [
    NaN, NaN,  15,  14,  15,  15,  14,  13,  NaN,  NaN
    NaN,  14,  17,  20,  18,  20,  20,  17,   12,  NaN
    10,   12,  18,  20,  19,  20,  19,  18,   12,  NaN
    11,   16,  18,  18,  17,  20,  17,   0,   11,  NaN
    NaN,  14,  17,  20,  18,  20,  20,  15,   12,  NaN
    NaN, NaN,  11,  10,  10,  10,  12,  13,  NaN,  NaN
    ];
inoise = 3; % std/slope of psychometric function, in dB

% run loop
while ~Z.isFinished()
    % pick a state
    [x_deg, y_deg, targLum_dB, i, j] = Z.getTarget();
    % test the point
    anscorrect = (targLum_dB+randn()*inoise) < trueThresh(i, j); % based on above 'true thresholds' matrix
    % update the state, given observer's response
    Z.update(x_deg, y_deg, targLum_dB, anscorrect, 400);
end

% report summary
fprintf('\nTrue Thresholds:\n');
disp(trueThresh)
fprintf('Estimated Thresholds:\n');
disp(Z.thresholds)
fprintf('\nTotal n stimulus presentations: %i\n', Z.getTotalNPresentations());