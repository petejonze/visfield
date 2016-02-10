function null = msetmode2260(s, setupnumber, infoflag)
% function null = msetmode2260(s, setupnumber, infoflag)
%
% -----------------------------------------------------
% set the 2260 to one of the previously-stored setups
% Set for type 2260 meter running software BK-7219 version 1
%-----------------------------------------------------------------
%
% Inputs =
%    s              = serial-port connection made by setup2260
%    setupnumber    = see below
%    infoflag       = 0 (nothing) or 1 (running infomation)
% 
% As of now (4/7/2003) two setup files exists on the 2260 disk:
% #1 = automatic mode with the important parameters being LCeq average on a 1-octave spectrum 
%        on a 20-100 dB range with a 20-second recording time and with a auto-save at end of recording
%        (to a '.S1A' file)
% #2 = same, but manual mode so no averaging is till reset is pressed and saving is *not* done
% #3 = as per #1 (therefore auto) but for a 10-90 dB range  (MAA 11/7/03)
% 
% Assumes serial port is already open: e.g.
% >> s = setup2260('COM3', 4800);
% >> msetmode2260(s, 1, 1)
%
% Used by mmeasurelevelofspeaker1 (which put it into mode #1 for the
% recording then leave it in mode #2 when all finished)
%
%
% MAA Summer 2003 4vii03
% Edited by Pete Jones , 15/07/2010
%---------------------------------


% restore setup ...
if infoflag >=1; fprintf('switching 2260 to setup #%d ... \n', setupnumber); end;
command = sprintf(':SE:R %d', setupnumber);
bkoutput = sendto2260BIN(s, command);


% the end!
%----------------------