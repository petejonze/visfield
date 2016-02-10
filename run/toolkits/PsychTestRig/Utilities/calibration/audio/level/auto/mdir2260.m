function bkdirectory = mdir2260(s, dir2260, infoflag)
% function bkdirectory = mdir2260(s, dir2260, infoflag)
%
%----------------------------------------------------
% Get a directory listing of a directory on the 2260
% Set for type 2260 meter running software BK-7219 version 1
%-----------------------------------------------------
% 
% Inputs =
%    s        = serial-port connection made by setup2260
%    dir2260  = directory to look at (usually 'C:\DATA\MEAS1')
%    infoflag = 0 (nothing) or 1 (running infomation)
%
% Returns the directory listing in a structure:
%   number of files found
%   for each file, the name and the info (both *without* the double quotes)
%
% Assumes serial port is already open: e.g.
% >> s = setup2260('COM3', 4800);
% >> bkdir = mdir2260(s, 'C:\DATA\MEAS1', 1)
%
% Used by mmeasurelevelofspeaker1, etc and mdeletealldatafiles2260.m
%
%
% MAA Summer 2003 4vii03
% Edited by Pete Jones , 15/07/2010
%---------------------------------


% put double quotes around filename
dirname = sprintf('"%s"', dir2260);


% cd 
if infoflag >=1; fprintf('moving to directory ''%s'' on 2260''s local drive ... ', dir2260); end;
command = sprintf(':SY:F_M:CH_D? %s', dirname);
bkoutput = sendto2260BIN(s, command);
if infoflag >=1; if strcmp(bkoutput, '') == 1; fprintf('output = %s\n', bkoutput); end; end;
if infoflag >=1; if strcmp(bkoutput, '') ~= 1; fprintf('output = %s', bkoutput); end; end;


% dir
if infoflag >=1; fprintf('listing directory ''%s'' on 2260''s local drive ...   ', dir2260); end;
command = sprintf(':SY:F_M:DIR?');
bkoutput = sendto2260BIN(s, command);
if infoflag >=1; fprintf('output = %s', bkoutput); end;


% prettyprint the directory listing
if infoflag >=1; fprintf('sorting that list ... \n'); end;
bkoutputfull = bkoutput;
[thisword, bkoutput] = strtok(bkoutput, ',');  bkdirectory.nfiles = str2num(thisword);
if infoflag >=1; fprintf('nfiles = %d\n', bkdirectory.nfiles); end;
for n=1:bkdirectory.nfiles 
   [thisword, bkoutput] = strtok(bkoutput, ',');  bkdirectory.file(n).filename = thisword(2:length(thisword)-1); % strip the double quotes too
   [thisword, bkoutput] = strtok(bkoutput, ',');  bkdirectory.file(n).fileinfo = thisword(2:length(thisword)-2); % ditto 
   if infoflag >=1; fprintf('#%d ... name = ''%s''   info = ''%s''\n', n, bkdirectory.file(n).filename, bkdirectory.file(n).fileinfo); end;
end;


% the end!
%----------------------