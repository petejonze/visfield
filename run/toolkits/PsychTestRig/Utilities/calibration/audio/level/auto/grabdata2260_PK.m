function out = grabdata2260_2(SO, filesize, infoflag)
% function out = grabdata2260_2(SO, filesize, infoflag)
%
% -----------------------------------------------------------
% Get binary data back from the 2260 over the serial line
% Set for type 2260 meter running software BK-7219 version 1
% -------------------------------------------------------------
%
% Used mgetdatafile2260.m 
% Do not use direct as the 'COPY' command needs to be run first ...
% 
% Input: S0 = serial-port connection
% Output: array of 'uint8' data (see 'help fread');
%
%
% Based on Steve's grabdata2260_2, but 
% (1) pulls back data in 256-byte chunks until no more is got
% (2) prettyprints byte counters
% (3) output is 'uint8'
% (change 1 was made as Steve had a 'bytes.available' loop but that is 
% unrealiable for the 2260 ... whether or not its the same problem as this
% I don't know but it sure looks like it:
% http://www.mathworks.com/support/solutions/31312.shtml
%
%
% MAA Summer 2003 4vii03
% PK October 2005 (Rewritten: file now read in one pass - Matlab 7.1 fix)
% Edited by Pete Jones , 15/07/2010
%-----------------------------------------



warning off MATLAB:deblank:NonStringInput
warning off MATLAB:serial:fread:unsuccessfulRead

blockcounter = 1;
DataLines = [];
blocksize = filesize;

[thisdataline count] = fread(SO,blocksize,'uint8');
for n=1:length(thisdataline)
    DataLines(blockcounter) = thisdataline(n);
    blockcounter = blockcounter+1;
end;
if infoflag >= 1; fprintf('%d ', count); end

fprintf('%d\n');

warning on MATLAB:deblank:NonStringInput;
warning off MATLAB:serial:fread:unsuccessfulRead;

out = DataLines;