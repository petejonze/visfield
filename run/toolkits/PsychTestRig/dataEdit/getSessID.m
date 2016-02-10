function sessID=getSessID(fn, varargin)        
%GETSESSID short desc.
%
% Gets the session ID from the meta data. Compares the found value
% against the value specified in the file name 
% and also any value specified by the user. Throws an error if any 
% mismatches
%
%   n.b. fn should be a full file name (i.e. with absolute path)
%
%   returns numeric
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         fn = 'K:\Peter\Experiments\SummerScientist2010\data\8\SummerScientist2010-8-1-1-20100816T131149.csv';
%                   getSessID(fn)
%                   getSessID(fn,1)
%                   getSessID(fn,'1')
%                   getSessID(fn,2) %should throw an error
%
% @See also:        getPartID, getBlockID, getMetaData
% 
% @Author:          Pete R Jones
%
% @Creation Date:	26/08/10
% @Last Update:     26/08/10
%
% @Todo:            <blank>

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('fn', @(x)exist(x,'file')>0);
    p.addOptional('expectedVal',[],@(x)1==1);
    p.FunctionName = 'GETSESSID';
    p.parse(fn,varargin{:});
    %----------------------------------------------------------------------
    sessID_expected = any2str(p.Results.expectedVal); %string since everything we will be dealing with will be strings
    %----------------------------------------------------------------------

	[pathStr,name,ext] = fileparts(fn); %#ok
        
    % calc from file name
    pattern = '(?<=-[0-9]+-)[0-9]+'; %after second hyphen
    sessID_name = regexp(name, pattern, 'Match','Once');

    % calc from meta info
    sessID_meta = getMetaData(fn,'Session ID');
    
    if ~strcmpi(sessID_name,sessID_meta)
        fprintf(['\n%s\n'...
                'Found values did not match each other:'...
              	'\n                  From file name: %s'...
              	'\n   From file content (meta info): %s\n']...
              	,fn,sessID_name,sessID_meta)
        if getLogicalInput(sprintf('Replace file content value (%s) with file name value (%s)?',sessID_name,sessID_meta))
            expID = getMetaData(fn, 'Experiment ID');
            editMetaData(expID, fn,'Session ID', sessID_name);
        else
            error('getSessID:mismatch', 'Mismatch detected. Use editMetaData to set the correct value')
        end
    end
      
    % check against expected (if specified)
    if ~isempty(sessID_expected)
        if ~strcmpi(sessID_expected,sessID_name) %take sessID_name as exemplar, since already established that all are equal
            error('getsessID:mismatch', [   'Found values did not match that specified:' ...
                                            '\n   Specified: %s' ...
                                            '\n       Found: %s']...
                                            ,sessID_expected,sessID_name)
        end
    end

    sessID = str2double(sessID_name);
end
        
