%% 02/05/2012, largely taken from SetupPsychtoolbox.m

% Locate ourselves:
targetdirectory=fileparts(mfilename('fullpath'));
if ~strcmpi(targetdirectory, pwd)
    error('You need to change your working directory to the PsychTestRig folder before running this routine!');
end

% Begin
fprintf('Will setup working copy of the PsychTestRig folder inside: %s\n',targetdirectory);
fprintf('\n');

% Check that Psychtoolbox is installed (since the following is dependent on
% it)
try
    AssertOpenGL();
catch ME
    error('InstallPsychTestRig:missingDependencies','Psychtoolbox not found. Please install that toolbox first before attempting to install PsychTestRig');
end

% Handle Windows ambiguity of \ symbol being the filesep'arator and a
% parameter marker:
if IsWin
    searchpattern = [filesep filesep 'PsychTestRig[' filesep pathsep ']'];
    searchpattern2 = [filesep filesep 'PsychTestRig'];
else
    searchpattern  = [filesep 'PsychTestRig[' filesep pathsep ']'];
    searchpattern2 = [filesep 'PsychTestRig'];
end

% Remove "Psychtoolbox" from path:
while any(regexp(path, searchpattern))
    fprintf('Your old PsychTestRig appears in the MATLAB/OCTAVE path:\n');
    paths=regexp(path,['[^' pathsep ']*'],'match');
    fprintf('Your old PsychTestRig appears %d times in the MATLAB/OCTAVE path.\n',length(paths));
    % Old and wrong, counts too many instances: fprintf('Your old Psychtoolbox appears %d times in the MATLAB/OCTAVE path.\n',length(paths));
    answer=input('Before you decide to delete the paths, do you want to see them (y or n)? ','s');
    if ~strcmp(answer,'y')
        fprintf('You didn''t say "yes", so I''m taking it as no.\n');
    else
        for p=paths
            s=char(p);
            if any(regexp(s,searchpattern2))
                fprintf('%s\n',s);
            end
        end
    end
    answer=input('Shall I delete all those instances from the MATLAB/OCTAVE path (y or n)? ','s');
    if ~strcmp(answer,'y')
        fprintf('You didn''t say yes, so I cannot proceed.\n');
        fprintf('Please use the MATLAB "File:Set Path" command or its Octave equivalent to remove all instances of "PsychTestRig" from the path.\n');
        error('Please remove PsychTestRig from MATLAB/OCTAVE path.');
    end
    for p=paths
        s=char(p);
        if any(regexp(s,searchpattern2))
            % fprintf('rmpath(''%s'')\n',s);
            rmpath(s);
        end
    end
    if exist('savepath') %#ok<EXIST>
       savepath;
    else
       path2rc;
    end

    fprintf('Success!\n\n');
end

% Add PsychTestRig to MATLAB/OCTAVE path
fprintf('Now adding the new PsychTestRig folder (and all its subfolders) to your MATLAB/OCTAVE path.\n');
p=targetdirectory;
pp=genpath(p);
addpath(pp);

if exist('savepath') %#ok<EXIST>
   err=savepath;
else
   err=path2rc;
end

if err
    fprintf('SAVEPATH failed. PsychTestRig is now already installed and configured for use on your Computer,\n');
    fprintf('but i could not save the updated Matlab/Octave path, probably due to insufficient permissions.\n');
    fprintf('You will either need to fix this manually via use of the path-browser (Menu: File -> Set Path),\n');
    fprintf('or by manual invocation of the savepath command (See help savepath). The third option is, of course,\n');
    fprintf('to add the path to the Psychtoolbox folder and all of its subfolders whenever you restart Matlab.\n\n\n');
else 
    fprintf('Add to path success.\n\n');
end

% Setup
if isSetup()
    fprintf('A valid PsychTestRig setup already exists, will keep using that.\n');
    fprintf('Type "ptr -viewSetup" to view.\n\n');
else
    fprintf('No valid PsychTestRig setup found.\n');
    answer=input('Do you wish to run the setup utility now\n[This is necessary, but can be done manually later\nby using the "ptr -setup" command] (y or n)? ','s');
    if ~strcmp(answer,'y')
        warning('InstallPsychTestRig:No_Setup','!!!PsychTestRig will not work until you run "ptr -setup"!!!\n\n');
    else
        ptr -setup;
    end
end

fprintf('\n\nPsychTestRig has been successfully installed. Enjoy!\n-------------------\n\n');
