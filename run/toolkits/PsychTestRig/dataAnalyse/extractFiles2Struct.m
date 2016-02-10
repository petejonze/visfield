function [DataSet,pids,sids,bids,nParticipants,nSessions,nBlocks,nTrialsPerBlock]=extractFiles2Struct(fn)
% from EXTRACTDATA2STRUCT
% just for specifically named files

nParticipants = [];

    % constants
    BEGINFILE_IDENTSTRING = '/*****HEADER INFORMATION*****/';
	BEGINDATA_IDENTSTRING = '/*****DATA*****/';    
    
    % create a variable to hold all the data in
    DataSet = struct();
    pids = []; sids = []; bids = [];
    if ischar(fn)
        fn = {fn};
    end
    
    % Extract the data!
    try
        for i=1:length(fn);

            % extract the data & metainfo
            [data,dataStruct,metaDataStruct] = sub_getData(fn{i});
            %
            pid = getPartID(fn{i});
            sid = getSessID(fn{i});
            bid = getBlockID(fn{i});

            % add data to dataset
            DataSet.part(pid).sess(sid).block(bid).fn = fn{i};
            DataSet.part(pid).sess(sid).block(bid).raw.cell = data;
            DataSet.part(pid).sess(sid).block(bid).raw.struct = dataStruct;
            DataSet.part(pid).sess(sid).block(bid).meta = metaDataStruct;
            
            if ~ismember(pid,pids)
                pids(end+1) = pid; %#ok
            end
            if ~ismember(sid,sids)
                sids(end+1) = sid; %#ok
            end
            bids(end+1) = bid; % i; % bid; %#ok / PTR_Block
            
            % calc extra info
            nParticipants = length(pids);
            nSessions = length(sids);
            nBlocks = length(bids);
            nTrialsPerBlock = size(data,1)-1; %-1 for headers
        end
        bids = sort(bids);
    catch ME
        fclose(fid); % fclose('all'); %ensure that any file that happens to be open is closed properly
        rethrow(ME)
    end

    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    function [data,dataStruct,metaDataStruct]=sub_getData(fileName)
        
        % Open the file.  If this returns a -1, we did not open the file 
        % successfully.
        fid = fopen(fileName,'r');
        if fid==-1
          error('extractData:errorOpeningFile',['File not found or permission denied: "' escape(fileName) '"']);
        end

        % Extract the essential meta info
        tline = fgetl(fid);
        if ~ischar(tline)
            error('extractData:failedToExtractMetaInfo:emptyFile','File is empty')
        elseif ~strncmp(tline,BEGINFILE_IDENTSTRING,length(BEGINFILE_IDENTSTRING))
            error('extractData:failedToExtractMetaInfo:firstLineNotProperlyFormed',['No entry of "' BEGINFILE_IDENTSTRING '" detected on first line.'])
        end
        metaDataHeaders = cell(1,6); %crude!
        metaData = cell(1,6);
        noOfMetaFeatures = length(metaDataHeaders);
        for x=1:noOfMetaFeatures
            md = regexp(fgetl(fid),',','split');
            metaDataHeaders{x} = ['PTR_'  regexp(md{1},'\w+','match','once')];
            metaData{x} = md{2};
        end
        metaDataHeaders{x+1} = 'PTR_sourceFile';
        metaData{x+1} = regexprep(regexprep(fileName,'\.csv',''),'-','_');
        typedMetaData = numberfyCell(metaData); % convert all number cols to numbers
        
        % Skip past all the remaining meta info
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
                error('extractData:failedToDetermineHeaderRowNum:noEntry',['No entry of "' BEGINDATA_IDENTSTRING '" detected.']);      
            elseif strncmp(tline,BEGINDATA_IDENTSTRING,length(BEGINDATA_IDENTSTRING))
                break;
            end
        end
            
        % Extract data headers
        dataHeaders = regexp(fgetl(fid),',','split');
        
        % Extract data
        data = fscanf(fid,'%c');
        %data = regexp(data,'\r\n|,','split');
        %data(length(data)) = []; %remove last item (which is blank)
        
        % from csv2struct
        data = regexp(data,'\n|\r\n|,','split');
        if isempty(data{end})
            data(end) = []; %remove last item (which is blank)
        end
    
        noOfFeatures = length(dataHeaders);
        noOfSamples = length(data) / noOfFeatures;

        data=reshape(data,[noOfFeatures,noOfSamples])'; %reshape into (cell) matrix
        typedData = numberfyCell(data); % convert all number cols to numbers
        data = cat(1,dataHeaders,typedData); % rejoin headers and data
        
        
        % Transfer info to a structure
        dataStruct = struct();
        for x=1:length(dataHeaders)
            col = typedData(:,x);
            % convert numeric columns to arrays, leave the rest as cells
            if isnumeric(col{1})
               col = [col{:}];
            else 
                col = col'; % ensure that all columns
            end
            % store column in struct field
            dataStruct.(dataHeaders{x}) = col;
        end

         % Transfer meta info to a structure
        metaDataStruct = struct();
        for x=1:length(metaDataHeaders)
            val = typedMetaData{:,x};
            metaDataStruct.(metaDataHeaders{x}) = val;  % store val in struct field
        end
        
        % prepend metainfo to cell matrix
        typedMetaData = repmat(typedMetaData,noOfSamples,1); %fill down meta data to the approp. num of rows
        metaData = cat(1,metaDataHeaders,typedMetaData); % rejoin headers and data
        cat(2,metaData,data); %prepend
        
        fclose(fid);
    
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
