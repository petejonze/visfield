function null = mstartmeasurement2260(s, duration_secs, infoflag)
% function null = mstartmeasurement2260(s, duration_secs, infoflag)
%
%------------------------------------------------------------------------
% Starts a measurement on the 2260, waits for the duration of the recording, then returns
% (also checks its running when its supposed to be and paused when its finished)
% Set for type 2260 meter running software BK-7219 version 1
%-----------------------------------------------------------------
%
% Inputs =
%    s              = serial-port connection made by setup2260
%    duration_secs  = how long to wait for = duration of recording
%    infoflag       = 0 (nothing) or 1 (running infomation)
%
% Due to various timelags in the serial port connections and code, this
% code will stop about 5 seconds (I think) after the recording has actually
% finished.
%
% Assumes serial port is already open: e.g.
% >> s = setup2260('COM3', 4800);
% >> mstartmeasurement2260(s, 20, 1);
%
% Used by mmeasurelevelofspeaker1, etc
%
% MAA Summer 2003 4vii03
% Edited by Pete Jones , 15/07/2010
%---------------------------------


% start ...
if infoflag >=1; fprintf('starting measurement on 2260 ...                '); end;
command = sprintf(':M:R_S');
bkoutput = sendto2260BIN(s, command) ;
if infoflag >=1; fprintf('output = %s\n', bkoutput); end;


% checking pause/go ...
if infoflag >=1; fprintf('checking pause again (expecting M) ...          '); end;
command = sprintf(':M:S?');
bkoutput = sendto2260BIN(s, command) ;
if infoflag >=1; fprintf('output = %s', bkoutput); end;


% wait while it records ...
if infoflag >= 1; fprintf('waiting for %d seconds while the meter records ... ', duration_secs); end
for n=1:(duration_secs)
    pause(1);
    if infoflag >= 1; fprintf('%d ', n); end
end;
if infoflag >= 1; fprintf('\n'); end


% checking pause/go ...
if infoflag >=1; fprintf('checking pause again (expecting P) ...          '); end;
command = sprintf(':M:S?');
bkoutput = sendto2260BIN(s, command) ;
if infoflag >=1; fprintf('output = %s', bkoutput); end;


if infoflag >= 1; fprintf('\n'); end


% the end!
%----------------------