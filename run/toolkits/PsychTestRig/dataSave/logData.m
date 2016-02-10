function logData(eventStr,varargin)
%LOGDATA description.
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
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	10/02/10
% @Last Update:     02/04/10
%
% @Todo:            <blank>


    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('eventStr', @(x)any(strcmpi(x,{   'DataSaved','NoteMade','DataFileStarted','DataFileEnded',...
                                                    'DataFileDestroyed','DataFileAborted','FatalError','dataLogOpened','dataLogClosed',...
                                                    'preparingEdit','editContent','editOccured','editAborted',...
                                                    'preparingMetaEdit','editMetaContent','metaEditOccured'})));
    p.addOptional('dataStr', '', @ischar);
    p.FunctionName = 'LOGDATA';
    p.parse(eventStr,varargin{:});
    %----------------------------------------------------------------------
    dataStr = p.Results.dataStr;
    %----------------------------------------------------------------------
    global DATALOG_FILE_ID;
    %----------------------------------------------------------------------
    
    %check that we are good to go
    if isempty(DATALOG_FILE_ID)
        error('no data log active. openDataLog must be called before logData will work!')
    end
    
    %initialise local variables
    fileID=DATALOG_FILE_ID;
    timestamp = datestr(now,30); %determine the time
 	preamble = ['[' timestamp '] ' strFillOut(eventStr,20,' ')];
    
    switch eventStr
        case {'DataSaved'}
            outputDataStr = [preamble '= ' dataStr];
      	case {'NoteMade'}
            outputDataStr = [preamble ': ' dataStr];
      	case 'DataFileStarted'
            outputDataStr = [preamble '(' dataStr ')'];
        case 'FatalError'
            outputDataStr = [preamble '!!!' dataStr];            
      	case 'DataFileEnded'
            outputDataStr = [preamble '----------------------------------------------------------'];
     	case 'DataFileDestroyed'
            outputDataStr = [preamble '----------------------------------------------------------'];
       	case 'DataFileAborted'
            outputDataStr = [preamble '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'];
        case 'dataLogOpened'
        	outputDataStr = [preamble '###LOG OPENED###'];
        case 'dataLogClosed'
            outputDataStr = [preamble '###LOG CLOSED###' getNewline() getNewline()];
    	case 'preparingEdit'
            outputDataStr = [preamble 'PREPARING TO EDIT: ' dataStr];           
    	case 'editContent'
            outputDataStr = [preamble dataStr];      
     	case 'editOccured'
            outputDataStr = [preamble '<><><><><><><><><><><><><><><><><><><><><><><><><><><><><>'];  
        case 'editAborted'
            outputDataStr = [preamble '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'];         
    	case 'preparingMetaEdit'
            outputDataStr = [preamble 'PREPARING TO EDIT: ' dataStr];           
    	case 'editMetaContent'
            outputDataStr = [preamble dataStr];      
     	case 'metaEditOccured'
            outputDataStr = [preamble '<><><><><><><><><><><><><><><><><><><><><><><><><><><><><>'];               
       	otherwise
            error('PsychTestRig:logData',['Unknown method: "' eventStr '"'])
    end
        
    %output data
    fprintf(fileID, '%s', outputDataStr);
    fwrite(fileID, getNewline(), 'char'); % terminate this line
             
	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>