function makeEditBackup(fn)
%MAKEEDITBACKUP short desc.
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
% @See also:        relabelPartID, getFilesMatching
% 
% @Author:          Pete R Jones
%
% @Creation Date:	02/04/10
% @Last Update:     02/04/10
%
% @Todo:            <blank>

    persistent preEditDir;

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('fn', @(x)exist(x,'file') > 0);
    p.FunctionName = 'MAKEEDITBACKUP';
    p.parse(fn);
    %----------------------------------------------------------------------

    if isempty(preEditDir)
        backupDir=getPrefVal('backupDir');
        if ~exist(backupDir,'dir')
            error('makeEditBackup:backUpDirNotFound',['Could not find the following backup directory: ' backupDir '\nTry running PsychTestRig -setup again?'])
        end
        if ~exist([backupDir filesep '__preEdit'],'dir')
            mkdir(backupDir,'__preEdit');
        end 
       	preEditDir = [backupDir filesep '__preEdit'];
    end
           
    % copy file to predEdit backup dir
 	copyfile(fn,preEditDir);
    
%     % rename backup file as '*.backup'
% 	if (strcmp(filesep,'\'))
%         fname=char(regexp(fname,['[^\' filesep ']*$'],'match')); %escape if necessary
%     else
%      	fname=char(regexp(fname,['[^' filesep ']*$'],'match'));
%     end
% 	newName=char(regexprep(fname,'.csv','.backup'));
% 	oldFullName=strjoin('',backupDir, filesep, fname);
%  	newFullName=strjoin('',backupDir, filesep, newName);
%   	x=movefile(oldFullName,newFullName);
    
    
end