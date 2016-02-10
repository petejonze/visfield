clc
clearAbsAll();
clearJavaMem();

params = [];
params.startVal = 8;
params.stepSize = [.1]; % 1./[1.1 1.05 1.001];
params.downMod = [1];
params.nReversals = [2];
params.nUp = 1; % [1 1 1];
params.nDown = 1; % [1 1 1];
params.isAbsolute = true;
params.minVal = 0;
params.maxVal = 12;
params.minNTrials = 10;
params.maxNTrials = 100;
params.verbosity = 2;
s = AdaptiveTrack(params) %#ok

% run
for i = 1:200
    s.update(rand()>0.5);
end
% s.getDelta()
% s.update(true);
% s.getDelta()
% s.update(true);
% s.update(false);
% s.update(true);
% s.update(true);
% s.update(false);
% s.getCurrentStage()
% s.update(true);
% s.getCurrentStage()
% s.update(true);
% s.update(false);
% s.update(true);
% s.update(true);
% s.update(true);
% s.update(true);
% s.update(true);
% s.update(true);
% s.update(true);
% s.update(true);
% s.wasAReversal()
% s.update(false);
% s.wasAReversal()
% s.update(true);
% s.update(true);
% s.update(false);
% s.update(true);
% s.update(true);
% s.update(false);
% s.update(true);
% s.update(true);
% s.update(false);
% % s.goBackN(16);
% s.update(false);
% s.update(true);
% s.update(true);
% s.update(true);
% s.getDelta()
% 



% query
[vals,idx,N,stage] = s.getReversals()
s.getReversals(2)
s.getReversals(2,false)

s.computeThreshold()