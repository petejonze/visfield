clc
clearAbsAll();
clearJavaMem();

s = AdaptiveTrack(AdaptiveTrack.getDummyParams) %#ok

% run
s.getDelta()
s.update(true);
s.getDelta()
s.update(true);
s.update(false);
s.update(true);
s.update(true);
s.update(false);
s.getCurrentStage()
s.update(true);
s.getCurrentStage()
s.update(true);
s.update(false);
s.update(true);
s.update(true);
s.update(true);
s.update(true);
s.update(true);
s.update(true);
s.update(true);
s.update(true);
s.wasAReversal()
s.update(false);
s.wasAReversal()
s.update(true);
s.update(true);
s.update(false);
s.update(true);
s.update(true);
s.update(false);
s.update(true);
s.update(true);
s.update(false);
s.goBackN(16);
s.update(false);
s.update(true);
s.update(true);
s.update(true);
s.getDelta()

% query
[vals,idx,N,stage] = s.getReversals()
s.getReversals(2)
s.getReversals(2,false)

s.computeThreshold()