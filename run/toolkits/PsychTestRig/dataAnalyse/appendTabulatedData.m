function s = appendTabulatedData(s)

    data = {};
    fields = {};

    for pid = 1:length(s.part)
        if isempty(s.part(pid))
            continue;
        end
        for sid = 1:length(s.part(pid).sess)
            if isempty(s.part(pid).sess(sid))
                continue;
            end
            for bid = 1:length(s.part(pid).sess(sid).block)
                if isempty(s.part(pid).sess(sid).block(bid))
                    continue;
                end
                
                % append sess & block info
                h = fieldnames(s.part(pid).sess(sid).block(bid).raw.struct);
                s.part(pid).sess(sid).block(bid).raw.struct.session = ones(size(s.part(pid).sess(sid).block(bid).raw.struct.id)) * sid; % bit hacky!
                s.part(pid).sess(sid).block(bid).raw.struct.block = ones(size(s.part(pid).sess(sid).block(bid).raw.struct.id)) * bid; % bit hacky!
                s.part(pid).sess(sid).block(bid).raw.struct = orderfields(s.part(pid).sess(sid).block(bid).raw.struct, {h{1:4} 'session' 'block' h{5:end}}); % more hacky! reorder so the session variable isn't at the end
                
                % get/check field names
                if isempty(fields)
                    fields = fieldnames(s.part(pid).sess(sid).block(bid).raw.struct);
                end
                
                newfields = fieldnames(s.part(pid).sess(sid).block(bid).raw.struct);
                %if ~all(strcmpi(fields, newfields))
                [comomonfields, fieldsidx, newfieldsidx] = intersect(fields, newfields, 'stable');
                if length(comomonfields) < length(fields)
                    fprintf('Fields\n-----------------\n');
                    fprintf('%s\n', fields{:});
                    fprintf('Fields in part %i, session %i, block %i \n-----------------\n', pid, sid, bid);
                    fprintf('%s\n', newfields{:});
                    warning('non common fields will be ignored')
                    fields = comomonfields;
                    data = data(:,fieldsidx);
                end
                
                % get data
                c = struct2cell(s.part(pid).sess(sid).block(bid).raw.struct);
                c = c(newfieldsidx); % exclude unwanted columns
                idx = cellfun(@isnumeric,c);
                c(idx) = cellfun(@(x)num2cell(x), c(idx), 'UniformOutput', 0);
                c = reshape([c{:}], [], length(fields)); % reshape into matrix
                
                % do best to make everything numeric
                scalar = zeros(size(c));
                for i = 1:size(c,1)
                    for j = 1:size(c,2)
                        if ~isnumeric(c{i,j}) && ~any(c{i,j}==':') % numeric and definitely not a time
                            x = str2num(c{i,j});
                            if ~isempty(x)
                                c{i,j} = x;
                            end
                        end
                        
                            scalar(i,j) = isnumeric(c{i,j}) && (length(c{i,j})==1);
                            
                    end
                end

                % append data to master
                data = [data; c];
            end
        end
    end
    
    % make a master structure
    dataStruct = cell2struct(cell(size(fields)), fields);
    for i = 1:length(fields)
        if all(scalar(:,i))
            dataStruct.(fields{i}) = [data{:,i}]';
        else
            dataStruct.(fields{i}) = data(:,i);
        end
    end
        
    % final tweaks
%     dataStruct.totalTrialN = 1:length(dataStruct.trialN);
    
    % append
    s.all.table = [{fields{:}}; data];
    s.all.struct = dataStruct;
end