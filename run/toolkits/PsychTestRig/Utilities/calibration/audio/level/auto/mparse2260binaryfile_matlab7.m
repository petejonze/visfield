function parseddata = mparse2260binaryfile(filename, infoflag);
% function parseddata = mparse2260binaryfile(filename, infoflag);
%
% ---------------------------------------------------
% Goes through the binary data file from a 2260, getting the useful values
% Set for type 2260 meter running software BK-7219 version 1
%-----------------------------------------------------------------
% Designed to get the octave-band Leqs for 1/1 octaves (as its hardwired for 12 bands)
% Works with '.S1A' files as those are what we presently get
%-----------------------------------------------------------------
%
% Inputs =
%    filename = local file to use (e.g. 'U:\michael\matlabtoolbox_rewrite\version2_local\soundlevelmeter\temp2260.bin');
%    infoflag = 0       (nothing) or 
%               1       (running infomation + octave-band summary) or
%               2       (full infomation: report all fields read) or
%               [1:50]  printout all these bytes of the file then stop
%
% Outputs:
%   All the fields found in the datafile in a big structure labelled 'parseddata'
%   Also the binary data itself in the first field 'binarydata';
%
% Unlike all the other code, uses the host computer so does not need the
% serial port to be open.
% >> mparse2260binaryfile('temp2260.bin', 1);     
% >> mparse2260binaryfile('temp2260.bin', 2);     
% >> mparse2260binaryfile('temp2260.bin', [1;50]);  % debug: print bytes 1-50 only
%
% Used by mmeasurelevelofspeaker1, etc
%
% MAA Summer 2003 4vii03
%
% version _matlab7 ...
% PK October 2005 (Line 128: Fixed warning messages with fprintf - Matlab 7.1 fix)
%---------------------------------


ASCII_SPACE    = 32;
ASCII_LINEFEED = 10;
endiantype     = 'ieee-le';
BZ_v1 = true; %version 1 (NCS) slightly differnet to v2 (glasgow). For example, v2 seems to output octave info slightly differently (in 1/1 octave mode 16Hz, 16000Hz and -1 info also outputted)

if infoflag >= 1; fprintf('opening local file ''%s'' as ''%s'' ... \n', filename, endiantype); end
fid = fopen(filename, 'rb', 'ieee-le');

if infoflag >= 1; fprintf('reading data as uint8=>uint8... '); end
[data_uint8, count] = fread(fid, inf, 'uint8=>uint8');
if infoflag >= 1; fprintf(' count = %d\n', count); end
lengthoffile = count;

% add an extra byte at the end so the upcoming +1 checks dont fail
data_uint8 = [data_uint8;0];

if infoflag >= 1; fprintf('converting to double precision ... '); end
data = double(data_uint8);

% store the data
parseddata.filename = filename;
parseddata.binarydata_uint8 = data_uint8;

% debugging ...
if length(infoflag) >= 2
  for bytecounter = infoflag
     fprintf('#%d ... ascii %d => ''%c''\n', bytecounter, data(bytecounter), data(bytecounter));
  end;
  return
end;
%% end of debugging


% main code
if infoflag >= 1; fprintf('finding groups ... \n'); end

