% init
clc
close all
clearAbsAll();
clearJavaMem();

% observer params
mu = 5;
sigma = 2;

%% constant stmuli ---------------------------

vals = 1:2:9;
nTrialsPerCond = 100;
cs1 = ConstantStimuli(vals, nTrialsPerCond);
cs2 = ConstantStimuli(vals+1, nTrialsPerCond);
ti = TrackInterleaver({cs1 cs2}, 'pseudorandom');

% run
while ~ti.isFinished()
    x = ti.getValue();
    anscorrect = x > normrnd(mu,sigma);
    ti.update(anscorrect);
end

% query/plot
figure();
plot(cs1.values, cs1.getPC(), 'o', cs2.values, cs2.getPC(), 'rs');

%% adaptive ---------------------------
close all

params = [];
params.startVal   	= 9;
params.stepSize  	= [1 .25];
params.downMod      = 1;
params.nReversals 	= [2 16];
params.nUp        	= 1;
params.isAbsolute	= true;
params.minVal     	= 0;
params.maxVal   	= 20;
params.maxNTrials 	= 100;
params.verbosity 	= 0;
%
params.nDown        = [1 1];
aT1 = AdaptiveTrack(params);  
%
params.nDown        = [1 2];    
aT2 = AdaptiveTrack(params); 
%
params.nDown        = [1 3];    
aT3 = AdaptiveTrack(params); 
%
ti = TrackInterleaver({aT1 aT2 aT3}, 'random');

% run
while ~ti.isFinished()
    x = ti.getValue();
    anscorrect = x > normrnd(mu,sigma);
    ti.update(anscorrect);
end

% query/plot
figure();
hold on
x = linspace(0,9,1000); plot(x, normcdf(x, mu, sigma), '-');
plot(getTrackThresh(aT1.deltaHistory, 8), .5, 'o', getTrackThresh(aT2.deltaHistory, 8), .707, 'g^', getTrackThresh(aT3.deltaHistory, 8), .794, 'rs');