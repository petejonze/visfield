function setFileContent(fn,fullContent,data)   
%SETFILECONTENTS short desc.
%
% Description.
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        editData, editMetaData, extractData
% 
% @Author:          Pete R Jones
%
% @Creation Date:	02/04/10
% @Last Update:     02/04/10
%
% @Todo:            <blank>


    % constants
    BEGINFILE_IDENTSTRING = '/*****HEADER INFORMATION*****/';
	BEGINDATA_IDENTSTRING = '/*****DATA*****/';   
    
    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('fn', @(x)exist(x,'file') > 0);
    p.addRequired('fullContent');
    p.addRequired('data');
    p.FunctionName = 'SETFILECONTENTS';
    p.parse(fn,fullContent,data);
    %----------------------------------------------------------------------
    
    % initialise local variables
    nDataRows = size(data,1);
    nLineChar = getNewline();
    
    % Open the file.  If this returns a -1, we did not open the file successfully.
    fid = fopen(fn,'r');
    if fid==-1
      error('setFileContent:errorOpeningFile',['File not found or permission denied (for reading): "' fn '"']);
    end

    % Check that good to go
    fseek(fid,0,'bof');                 %starting at the beginning of the file..
    fc = fscanf(fid,'%c');              % Read in the rest of the file in readable text format
    if sum(fc)~=sum(fullContent)        
        error('setFileContent:contentMismatch','Specified file content and found content do not match')
    end
    fclose(fid);

    % clear file(!)
    fid=fopen(fn,'w'); 
  	if fid==-1
      error('setFileContent:errorOpeningFile',['File not found or permission denied (for editing): "' escape(fn) '"']);
    end
    
    % Print out meta data, etc.
    preText = regexp(fullContent,['.+' BEGINDATA_IDENTSTRING],'match','Once');
    fwrite(fid,preText);
    fwrite(fid, nLineChar, 'char'); % terminate this line
    
    % Print out newly edited data
    for i=1:nDataRows
        outputDataStr = strjoin(',', data{i,:});
        fprintf(fid, '%s', outputDataStr);
        fwrite(fid, nLineChar, 'char'); % terminate this line
    end
    
    % release the file
    fclose(fid);

end