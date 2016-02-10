function [pass verString]=mysql_isAtLeastVersion(versionNumCriterion, releaseLevelCriterion, releaseNumCriterion)
%MYSQL_CHECKVERSION shortdescr.
%
% Description
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10
    
    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('versionNumCriterion', @(x)x>=0 && mod(x,1)==0);
    p.addRequired('releaseLevelCriterion', @(x)x>=0 && mod(x,1)==0);
    p.addRequired('releaseNumCriterion', @(x)x>=0 && mod(x,1)==0);
    p.FunctionName = 'MYSQL_CHECKVERSION';
    p.parse(versionNumCriterion, releaseLevelCriterion, releaseNumCriterion);
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
   
    %get version info from MySQL
    verString=mysql('SELECT VERSION()');
    
    %parse version info into numeric format
  	verNum=regexp(verString,'^[0-9]+','match');
    verNum = str2double(verNum{1});
    rLevel=regexp(verString,'(?<=\.)[0-9]+(?=\.)','match');
    rLevel = str2double(rLevel{1});
    rNum=regexp(verString,'(?<=\.[0-9]+\.)[0-9]+','match');
    rNum = str2double(rNum{1});
    
    %perform checks & return result
    pass = true;
    if (verNum > versionNumCriterion)
        return; %fine
    elseif (verNum == versionNumCriterion && rLevel > releaseLevelCriterion)
        return; %fine
    elseif (verNum == versionNumCriterion && rLevel == releaseLevelCriterion && rNum >= releaseNumCriterion)
        return; %fine
    else
       pass = false;
    end

end