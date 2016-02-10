function null = msetmode2260(s, range_upperlimit_db, infoflag)
% function null = msetmode2260(s, range_upperlimit_db, infoflag)
%
%----------------------------------------------------------------
% set the measurementrange of the 2260 
% Set for type 2260 meter running software BK-7219 version 1
%---------------------------------------------------------------
%
% Inputs:
%    s              = serial-port connection made by setup2260
%    range_upperlimit_db   = range of meter (upperlimit)
%    infoflag       = 0 (nothing) or 1 (running infomation)
%
% Measurement ranges are 
% upperlimit = 80  ... 0 to 80 dB
% upperlimit = 90  ... 10 to 90 dB  (usual one for background noise of room)
% upperlimit = 100 ... 20 to 100 dB (usual one when playing a sound)
% upperlimit = 110 ... 30 to 120 dB
%
% Assumes serial port is already open: e.g.
% >> s = setup2260('COM3', 4800);
% >> msetrange2260(s, 100, 1)
%
% Used by mmeasurelevelofspeaker1 
%
%
% MAA Summer 2003 4vii03
% Edited by Pete Jones , 15/07/2010
%---------------------------------


% set recoding level on meter
offset_db = -1; % because the meter seems to round up 
if infoflag >=0; fprintf('setting upperlimit of range to %.0f db (with offset of %.0f dB) ...  \n', range_upperlimit_db, offset_db); end;
command = sprintf(':SE:M_PAR:R %.0f', (range_upperlimit_db+offset_db));
bkoutput = sendto2260BIN(s, command) ;
if infoflag >=0; fprintf('checking range ...                                               '); end;
command = sprintf(':SE:M_PAR:R?');
bkoutput = sendto2260BIN(s, command) ;
if infoflag >=0; fprintf('output = %s\n', bkoutput); end;



% the end!
%----------------------