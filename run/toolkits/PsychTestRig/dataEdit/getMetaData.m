function val=getMetaData(fn,seekField)
%GETMETADATA short desc.
%
% Extract meta data value for a specified field
% was written much later, and in a quite different way to editMetaData
% n.b. expects a full file name (i.e. with absolute path)
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        editMetaData
% 
% @Author:          Pete R Jones
%
% @Creation Date:	01/04/10
% @Last Update:     01/04/10
%
% @Todo:            <blank>

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('fn', @(x)exist(x,'file')>0);
    p.addRequired('seekField', @ischar);
    p.FunctionName = 'GETMETADATA';
    p.parse(fn,seekField);
    %----------------------------------------------------------------------

    % get value
%     try
        % retrieve the file contents;
        fullContent=getFileContent(fn);

        % look for value
        pattern = ['(?<=' seekField ':,)[a-zA-Z0-9]+'];
        val = regexp(fullContent, pattern, 'Match','Once');
        
        % check whether something was found, warn if not
        if strcmp(val,'')
            warning('getMetaData:fieldNotFound',['The specified field: "' seekField '" was not found in: ' escape(fn)])
        end
%     catch ME
% stupid:        
%         fclose('all');
%         rethrow(ME);
%     end
% 
%     fclose('all');
    
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>
    