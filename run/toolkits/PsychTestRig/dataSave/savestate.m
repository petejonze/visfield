% Get time
timestamp = datestr(now());

% Get filename
s=dbstack();
scriptfilename=s(2).name;
if ~strcmpi(scriptfilename(end-1:end), '.m'), scriptfilename=[scriptfilename, '.m']; end

% Get file content
fid=fopen(scriptfilename,'r');
script=char(fread(fid)');
fclose(fid);

% Clear tmp params
clear s f

% Calc filename to save to
[path,name] = fileparts(getOutputFn());
name = [name '_workspace.mat'];
fn = fullfile(path, name);

% Save data
save(fn);