% skip the linefeed before the groupname
bytecounter = 1;
bytecounter = bytecounter + 1;
groupcounter = 1;
group(groupcounter).groupnamestartbyte = bytecounter; % (the first letter of the groupname, after spaces and linefeeds, etc);
thisword = [];
while bytecounter <= lengthoffile

    
    % for the main groupname, include all chars as far as the next space
    thisword = [thisword data(bytecounter)];
    bytecounter = bytecounter + 1;
    if data(bytecounter) ~= ASCII_SPACE % space
        continue;
    end;
    % if this far, got full word, so save it and skip the space
    group(groupcounter).groupname = thisword;
    thisword = [];
    while data(bytecounter) == ASCII_SPACE; bytecounter = bytecounter + 1; end; 
    

    % now search for the version number
    successflag = 0;
    while successflag == 0
        thisword = [thisword data(bytecounter)];
        bytecounter = bytecounter + 1;
        if data(bytecounter) ~= ASCII_SPACE % space
           continue;
        end;
        % if this far, got version number so save it and skip the spaces
        group(groupcounter).versionnumber = thisword;
        thisword = [];
        successflag = 1;
        while data(bytecounter) == ASCII_SPACE; bytecounter = bytecounter + 1; end; 
    end;
    
    
    % next get the data count (which is ended by a linefeed)
    successflag = 0;
    while successflag == 0
       thisword = [thisword data(bytecounter)];
       bytecounter = bytecounter + 1;
       if data(bytecounter) ~= ASCII_LINEFEED % linefeed
         continue;
       end;
       % if this far, got data count
       group(groupcounter).datacount = thisword;
       thisword = [];
       successflag = 1;
       while data(bytecounter) == ASCII_SPACE; bytecounter = bytecounter + 1; end; 
    end;
 
    %if infoflag >= 2; fprintf('Group = %20s ... Version = %2s ... Datacount = %5s  ', group(groupcounter).groupname, group(groupcounter).versionnumber, group(groupcounter).datacount); end
    
    %PK - fprintf warning messages fix for Matlab 7.1
    if infoflag >= 2; fprintf('Group = %20s ... Version = %2s ... Datacount = %5s  ', char(group(groupcounter).groupname), char(group(groupcounter).versionnumber), char(group(groupcounter).datacount)); end
    %PK - end
    
    % skip the linefeed, the { and the linefeed
    bytecounter = bytecounter + 1;
    bytecounter = bytecounter + 1;
    bytecounter = bytecounter + 1;
    
    
    % skip the number of databytes
    group(groupcounter).datastartbyte = bytecounter;      % (the first byte of the actual data, after spaces and linefeeds, etc);
    for n=1:str2num(char(group(groupcounter).datacount));
        bytecounter = bytecounter + 1;
    end;
    
    
    % skip the linefeed, the } and the linefeed at the end of this group
    bytecounter = bytecounter + 1;
    bytecounter = bytecounter + 1;
    bytecounter = bytecounter + 1;
    
    if infoflag >= 2; fprintf('(groupname starts @ #%4d ... data starts @ #%4d)', group(groupcounter).groupnamestartbyte, group(groupcounter).datastartbyte); end

    
    % carry on looking for the next word ...
    groupcounter = groupcounter + 1;
    
    
    % skip the linefeed before the next groupname
    bytecounter = bytecounter + 1;
    group(groupcounter).groupnamestartbyte = bytecounter; % (the first letter of the groupname);
    if infoflag >= 2; fprintf('\n'); end
end;
ngroups = groupcounter - 1;
% if this far, got to the end of the file ok

if infoflag >= 1; fprintf('done ... found %d groups ... final bytecounter = %d\n', ngroups, bytecounter); end



% now, start parsing the groups ...
fseekoffset = -1; % because it seems to work ...

