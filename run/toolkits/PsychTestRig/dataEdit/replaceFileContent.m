function replaceFileContent(fn,oldContent,newContent)   
%REPLACEFILECONTENT short desc.
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

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('fn', @(x)exist(x,'file') > 0);
    p.addRequired('fullContent');
    p.addRequired('data');
    p.FunctionName = 'REPLACEFILECONTENT';
    p.parse(fn,oldContent,newContent);
    %----------------------------------------------------------------------
    
    % Open the file.  If this returns a -1, we did not open the file successfully.
    fid = fopen(fn,'r');
    if fid==-1
      error('setFileContent:errorOpeningFile',['File not found or permission denied (for reading): "' fn '"']);
    end

    % Check that good to go
    fseek(fid,0,'bof');                 %starting at the beginning of the file..
    fc = fscanf(fid,'%c');              % Read in the rest of the file in readable text format
    if sum(fc)~=sum(oldContent)        
        error('setFileContent:contentMismatch','Specified file content and found content do not match')
    end
    fclose(fid);

    % clear file(!)
    fid=fopen(fn,'w'); 
  	if fid==-1
      error('setFileContent:errorOpeningFile',['File not found or permission denied (for editing): "' escape(fn) '"']);
    end
    
    % Print out new data
    fwrite(fid,newContent);
    
    % release the file
    fclose(fid);

end