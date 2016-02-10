close all
clear all

a = adaptiveTrack(adaptiveTrack.getDummyParams());
b = adaptiveTrack(adaptiveTrack.getDummyParams());
c = adaptiveTrack(adaptiveTrack.getDummyParams());
tInterleaver = trackInterleaver([a b c],'pseudorandom'); % or 'random', 'sequential'

for i = 1:100
    trk = tInterleaver.selectTrack;
    if isempty(trk)
        break
    end
    trk.Update(true);
    pause(.15);
end