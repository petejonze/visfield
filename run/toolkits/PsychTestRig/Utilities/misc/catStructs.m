function concatStruct=catStructs(inputStructs)
%CATSTRUCTS shortdescr.
%
% Description
%
% Example: catStructs({d1,d2})
%
% See also mergeStructs, getStructVal, setStructVal
% 
% @Author: Pete R Jones
% @Date: 07/04/10

% only works for flat structs!
% only works if all entries the same length (i.e. if read using csv2struct)

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('inputFiles', @iscell);
    p.FunctionName = 'CATSTRUCTS';
    p.parse(inputStructs);
    %----------------------------------------------------------------------

    
    % Check good to go
    
    % Initialise local variables
    nStructs = length(inputStructs);
    
    % Get headers
    masterHeaderSet = {};
    for i=1:nStructs
        myStruct = inputStructs{i};
        headers = fieldnames(myStruct);
        masterHeaderSet = {masterHeaderSet{:}, headers{:}}; 
    end
    masterHeaderSet = unique(masterHeaderSet); %prune out repeat values
    nHeaders = length(masterHeaderSet);
    
    % Initialise master data set
    masterDataSet = struct;
    for i=1:nHeaders
        masterDataSet.(masterHeaderSet{i}) = {};
    end
    
    
    % Merge
    for s=1:nStructs
        myStruct = inputStructs{s};
        
        % find some example element to determine length
        tmpNames = fieldnames(myStruct);
        tmpExemplar = myStruct.(tmpNames{1});
        nElements = length(tmpExemplar);
        
        for h=1:nHeaders
            myHeader = masterHeaderSet{h};
            
            % if output header is a valid header for this structure then
            % grab the values
            if isfield(myStruct,myHeader)
                values = myStruct.(myHeader);
                if isnumeric(values)
                    values = num2cellstr(values);
                elseif ~iscellstr(values) %else if is a cell, but not every entry is a string
                   for i=1:nElements
                       if ~ischar(values{i})
                           values(i) = any2str(values{i});
                       end
                   end
                end
            else % else make some blank values
                values = cell(1,nElements);
                values(:) = {''};
            end
            
            %append values into master data set
            currentData = masterDataSet.(myHeader);
            masterDataSet.(myHeader) = {currentData{:} values{:}};  
        end
    end
    
    concatStruct = masterDataSet;
      


end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
