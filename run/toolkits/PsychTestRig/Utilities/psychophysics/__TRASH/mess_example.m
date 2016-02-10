%% simple

s = AdaptiveTrack(AdaptiveTrack.getDummyParams)

% run
s.getTargetValue
s = s.Update(true);
s.getTargetValue
s = s.Update(true);
s = s.Update(true);
s = s.Update(false);
s = s.Update(false);

%% custom params
standard = 1000;
initialDifference = 100;
stepValIsAbs = true;
leadIn_nUp = 1;
leadIn_nDown = 1;
leadIn_stepSize = 10;
leadIn_nReversalsLim = 2;
leadIn_finalDirection = 1;
main_nUp = 1;
main_nDown = 2;
main_stepSize = 2;
main_nReversalsLim = 4;
nReversals_analysis = 4;
maxN = 50;
minVal = 1000;
maxVal = 1500;
verbosity = 2;

% create
s = AdaptiveTrack(standard,initialDifference,stepValIsAbs,...
    leadIn_nUp,leadIn_nDown,leadIn_stepSize,leadIn_nReversalsLim,leadIn_finalDirection,...
    main_nUp,main_nDown,main_stepSize,main_nReversalsLim,...
    nReversals_analysis,maxN,minVal,maxVal,...
    verbosity);

% run
s.getTargetValue
s = s.Update(true);
s.getTargetValue
s = s.Update(true);
s = s.Update(true);
s = s.Update(false);
s = s.Update(false); %#ok

%% Alternatively we could simulate an observer
% create
s = AdaptiveTrack(standard,initialDifference,stepValIsAbs,...
    leadIn_nUp,leadIn_nDown,leadIn_stepSize,leadIn_nReversalsLim,leadIn_finalDirection,...
    main_nUp,main_nDown,main_stepSize,main_nReversalsLim,...
    nReversals_analysis,maxN,minVal,maxVal,...
    verbosity);

% run
tresh = 1020;
intnoise = 10;
while ~s.isFinished
    anscorrect = false;
    if (s.getTargetValue + randn()*intnoise) > tresh
        anscorrect = true;
    end
    s = s.Update(anscorrect);
end