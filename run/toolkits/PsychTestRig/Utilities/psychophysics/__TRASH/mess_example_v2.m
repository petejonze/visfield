clearAbsAll();
clearJavaMem();

s = AdaptiveTrack(AdaptiveTrack.getDummyParams)

% run
s.getTargetValue
s.Update(true);
s.getTargetValue
s.Update(true);
s.Update(true);
s.Update(false);
s.goBackN(1)