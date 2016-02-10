function [fn,files] = getBlockFns(expID, pid, sid, bid, lastN, fullPath)
%GETBLOCKFNS return most recent block data files
%
%   longdescr
%
% @Requires the following toolkits:
%               PsychTestRig v0.5
%   
% @Parameters:  
%
%    	[lastN]       	Integer.  	Defaults to 1                 
%                                   e.g. = #######.
%     	[fullPath]   	Logical.   	Defaults to true                      
%                                   e.g. = #######.               
%
% @Returns:  
%
%    	fn        	Char / StrCell	##########
%
% @Usage:           #####
% @Example:         fn = getBlockFns('Compound',99,1,3:4,3); fn{:}
%
% @Requires:        PsychTestRig (v0.5)
%   
% @See also:        getFiles.m, getCurBlockFn.m, runExperiment.m
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	27/11/2011
% @Last Update:     27/11/2011
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	27/11/2011    Initial build.
%
% NOT WORKING! (and possibly a bit silly anyway)


    %Check that we are good to go
    ensurePsychTestRigSetup();
    
    % init
    if nargin < 1 || isempty(expID)
        expID = getExpID();
    else
     	if ~isValidExpID(expID)
            msg=[   '/*****\n' ...
                    'Specified experiment invalid: ' escape([getPrefVal('homeDir') filesep expID]) '\n\n' ...
                    'Specify a different experiment,\n' ...
                    'or create a new experiment by using "createNewExperiment"\n' ...
                    '*****/' ...
             	];
            error('PsychTestRig:runExperiment:invalidExp',msg);
     	end
    end
    if nargin < 2 || isempty(pid)
        error('no participant id specified');
    end
    
 	%pid = any2str(pid);
    pid = sprintf('%i|',pid);
    pid(end) = [];  % e.g. '1|3', or '1'
    pid = ['(' pid ')'];
    
  	if nargin < 3 || isempty(sid)
        sid = '.+';
    else
        sid = sprintf('%i|',sid); sid(end) = [];  % e.g. '1|3', or '1'
        sid = ['(' sid ')'];
    end
    if nargin < 4 || isempty(bid)
        bid = '.+'; % e.g. [1-2]
    else
       %if isnumeric(bid) % e.g. [1 3]
           %bid = sprintf('%i,',bid);
           %bid = ['[' bid(1:(end-1)) ']']; % e.g. '[1,3]'
           bid = sprintf('%i|',bid); bid(end) = [];  % e.g. '1|3', or '1'
           bid = ['(' bid ')'];
           % above is crude!
           % e.g. see
           % http://www.regular-expressions.info/numericranges.html
       %end
       % example string: '[5-9]|([1][0-9])'  5+
    end
    if nargin < 5 || isempty(lastN)
        lastN = inf;
    end
    if nargin < 6 || isempty(fullPath)
        fullPath = true; % not yet used
    end

%     % determine dir
%     dataDir = [getPrefVal('homeDir') filesep expID filesep 'data' filesep pid];
%     %file_expr = sprintf('%s-%s-%s-*-*.csv', expID, pid, sid);
%     file_expr = sprintf('%s-%s-*-*-*.csv', expID, pid);
%     pattern =fullfile(dataDir, file_expr);
%     
%  	% get files
%     files = 	(pattern);

    % get files
    d = fullfile(getPrefVal('homeDir'), expID, 'data', '*', [expID '*.csv']);
    files = rdir(d);

    % exclude non-files
    files = files(~[files.isdir]); % exclude dirs
  	files(strncmp({files.name}, '.', 1)) = []; % exclude hidden
    
        
    % exclude unwanted blocks and sessions
    fn = {files.name};
    pattern = escape(sprintf('%s-%s-%s-%s-.+.csv', expID, pid, sid, bid));
    idx = regexpi(fn,pattern);
    idx = cellfun(@(x)~isempty(x), idx); % convert from cell of (1 item) vectors, to a vector
    files = files(idx);
    
    % get last n
    [~,idx] = sort([files.datenum],2,'descend');
    lastN = min(lastN, length(idx)); % adjust to avoid exceeding matrix dimensions
    idx = idx(1:lastN); % just specified number
    fn = {files(idx).name}; % get names

    % no longer needed now using rdir:
%     % make absolute
%     if fullPath
%         for i = 1:length(fn)
%             fn{i} = fullfile(dataDir,fn{i});
%         end
%     end
    
    if length(fn) == 1
        fn = fn{1};
    end
    files = files(idx);
end