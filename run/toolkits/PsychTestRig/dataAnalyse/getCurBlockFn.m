function fn = getCurBlockFn()
%GETBLOCKFNS return most recent block data files
%
%   longdescr
%
% @Requires the following toolkits:
%               PsychTestRig v0.5
%   
% @Parameters:  
%
%    	<none>              
%
% @Returns:  
%
%    	fn        	Char / StrCell	##########
%
% @Usage:           #####
% @Example:         #####
%
% @Requires:        PsychTestRig (v0.5)
%   
% @See also:        <none>
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


     global DATAGATHERING_BEGUN OUTPUT_FILE_ID;
     
     if isempty(DATAGATHERING_BEGUN) || ~DATAGATHERING_BEGUN || isempty(OUTPUT_FILE_ID)
         fn = [];
     else
         fid = OUTPUT_FILE_ID;
         fn = fopen(fid);
         try
             fn = GetFullPath(fn); % System.IO.DirectoryInfo(fopen(fid)).FullName; % ALT: fopen(fid), but this will only return the path initially specified (e.g. even if relative)
         catch ME
             rethrow(ME)
         end
     end
end