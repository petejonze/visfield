function blockID=getBlockID(fn, varargin)        
%GETBLOCKID short desc.
%
% Gets the block ID from the meta data. Compares the found value
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
%                   getBlockID(fn)
%                   getBlockID(fn,1)
%                   getBlockID(fn,'1')
%                   getBlockID(fn,2) %should throw an error
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
    p.FunctionName = 'GETBLOCKID';
    p.parse(fn,varargin{:});
    %----------------------------------------------------------------------
    blockID_expected = any2str(p.Results.expectedVal); %string since everything we will be dealing with will be strings
    %----------------------------------------------------------------------

	[pathStr,name,ext] = fileparts(fn); %#ok
        
    % calc from file name
    pattern = '(?<=-[0-9]+-[0-9]+-)[0-9]+'; %after third hyphen
    blockID_name = regexp(name, pattern, 'Match','Once');
    % calc from meta info
    blockID_meta = getMetaData(fn,'Block Num');
    
    if ~strcmpi(blockID_name,blockID_meta)
        fprintf(['\n%s\n'...
                'Found values did not match each other:'...
              	'\n                  From file name: %s'...
              	'\n   From file content (meta info): %s\n']...
              	,fn,blockID_name,blockID_meta)
        if getLogicalInput(sprintf('Replace file content value (%s) with file name value (%s)?',blockID_name,blockID_meta))
            expID = getMetaData(fn, 'Experiment ID');
            editMetaData(expID, fn,'Block ID', blockID_name);
        else
            error('getBlockID:mismatch', 'Mismatch detected. Use editMetaData to set the correct value')
        end
    end

    blockID = str2double(blockID_name);
end
        
