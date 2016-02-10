function partID=getPartID(fn, varargin)        
%GETPARTID short desc.
%
% Gets the participant ID from the meta data. Compares the found value
% against the value specified in the file name, the name of the parent dir, 
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
%                   getPartID(fn)
%                   getPartID(fn,8)
%                   getPartID(fn,'8')
%                   getPartID(fn,4) %should throw an error
%
% @See also:        getSessID, getBlockID, getMetaData
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
    p.FunctionName = 'GETPARTID';
    p.parse(fn,varargin{:});
    %----------------------------------------------------------------------
    partID_expected = any2str(p.Results.expectedVal); %string since everything we will be dealing with will be strings
    %----------------------------------------------------------------------

	[pathStr,name,ext] = fileparts(fn); %#ok
        
    % calc from file name
    pattern = '(?<=-)[0-9]+'; %after first hyphen
    partID_name = regexp(name, pattern, 'Match','Once');
    
    % calc from dir
 	partID_dir = regexp(pathStr,['[^\' filesep ']+$'],'match','Once');   %e.g. K:\Peter\Experiments\exp1ver8\data\13   ->  13
        
    % calc from meta info
    partID_meta = getMetaData(fn,'Participant ID');
    
    if ~strcmpi(partID_name,partID_dir) || ~strcmpi(partID_dir,partID_meta)
        disp(fn);
        error('getPartID:mismatch', [   'Found values did not match each other:'...
                                        '\n                  From file name: %s'...
                                        '\n           From parent directory: %s'...
                                        '\n   From file content (meta info): %s']...
                                        ,partID_name,partID_dir,partID_meta)
    end
      
    if ~isempty(partID_expected)
        if ~strcmpi(partID_expected,partID_name) %take partID_name as exemplar, since already established that all are equal
            error('getPartID:mismatch', [   'Found values did not match that specified:' ...
                                            '\n   Specified: %s' ...
                                            '\n       Found: %s']...
                                            ,partID_expected,partID_name)
        end
    end

    partID = str2double(partID_name);
end
        
