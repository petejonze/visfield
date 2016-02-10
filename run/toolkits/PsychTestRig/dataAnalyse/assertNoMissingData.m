function assertNoMissingData(data, participants, expectedNSessions, expectedNBlocks, expectedNTrials)
%CHECKFORMISSINGDATA short desc.
%
% Description.
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank> 
%
% @See also:        checkForMissingData
% 
% @Author:          Pete R Jones
%
% @Creation Date:	23/05/13
% @Last Update:     23/05/13
%
% @Todo:            <none>

    % parse inputs
    if nargin < 2 || isempty(participants)
        participants = 1:length(data.part);
    end
    if nargin < 3
        expectedNSessions = [];
    end
    if nargin < 4
        expectedNBlocks = [];
    end
    if nargin < 5
        expectedNTrials = [];
    end
    
    % expand inputs if necessary
    if ~isempty(expectedNSessions) && length(expectedNSessions)==1
        expectedNSessions = repmat(expectedNSessions,1,2); % same for min and max
    end
    if ~isempty(expectedNBlocks) && length(expectedNBlocks)==1
        expectedNBlocks = repmat(expectedNBlocks,1,2); % same for min and max
    end
    if ~isempty(expectedNTrials) && length(expectedNTrials)==1
        expectedNTrials = repmat(expectedNTrials,1,2); % same for min and max
    end
    
    
    
  	% init
    ok = true;
    fprintf('Checking for missing data...\n');
    
    % Check all PARTICIPANTS present
    % print header
    fprintf('   Checking participants...\n');
    for pid=participants
        % evaluate
        status = 'ok'; % assume ok unless found otherwise
        try
            if length(data.part) < pid || isempty(data.part(pid))
                status = 'FAILED (not found)';
            end
        catch %#ok
            status = 'FAILED (error?)';
        end
        if ~strcmpi(status,'ok')
            ok = false;
        end
        
        % report
        fprintf('      pid %i.. %s\n', pid, status);
    end
    
    % Check all SESSIONS present
    if ~isempty(expectedNSessions)
        % print header
        fprintf('   Checking nSessions (%i < x < %i)...\n', expectedNSessions);
        % run
        for pid=participants
            % evaluate
            status = 'ok'; % assume ok unless found otherwise
            try
                N = length(data.part(pid).sess);
                if N < expectedNSessions(1)
                    status = sprintf('FAILED (too few: %i)',N);
                elseif N > expectedNSessions(2)
                    status = sprintf('FAILED (too many: %i)',N);
                end
            catch %#ok
                status = 'FAILED (error?)';
            end
            if ~strcmpi(status,'ok')
                ok = false;
            end
            % report
            fprintf('      pid %i.. %s\n', pid, status);
        end
    end
    
    % Check all BLOCKS present
    if ~isempty(expectedNBlocks)
        % print header
        fprintf('   Checking nBlocks (%i < x < %i)...\n', expectedNBlocks);
        % run
        for pid=participants
            for sid=1:length(data.part(pid).sess)
                % evaluate
                status = 'ok'; % assume ok unless found otherwise
                try
                    N = length(data.part(pid).sess(sid).block);
                    if N < expectedNBlocks(1)
                        status = sprintf('FAILED (too few: %i)',N);
                    elseif N > expectedNBlocks(2)
                        status = sprintf('FAILED (too many: %i)',N);
                    end
                catch %#ok
                    status = 'FAILED (error?)';
                end
                if ~strcmpi(status,'ok')
                    ok = false;
                end
                % report
                fprintf('      pid %i, session %i.. %s\n', pid, sid, status);
            end
        end
    end
    
    % Check all TRIALS present
    if ~isempty(expectedNTrials)
        % print header
        fprintf('   Checking nTrials (%i < x < %i)...\n', expectedNTrials);
        % run
        for pid=participants
            for sid=1:length(data.part(pid).sess)
                for bid=1:length(data.part(pid).sess(sid).block)
                % evaluate
                status = 'ok'; % assume ok unless found otherwise
                try
                    N = length(data.part(pid).sess(sid).block(bid).raw.struct.id); % use id as arbitrary parameter (should be automatically saved in every data file)
                    if N < expectedNTrials(1)
                        status = sprintf('FAILED (too few: %i)',N);
                    elseif N > expectedNTrials(2)
                        status = sprintf('FAILED (too many: %i)',N);
                    end
                catch %#ok
                    status = 'FAILED (error?)';
                end
                if ~strcmpi(status,'ok')
                    ok = false;
                end
                % report
                fprintf('      pid %i, session %i, block %i.. %s\n', pid, sid, bid, status);
                end
            end
        end
    end
    
    % throw error if anything failed along the way (if not all OK)
    if ~ok
        error('Missing data detected. See above for breakdown.');
    else
        fprintf('...Done!\n\n');
    end

end
