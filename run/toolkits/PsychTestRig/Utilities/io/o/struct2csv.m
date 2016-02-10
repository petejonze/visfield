function struct2csv(s, fn, overwrite, joinChar)
%STRUCT2CSV Write struct to a csv file   
%
%  	####
%
% @Parameters:             
%
%     	s           Struct      Structure
%
%     	fn          Char        Output file name
%
%     	overwrite 	Logical     ####
%
%     	joinChar  	Char        ####
%                                
% @Returns:  
%
%    	<none>
%
% @Usage:           struct2csv(s, fn, [overwrite])   
% @Example:         s = struct; s.name = {'pedro','jonez'}; s.age = 87; s.sex = 'M'; 
%                   struct2csv(s, './myInfo.csv', true);
%
%                   s = struct; s.name.first = 'pedro'; s.name.last ='jonez'; s.age = 87; s.sex = 'M'; 
%                   struct2csv(s, './myInfo.csv', true, '-');
%
% @Requires:        flatNestedStructAccessList.m
%   
% @See also:        #####
%
% @Matlab:          v2008 onwards (?)
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	11/06/11
% @Last Update:     11/06/11
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	11/06/11    Initial build.
%                   v1.0.1	12/06/11    Allowed for nested structures
%
% @Todo:            Lots!
%
%    Allowed for nested fields (_) ?            	
    
% accessList = flatNestedStructAccessList(s)


    %% Init  
    % insert defaults
    if nargin < 3 || isempty(overwrite)
        overwrite = false;
    end
    if nargin < 4 || isempty(joinChar)
        joinChar = '-';
    end
    % validate
    if exist(fn,'file') && ~overwrite
        error('struct2csv:invalidInput', 'File %s already exists\nRun again with the overwrite==true to force overwrite', fn);
    end
  
    %% Get complete list of fields
    accessList = flatNestedStructAccessList(s);

    
    %% Create cellstr matrix
   	% Caculate the size of matrix required
    nCols = length(accessList);
    %
    nRows = 0;
    for j=1:nCols
        content = eval(['s.' accessList{j}]); % OLD: s.(field{j});
        % fix any inputs
        if ischar(content);
            eval(['s.' accessList{j} ' = {content};']);
        elseif isnumeric(content)
            eval(['s.' accessList{j} ' = num2cell(content);']);
        elseif islogical(content)
            eval(['s.' accessList{j} ' = num2cell(single(content));']);
        end
        %
        content = eval(['s.' accessList{j}]); % re-calc in case changed
        %
        l = length(content);
        if l > nRows; nRows = l; end
    end
    %
    % intialise cell matrix
    matrix = cell(nRows+1, nCols);
    % insert headers
    for j=1:nCols
       matrix{1,j} = regexprep(accessList{j},'\.',joinChar); % OLD: field{j};
    end
    % insert content
    for j=1:nCols
        content = eval(['s.' accessList{j}]); % OLD: s.(field{j});
      	matrix(2:end-(nRows-length(content)),j) = content';
    end    
    %
    % older matlab versions do not support output of mixed-type matrices
    % (num & str)
    for i=1:(nRows+1)
        for j=1:nCols
            if isnumeric(matrix{i,j})
                matrix{i,j} = num2str(matrix{i,j});
            end
        end
    end

    %% Output to file
    % open/create file
    fid = fopen(fn,'w+');
    % write data
    for i=1:(nRows+1) 
        output = sprintf('%s,',matrix{i,:});
        output = output(1:end-1); % remove trailing comma
        fprintf(fid, '%s', output);
        fwrite(fid, getNewline(), 'char'); % terminate this line
    end
    % close file
    fclose(fid); 
    
end