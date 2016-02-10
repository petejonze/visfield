deviceName = 'C-Media USB Headphone Set';
calib=calib_load('pbt_n2_31-01-11.mat',deviceName); %load calib
Fs = 44100;
d=30;
db = 60;
x = getCalibratedPureTone(1000,Fs,d,0,db,[0],calib,false);

% plot(x)
PsychPortTestPlay(x,Fs,[0],calib)

%% 24 speaker ring example

deviceName = 'MOTU PCI ASIO';
calib=calib_load('pci24_test1_07-04-11.mat',deviceName); %load calib
Fs = 44100;
d=5;
db = 60;


outChan = 13

x = getCalibratedPureTone(1000,Fs,d,0,db,outChan,calib,false);

% plot(x)
PsychPortTestPlay(x,Fs,outChan,calib)