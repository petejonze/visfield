function [newDataSet]=splitDataStruct(oldDataSet,criterionFieldName,checkEveryRow)
%SPLITDATASTRUCT short desc.
%
%   Takes a data set and splits it into multiple subsets. This can 
%   therefore be used to redirect different data to different compilations.
%
%   The expected dataset should be structure split by participant ID, and
%   then with a field of name 'fileName' and of contents a cell containing the
%   data contents.
%
%   Currently the split is done by finding the column with the appropriate 
%   header (i.e. == criterionFieldString) and then looking at the first
%   value. This value is then matched to the previously observed values. If
%   it matches the entire cell contents (minus the header) is appended to
%   the data set, if not then the cell is used to form a new set.
%   This is a bit rubbish really. since But it means that you effectively 
%   can't subdivide within a file(/block) (e.g. all A responses to one 
%   dataset, all B responses to another)
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        extractData()
% 
% @Author:          Pete R Jones
%
% @Creation Date:	14/03/10
% @Last Update:     14/03/10
%
% @Todo:            <blank>


    newDataSet = struct();
    prevObserved = cell(0);
    prevObsHeaders = struct();
    criterionFieldID = '';
    %prevObserved = {'hi','my','dpc_level1_run1'}
    
    accessList=flatNestedStructAccessList(oldDataSet);
    
    for i=1:length(accessList)

        subDataSet =getStructVal(oldDataSet, accessList{i}); % data from a single file
        headers = subDataSet(1,:);
        criterionFieldIndex = find(ismember(headers, criterionFieldName)==1);
        
        if checkEveryRow
            nDataRows = size(subDataSet,1);
            for j=2:nDataRows %2.. since we need to skip the headers
                data = subDataSet(j,:); 
            	% add the data to the appropriate part of the new structure
                assignDataToSet(data);    
            end
        else
            %just assume that the top row is indicative of all (useful if
            %splitting between, not within, blocks
            data = subDataSet(2:end,:); %everything excluding header row
            % add the data to the appropriate part of the new structure
            assignDataToSet(data);
        end
  
    end 
    
    
    function assignDataToSet(data)
        criterionFieldVal = data{1,criterionFieldIndex};
        criterionFieldID = [criterionFieldName '_' criterionFieldVal];
        if isNew(criterionFieldID)
            newDataSet.(criterionFieldID) = cat(1,headers,data); % new, so include headers also
        else %compare and strip headers
            % check that headers match
            assertHeadersMatch()
            % add data
            newDataSet.(criterionFieldID) = cat(1,newDataSet.(criterionFieldID),data);
        end
    end
    
    function bool=isNew(criterionFieldID)
        if ~any(strcmp(criterionFieldID,prevObserved)) %if not seen before
            prevObserved = [prevObserved {criterionFieldID}]; %#ok<AGROW>
            prevObsHeaders.(criterionFieldID).data = headers;
            prevObsHeaders.(criterionFieldID).observedIn = accessList{i};
            bool = true;
            return
        end
    	bool = false;
    end

    function assertHeadersMatch()
        areSame = false; %check that header row matches the initial observation of this kind
        try
            if all(strcmpi(prevObsHeaders.(criterionFieldID).data,headers))
                areSame = true;
            end
        catch
        end
        if ~areSame
            error('extractData:local_restructure:headerMismatch',['The column headers for "' accessList{i} '"\nfailed to match those previously observed in "' prevObsHeaders.(criterionFieldID).observedIn '"']);
        end
    end
end