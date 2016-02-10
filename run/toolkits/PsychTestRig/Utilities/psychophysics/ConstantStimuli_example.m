% init
clc
clearAbsAll();
clearJavaMem();

% user params
vals = 1:2:9;
mu = 5;
sigma = 2;
cs = ConstantStimuli(vals, 10);

% run
while ~cs.isFinished()
    x = cs.getDelta();
    anscorrect = x > normrnd(mu,sigma);
    cs.update(anscorrect);
end

% query
pc = cs.getPC();

% plot
figure();
plot(vals, pc, 'o');
