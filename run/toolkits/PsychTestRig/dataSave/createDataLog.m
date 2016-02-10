function createDataLog(dataDir,expID)
%CREATEDATALOG description.
%
% desc
%
% Example: none
%
% See also startDataSession writeData finishDataSession

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('dataDir', @ischar);
    p.addRequired('expID', @ischar);
    p.FunctionName = 'OPENDATALOG';
    p.parse(dataDir,expID);
    %----------------------------------------------------------------------

    %check that we are good to go
    if isDataLogPresent(dataDir,expID)
        return; %data log already extant, no need to create
    end

    %create file
  	dataLogFileName=mkfile([dataDir filesep expID '-dataLog.txt']);
    

    %construct header info
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% The - expID - Data Log                                  %%% 
    %%%    n.b. the data log is a ticker tape of all outputs, 	%%%
    %%%    even from sessions that failed or were aborted.     	%%%
    %%%    It is not recommended that you use this data for   	%%%
    %%%    analysis, but rather keep it for your records.      	%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    headerInfo =    {  
                        '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',...
                        [strFillOut(['%%% The - ' expID ' - Data Log'],60,' ') '%%%'],...
                        '%%%    n.b. the data log is a ticker tape of all outputs,   %%%',...
                        '%%%    even from sessions that failed or were aborted.      %%%',...
                        '%%%    It is not recommended that you use this data for     %%%',...
                        '%%%    analysis, but rather keep it for your records.       %%%',...
                        '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',...
                        '',...
                        '',...
                    };

    %write header info
    newline=getNewline();
	fileID = fopen(dataLogFileName,'w+');
	for i=1:size(headerInfo,2)
    	fprintf(fileID, '%s', headerInfo{i});
      	fwrite(fileID, newline, 'char'); % terminate this line
    end
  	fclose(fileID);

	%%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    %<blank>
    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
%<blank>