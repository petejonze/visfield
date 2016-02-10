function output_bytesgot = mgetdatafile2260(s, filename2260, localfilename, infoflag)
% function output_bytesgot = mgetdatafile2260(s, filename2260, localfilename, infoflag)
%
%-----------------------------------------------------------------
% Copy a 2260 data file down the serial connection to a local file
% Set for type 2260 meter running software BK-7219 version 1
%-----------------------------------------------------------------
% 
% Inputs =
%    s             = serial-port connection made by setup2260
%    filename2260  = 2260 file to use (e.g. 'C:\DATA\MEAS1\0002.S1A')
%    localfilename = local file to use (e.g. 'U:\michael\matlabtoolbox_rewrite\version2_local\soundlevelmeter\temp2260.bin');
%    infoflag      = 0 (nothing) or 1 (running infomation)
%
% Returns the number of bytes succesfully downloaded
% The local file is a binary copy of the 2260 file and is read by mparse2260binaryfile
%
% Assumes serial port is already open: e.g.
% >> s = setup2260('COM3', 4800);
% >> pause(6);
% >> mgetdatafile2260(s, 'C:\DATA\MEAS1\0001.S1A', 'temp2260.bin', 1)
% >> mparse2260binaryfile('temp2260.bin', 1);
%
% Used by mmeasurelevelofspeaker1, etc
%
% MAA Summer 2003 4vii03
%
% version _matlab7 ...
% PK October 2005 (Lines 33-47: Added code to retrieve total filesize,
%                  Line 65: Added new filesize parameter to grabdata function - Matlab 7.1 fix)
% Edited by Pete Jones , 15/07/2010
%---------------------------------

if infoflag >= 1; fprintf('\n'); end

%PK - get file size
command = sprintf(':SY:F_M:DIR?');
bkoutput = sendto2260BIN(s, command);
[thisword, bkoutput] = strtok(bkoutput, ',');  bkdirectory.nfiles = str2num(thisword);
if infoflag >=1; fprintf('nfiles = %d\n', bkdirectory.nfiles); end;
% There should only be 1 file in the current directorys so we don't need to
% loop through the file list, just access the first file
[thisword, bkoutput] = strtok(bkoutput, ',');  bkdirectory.file(1).filename = thisword(2:length(thisword)-1); % strip the double quotes too
[thisword, bkoutput] = strtok(bkoutput, ',');  bkdirectory.file(1).fileinfo = thisword(2:length(thisword)-2); % ditto 
fileinfo = bkdirectory.file(1).fileinfo;
[thisword, fileinfo] = strtok(fileinfo, ' ');
[thisword, fileinfo] = strtok(fileinfo, ' ');
[thisword, fileinfo] = strtok(fileinfo, ' ');
filesize = str2num(thisword);
if infoflag >=1; fprintf('filesize = %d \n',filesize); end
%PK - end


%PETE - START
dispStruct(bkdirectory)
for argh=1:length(bkdirectory)
   disp(bkdirectory.file)
end



%PETE - END




% copy file to output  ... 
% put double quotes around filename
filename = sprintf('"%s"', filename2260);
if infoflag >=1; fprintf('copying file %s from 2260 to computer  ... ', filename); end;
command = sprintf(':SY:F_M:CO? %s', filename);
bkoutput = sendto2260BIN(s, command) ;
if infoflag >=1; fprintf('output = %s', bkoutput); end;

% grab data
if infoflag >=1; fprintf('getting binary data ... '); end;
warning off MATLAB:serial:fgets:unsuccessfulRead

%bkdata = grabdata2260_2(s, infoflag);   % this returns a 'uint8' datatype, so svae it alter using 'unit8' too ...
%PK - get file data - filesize is also passed
fprintf('attempting to grab data from file of size ''%s'' ... \n', filesize);
bkdata = grabdata2260_PK(s, filesize, infoflag);   % this returns a 'uint8' datatype, so svae it alter using 'unit8' too ...
%PK - end

warning on MATLAB:serial:fgets:unsuccessfulRead
if infoflag >= 1; fprintf('total bytes = %d\n', length(bkdata)); end
output_bytesgot = length(bkdata);

% save data
if infoflag >= 1; fprintf('opening local file ''%s'' ... \n', localfilename); end
fid = fopen(localfilename, 'wb');
if infoflag >= 1; fprintf('saving data ... '); end
count = fwrite(fid, bkdata, 'uint8');
if infoflag >= 1; fprintf('count = %d\n', count); end
fclose(fid);

if infoflag >= 1; fprintf('\n'); end


% the end!
%----------------------