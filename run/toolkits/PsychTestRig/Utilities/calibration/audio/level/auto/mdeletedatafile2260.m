function null = mdeletedatafile(s, filename2260, infoflag)
% function null = mdeletedatafile(s, filename2260, infoflag)
%
% -----------------------------------------------------------------
% Delete a file in a given directory on the 2260
% Set for type 2260 meter running software BK-7219 version 1
%-----------------------------------------------------------------
%
% Inputs =
%    s             = serial-port connection made by setup2260
%    filename2260  = 2260 file to delete (e.g. 'C:\DATA\MEAS1\0002.S1A')
%    infoflag      = 0 (nothing) or 1 (running infomation)
%
%
% Assumes serial port is already open: e.g.
% >> s = setup2260('COM3', 4800);
% >> mdeletedatafile2260(s, 'C:\DATA\MEAS1\0001.S1A', 1)
%
% Used by mdeletealldatafiles2260.m
%
% MAA Summer 2003 4vii03
% Edited by Pete Jones , 15/07/2010
%---------------------------------


% put double quotes around filename
filename = sprintf('"%s"', filename2260);

% delete
if infoflag >=1; fprintf('attempting to delete data file ''%s'' on 2260''s local drive ... ', filename); end;
command = sprintf(':SY:F_M:DE? %s', filename);
bkoutput = sendto2260BIN(s, command);
if infoflag >=1; if strcmp(bkoutput, '') == 1; fprintf('output = %s\n', bkoutput); end; end;
if infoflag >=1; if strcmp(bkoutput, '') ~= 1; fprintf('output = %s', bkoutput); end; end;

% the end!
%----------------------