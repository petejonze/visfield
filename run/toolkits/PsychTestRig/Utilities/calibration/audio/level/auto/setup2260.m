function  SO=setup2260(COMPORT, BRATE)
% function  SO=setup2260(COMPORT, BRATE)
%
% --------------------------------------------
% Opens a serial-port link to the soundlevel meter
% Set for type 2260 meter
% ----------------------------------------------
%
%
% setup2260(), Initialises the Serial Object(SO) with the right settings for the observer2260.
% setup2260(), Creates a Serial Object(SO) on COMPORT(or com1 if empty), and then sets the Baudrate(115200), Parity(none), DataBits(8), and StopBits(1). It
% returns an open Serial Object(file handle to a serial object), and a status code of 1 if the serial object status is open(ie ready).
%
% example:
% >> s = setup2260('COM3', 4800);
%
% MAA: Used by mmeasurelevelofspeaker1, etc
% Sometimes this will fail, mainly if MATLAB thinks the COM port is claimed
% by something else. If so, close the port, delete it, then try again
% >> fclose(s); delete(s); s = setup2260('COM3', 4800);
% If that fails --- probably because 's' has been deleted --- then we don't
% know of anyway to get matlab to get the port back. Kill matlab and
% restart ...
%
%
% Written by S. Maver, v 1.0, 06/05/2003
% S. Maver added COM port checking , v 1.1, 06/05/2003
% MAA Added the COMPORT as the option       27/06/2003
% MAA Added the BRATE as the option       27/06/2003
%
% version _matlab7 ...
% PK October 2005 (Lines 48-49: Added input buffer size parameter for the serial port - Matlab 7.1 fix)
% Edited by Pete Jones , 15/07/2010
% --------------------------------------------------------------


%Define the constants
% COMPORT='COM2';  % MAA 27/06/2003 ... now a command-line parameter
% BRATE   = 2400;   % MAA 27/06/2003 ... now a command-line parameter
DBITS   = 8;
SBITS   = 1;
PRTY    = 'none';
TIMEOUT = 1;
TIMEOUT = 2; % MAA 30/6/2003 ... see if it helps ...
BUFFER = 2000;

% % pete... [for when we load our big directory full of old files]
% TIMEOUT = 20;
% BUFFER = 10000;

%SO = serial(COM,'Baudrate',115200,'Parity','none','Databits',8,'StopBits',1);
%Use the constants
%SO = serial(COMPORT,'BaudRate',BRATE,'Parity',PRTY,'Databits',DBITS,'StopBits',SBITS,'Timeout',TIMEOUT,'InputBufferSize',BUFFER);

%PK - Serial port input buffer fix

fprintf('opening serial port ... \n');
fprintf('port=%s  baudrate=%d  dbits=%d  sbits=%d  parity=%s  timeout=%d  buffer=%d\n', COMPORT, BRATE, DBITS, SBITS, PRTY, TIMEOUT, BUFFER);
SO = serial(COMPORT,'BaudRate',BRATE,'Parity',PRTY,'Databits',DBITS,'StopBits',SBITS,'Timeout',TIMEOUT,'InputBufferSize',BUFFER);
%PK - end
fopen(SO);
fprintf('open!\n');

% Now the serial object is set up with the 2260 details and should be
% ready to be used. So let's send 6 control-c's to the 2260 and put it in
% remote mode.


disp(SO)
CNTRLC=char(03);


for I = 1:6
    fprintf(SO,'%c',CNTRLC);
    echo = char(fread(SO,1));
%     % pete debug
%     fprintf('sent == %i',CNTRLC);
%     fprintf('   ....     received == %i\n',echo);
    if echo ~= CNTRLC
        warning off backtrace; %dosent display the line number of the warning trigger
        warning('Couldnt set SLM in remote mode.');
    end %if
end %for

% We should wait 6 seconds before sending any commands
%T=timer('ExecutionMode','singleShot','Period',6,'TimerFcn','@status2260');   % Set up a 6 second timer
%start(T);                                           % Start it off
%wait(T);                                            % Wait until it is done(ie 6 seconds have passed)

% Read the LF from the 2260 output
%if char(10) ~= fread(SO,1)
%    warning off backtrace; %dosent display the line number of the warning trigger
%    warning('Couldnt set SLM in remote mode, problem echoing LineFeed.');
%end %if



% the end
%--------------------------------------------