if infoflag >= 1; fprintf('parsing groups ... \n'); end
for g=1:ngroups
    thisgroup = group(g);
    if infoflag >= 2; fprintf('#%d = ''%s'' ... ', g, char(thisgroup.groupname)); end


    switch (char(thisgroup.groupname));
        case 'CCalibrationSetup'
        if infoflag >= 2; fprintf(' ... \n'); end
        bytecounter = thisgroup.datastartbyte; fseek(fid,bytecounter + fseekoffset, 'bof');
        parseddata.null = fread(fid, 1, 'int32'); % D/A offset
        parseddata.null = fread(fid, 1, 'int32'); % D/A offset
        parseddata.null = fread(fid, 1, 'int32'); % D/A gain
        parseddata.null = fread(fid, 1, 'int32'); % D/A gain
        parseddata.null = fread(fid, 1, 'int32'); % A/D calib
        parseddata.null = fread(fid, 1, 'int32'); % A/D calib
        parseddata.dbpervolt_db100 = fread(fid, 1, 'int16');
        if infoflag >= 2; fprintf('      db per volt               = %.2f dB\n', parseddata.dbpervolt_db100/100);end
        for n=1:9;
            parseddata.null = fread(fid, 1, 'int16');  % anti C correction
        end
        parseddata.calibrationlevel_db100 = fread(fid, 1, 'int16');
        parseddata.micsensitivity_db100 = fread(fid, 1, 'int16');
        parseddata.currentsensitivity_db100 = fread(fid, 1, 'int16');
        parseddata.currentcalibrationdate_time = fread(fid, 1, 'int32');
        parseddata.currentcalibrationlevel_db100 = fread(fid, 1, 'int16');
        parseddata.micspecifiedsensitivity_db100 = fread(fid, 1, 'int16');
        parseddata.micspecifieddate_time = fread(fid, 1, 'int32');
        parseddata.miccalibrationlevel_db100 = fread(fid, 1, 'int16');
        parseddata.zf0023_enum = fread(fid, 1, 'int16');
        if infoflag >= 2; fprintf('      calibrationlevel          = %.2f dB\n', parseddata.calibrationlevel_db100/100);end
        if infoflag >= 2; fprintf('      micsensitivity            = %.2f dB \n', parseddata.micsensitivity_db100/100);end
        if infoflag >= 2; fprintf('      currentsensitivity        = %.2f dB \n', parseddata.currentsensitivity_db100/100);end
        if infoflag >= 2; fprintf('      currentcalibrationdate    = %d      \n', parseddata.currentcalibrationdate_time);end
        if infoflag >= 2; fprintf('      currentcalibrationlevel   = %.2f dB \n', parseddata.currentcalibrationlevel_db100/100);end
        if infoflag >= 2; fprintf('      micspecifiedsens          = %.2f dB \n', parseddata.micspecifiedsensitivity_db100/100);end
        if infoflag >= 2; fprintf('      micspecifiedtime          = %d      \n', parseddata.micspecifieddate_time);end
        if infoflag >= 2; fprintf('      miccalibration            = %.2f dB\n', parseddata.miccalibrationlevel_db100/100);end
        if infoflag >= 2; fprintf('      zf0023                    = %d     \n', parseddata.zf0023_enum);end

        
        case 'CInitialCalibration'
        if infoflag >= 2; fprintf(' ... \n'); end
        bytecounter = thisgroup.datastartbyte; fseek(fid,bytecounter + fseekoffset, 'bof');
        % get the serial number, sensitivity and calibration date
        parseddata.micserialnumber = fread(fid, 1, 'int32');
        parseddata.micsensitivity = fread(fid, 1, 'int16');
        parseddata.miccalibrationdate = fread(fid, 1, 'int32');
        if infoflag >= 2; fprintf('      mic serial number    = #%d\n', parseddata.micserialnumber); end
        if infoflag >= 2; fprintf('      mic sensitivity      = #%.1f dB\n', parseddata.micsensitivity/100);end
        if infoflag >= 2; fprintf('      mic calibration date = #%d seconds since 1/1/1970\n', parseddata.miccalibrationdate);end
        
        
        case 'C2260SerialNo'
        if infoflag >= 2; fprintf(' ... \n'); end
        bytecounter = thisgroup.datastartbyte; fseek(fid,bytecounter + fseekoffset, 'bof');
        % get the serial number, sensitivity and calibration date
        parseddata.serialnumber2260 = fread(fid, 1, 'int32');
        if infoflag >= 2; fprintf('      2260 serial number    = #%d\n', parseddata.serialnumber2260); end
        
        
        case 'CMeasPar'
        if infoflag >= 2; fprintf(' ... \n'); end
        bytecounter = thisgroup.datastartbyte; fseek(fid,bytecounter + fseekoffset, 'bof');
        parseddata.range_enum = fread(fid, 1, 'int16');
        if parseddata.range_enum == 0; if infoflag >= 2; fprintf('      range = %d = -10 to 70 dB\n', parseddata.range_enum); end; end
        if parseddata.range_enum == 1; if infoflag >= 2; fprintf('      range = %d =   0 to 80 dB\n', parseddata.range_enum); end; end
        if parseddata.range_enum == 2; if infoflag >= 2; fprintf('      range = %d =  10 to 90 dB\n', parseddata.range_enum); end; end
        if parseddata.range_enum == 3; if infoflag >= 2; fprintf('      range = %d =  20 to 100 dB\n', parseddata.range_enum); end; end
        if parseddata.range_enum == 4; if infoflag >= 2; fprintf('      range = %d =  30 to 110 dB\n', parseddata.range_enum); end; end
        if parseddata.range_enum == 5; if infoflag >= 2; fprintf('      range = %d =  40 to 120 dB\n', parseddata.range_enum); end; end
        if parseddata.range_enum == 6; if infoflag >= 2; fprintf('      range = %d =  50 to 130 dB\n', parseddata.range_enum); end; end
        
        
        case 'CGPSData'
        if infoflag >= 2; fprintf(' (nothing to do yet)\n'); end
        
        
        case 'COneSecAuxValues'
        if infoflag >= 2; fprintf(' ... \n'); end
        bytecounter = thisgroup.datastartbyte; fseek(fid,bytecounter + fseekoffset, 'bof');
        parseddata.null = fread(fid, 1, 'int32'); % noofoverloadupdates
        parseddata.null = fread(fid, 1, 'double'); % overload%
        parseddata.null = fread(fid, 1, 'int32'); % noofunderangeupdates
        parseddata.null = fread(fid, 1, 'double'); % underrange%
        parseddata.null = fread(fid, 1, 'int32'); % noofpauses
        parseddata.measno = fread(fid, 1, 'int32'); 
        parseddata.elapsedtime = fread(fid, 1, 'int32'); 
        parseddata.starttime = fread(fid, 1, 'int32'); 
        if infoflag >= 2; fprintf('      measno      = %d \n', parseddata.measno); end
        if infoflag >= 2; fprintf('      elapsedtime = %d \n', parseddata.elapsedtime); end
        if infoflag >= 2; fprintf('      starttime   = %d \n', parseddata.starttime); end
        
        
        case 'CBroadParam'
        if infoflag >= 2; fprintf(' (nothing to do yet)\n'); end
        
        
        case 'CBroadStat'
        if infoflag >= 2; fprintf(' (nothing to do yet)\n'); end
        
        
        case 'COctaveParam'
        if infoflag >= 2; fprintf(' ... \n'); end
        bytecounter = thisgroup.datastartbyte; fseek(fid,bytecounter + fseekoffset, 'bof');
        parseddata.octave_bandwidth_enum = fread(fid, 1, 'int16');
        if parseddata.octave_bandwidth_enum == 0; if infoflag >= 2; fprintf('      octavebandwith = 1/1\n'); end; end
        if parseddata.octave_bandwidth_enum == 1; if infoflag >= 2; fprintf('      octavebandwith = 1/3\n'); end; end
        parseddata.null = fread(fid, 1, 'int16');
        parseddata.null = fread(fid, 1, 'int16');
        
        if parseddata.octave_bandwidth_enum == 0 && BZ_v1; octave_freq_hz = [32 63 125 250 500 1000 2000 4000 8000];
        elseif parseddata.octave_bandwidth_enum == 1 && BZ_v1; octave_freq_hz = [16 20 25 32 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500];
        elseif parseddata.octave_bandwidth_enum == 0 && ~BZ_v1; octave_freq_hz = [16 32 63 125 250 500 1000 2000 4000 8000 16000 -1];
        elseif parseddata.octave_bandwidth_enum == 1 && ~BZ_v1; noctavebands = []; end %don't know!
        
        noctavebands = length(octave_freq_hz);
        
        if infoflag >= 2; fprintf('      (guessing %d bands ...) \n', noctavebands); end
        for n=1:noctavebands
           temp.octave_nlequpdates(n) = fread(fid, 1, 'int32')
           temp.octave_leq_dose(n) = fread(fid, 1, 'double');
           temp.octave_lmin_db100corr(n) = fread(fid, 1, 'int16');
           temp.octave_lmax_db100corr(n) = fread(fid, 1, 'int16');
           if BZ_v1
            parseddata.octave_freq_hz(n) = octave_freq_hz(n); parseddata.octave_nlequpdates(n) = temp.octave_nlequpdates(n); parseddata.octave_leq_dose(n) = temp.octave_leq_dose(n); parseddata.octave_lmin_db100corr(n) = temp.octave_lmin_db100corr(n); parseddata.octave_lmax_db100corr(n) = temp.octave_lmax_db100corr(n); 
           end
        end;
        
        % PETE: as far as I can determine our older SLM (v1.0, not v2.0)
        % does not have 16Hz, 16000Hz, it seems logical to assume that
        % n2=10,11,12 are all new additions. Since we don't have them there
        % is no need to re-order! So the following logic moved into the for
        % loop above
        if ~BZ_v1
            % reset the orderings ... seems necessary, as for somereason band #1 appears at position 10 ...
            % set for a 1/1 octave band
            n1=1;  n2 = 10; parseddata.octave_freq_hz(n1) = 16; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=2;  n2 = 1;  parseddata.octave_freq_hz(n1) = 32; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=3;  n2 = 2;  parseddata.octave_freq_hz(n1) = 63; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=4;  n2 = 3;  parseddata.octave_freq_hz(n1) = 125; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=5;  n2 = 4;  parseddata.octave_freq_hz(n1) = 250; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=6;  n2 = 5;  parseddata.octave_freq_hz(n1) = 500; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=7;  n2 = 6;  parseddata.octave_freq_hz(n1) = 1000; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=8;  n2 = 7;  parseddata.octave_freq_hz(n1) = 2000; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=9;  n2 = 8;  parseddata.octave_freq_hz(n1) = 4000; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=10; n2 = 9;  parseddata.octave_freq_hz(n1) = 8000; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=11; n2 = 11; parseddata.octave_freq_hz(n1) = 16000; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
            n1=12; n2 = 12; parseddata.octave_freq_hz(n1) = -1; parseddata.octave_nlequpdates(n1) = temp.octave_nlequpdates(n2); parseddata.octave_leq_dose(n1) = temp.octave_leq_dose(n2); parseddata.octave_lmin_db100corr(n1) = temp.octave_lmin_db100corr(n2); parseddata.octave_lmax_db100corr(n1) = temp.octave_lmax_db100corr(n2); 
        end
        % get FullScaleCorrection
        % = "FullScaleCorrection = Range * 1000 + 3398 - dBPerVolt - CurrentSensitivity
        %    Range if from CMeasPar (BZ7201-02-06-10-19),
        %    dBPerVolt and CurrentSensitivity are from CCalibrationSetup,
        %    3398 = 7000-1301-2602+301
        % (from 2260dataset.xls : types)
        parseddata.fullscalecorrection = parseddata.range_enum*1000 + 3398 - parseddata.dbpervolt_db100 - parseddata.currentsensitivity_db100;
        if infoflag >= 2; fprintf('      fullscalecorrection = %.1f\n', parseddata.fullscalecorrection); end; 
        % convert dose to dB
        % = "convert to dB = FullScaleCorrection / 100 + 10 * LOG10(Dose / NoOfUpdates)
        for n=1:noctavebands
            parseddata.octave_db(n) = parseddata.fullscalecorrection/100 + 10*log10(parseddata.octave_leq_dose(n)/parseddata.octave_nlequpdates(n) + 1e-99);
        end;
        % convert Lmin and LMax to dB
        for n=1:noctavebands
            parseddata.octave_lmin_db(n) = (parseddata.octave_lmin_db100corr(n) + parseddata.fullscalecorrection)/100;;
            parseddata.octave_lmax_db(n) = (parseddata.octave_lmax_db100corr(n) + parseddata.fullscalecorrection)/100;;
        end;
        % print
        for n=1:noctavebands
           if infoflag >= 2; fprintf('      #%2d = %5.0f Hz ... level %7.2f dB  (updates=%d  dose=%.10f  min-max = %5.1f - %5.1f db)\n', n, parseddata.octave_freq_hz(n), parseddata.octave_db(n), parseddata.octave_nlequpdates(n), parseddata.octave_leq_dose(n), parseddata.octave_lmin_db(n), parseddata.octave_lmax_db(n)); end; 
        end;
        parseddata.octave_1khzlevel_db = parseddata.octave_db(find(octave_freq_hz==1000));
        parseddata.octave_1khzmin_db = parseddata.octave_lmin_db(find(octave_freq_hz==1000));
        parseddata.octave_1khzmax_db = parseddata.octave_lmax_db(find(octave_freq_hz==1000));
        
        
        case 'COctaveStat'
        if infoflag >= 2; fprintf(' (nothing to do yet)\n'); end

        
        case 'CEOB'
        if infoflag >= 2; fprintf(' (nothing to do yet)\n'); end
        
        
        otherwise
        if infoflag >= 2; fprintf(' unknown group name! \n'); end

    end;
    
end;


if infoflag >= 1; fprintf('closing file ... \n'); end
fclose(fid);
if infoflag >= 2; fprintf('\n'); end
if infoflag >= 1; fprintf('B&K time = %d secs since 1/1/1970\b',  parseddata.starttime); end
if infoflag >= 2; fprintf('\n'); end


% report octaveband data
if infoflag >= 1; fprintf('Octave-band data: \n'); end; 
for n=1:noctavebands
   if infoflag >= 1; fprintf(' #%2d = %5.0f Hz ... level %7.2f dB  (n updates=%d  min-max range = %5.1f - %5.1f db)\n', n, parseddata.octave_freq_hz(n), parseddata.octave_db(n), parseddata.octave_nlequpdates(n), parseddata.octave_lmin_db(n), parseddata.octave_lmax_db(n)); end; 
   end;
if infoflag >= 1; fprintf('\n'); end


% the end!
%----------------------