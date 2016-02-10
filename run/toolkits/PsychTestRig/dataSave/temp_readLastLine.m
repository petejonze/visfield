Example 3: Reading only the last line of data using FGETL and FSEEK

NL = 10; 
fid = fopen('sample_file.txt','r'); 
% The loop below uses FSEEK to start at the end of the file and calls 
% FSCANF to read data backwards to check for new line markers. 
status = fseek(fid,0,'eof'); 
i = 0; 
found = 0; 
while 1 
    % If the file is only 1 line with no new line marker, break 
    if fseek(fid,-1,'cof') == -1, break, end 
    c = fscanf(fid,'%c',1); 
    % If a new line marker other than the terminating new 
    % line marker is found, break 
    if c == char(NL) & i ~= 0 , found = 1; break, end 
    i = i + 1; 
    if fseek(fid,-1,'cof') == -1, break, end 
end 
if found | i > 0 
    % Last line is captured with FGETL 
    last_line = fgetl(fid) 
end 



Example 2: Using FPRINTF to write data to the end of the file

% Opening the file to append to the end of it 
fid = fopen('sample_file.txt','a'); 
fprintf(fid,'%s',last_line); 
fclose(fid); 


Example 3: Using FPRINTF to write data to a specific line in the file

% Opening the file to both read and write 
fid = fopen('sample_file.txt','r+'); 
% Can change 'loc' to insert data at any line in file. 
% When loc=2, data will be inserted at line 3 
loc = 2; 
for i = 1:loc 
    %Used FGETL to move file pointer a whole line at a time: 
    %See FGETL section below for more information 
    temp_line = fgetl(fid);
end; 
location = ftell(fid);
fseek(fid,location,'bof');
fprintf(fid,'\n'); 
fseek(fid,-1,'cof'); 

% This call to FPRINTF utilizes the vectorized feature of the 
% MATLAB version: see below for more information 
fprintf(fid,'%s',last_line); 
fprintf(fid,'\n'); 
fclose(fid);  