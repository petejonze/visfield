function strStruct=struct2String(thestruct, varargin)
%STRUCT2STRING shortdescr.
%
% Description
%
% Example: none
%
% See also dispStruct, dispStruct4
% 
% @Author: Pete R Jones
% @Date: 22/01/10
% @Last Update: 09/01/2010

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('thestruct', @isstruct);
    p.addParamValue('indent', 4, @(x)x>=0 && mod(x,1)==0); %4 = disp()
    p.addParamValue('showNames', true, @islogical);
    p.addParamValue('showVals', true, @islogical);
    p.addParamValue('offshoot', false, @islogical);
    p.addParamValue('trailingBlank', false, @islogical);
    p.FunctionName = 'STRUCT2STRING';
    p.parse(thestruct, varargin{:});
    indentNum = p.Results.indent;
    showNames = p.Results.showNames;
    showVals = p.Results.showVals;
    isOffshoot = p.Results.offshoot;
    isTrailingBlankLine = p.Results.trailingBlank;
    %----------------------------------------------------------------------
    strStruct='';
    %----------------------------------------------------------------------
    
    %check not empty
    if isempty(fieldnames(thestruct)) %no fields
        strStruct = '';
        return
    end
    if isempty(struct2cell(thestruct)) %no vals
        strStruct = '';
        return
    end
    
    
    %initialise local variables
    longestWordLength = 0;
    if (showNames && showVals)
        sepStr = ': ';
    else
        sepStr = '';
    end
    FNs = fieldnames(thestruct); %get field names    
    FVs = struct2cell(thestruct); %get values
    
    %display results
    for i=1:size(FNs,1)
        name = sub_getName(FNs,i);
        val = FVs{i};
        
        if isstruct(val)
            if showNames
                if showVals %crude
                    name = regexprep(name,': ',':-|');
                else
                    name = [name ' -|'];
                end
                strStruct=[strStruct name '\n'];
            end
            strStruct = [strStruct struct2String(val, 'indent',(length(name)-1),'showNames',showNames,'showVals',showVals,'offshoot',true)];
        elseif ischar(val)
            valStr = sub_getCharVal(val);
            strStruct=[strStruct name valStr '\n'];
        elseif isnumeric(val)
            valStr = sub_getNumVal(val);
            strStruct=[strStruct name valStr '\n'];
    	elseif islogical(val)
            valStr = log2str(val);
            strStruct=[strStruct name valStr '\n'];
        else
            valStr = sub_getCellVals(val);
            strStruct=[strStruct name valStr '\n'];
        end   
    end
        
    %print blank line at end - like disp(struct)
    if ~isOffshoot
        if isTrailingBlankLine
            strStruct = [strStruct '\n'];
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    %%% SUB FUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%%
    function nameStr=sub_getName(strCell,i)
        if showNames
            longestWordLength = max(cellfun(@length,strCell));
            str = strCell{i};
            if isOffshoot
                strBuff = [blanks(indentNum) '|-' blanks(longestWordLength - length(str))]; %+5 to account for "|-" and ":-|"
            else
                strBuff = blanks(longestWordLength - length(str) + indentNum);
            end
            nameStr = [strBuff str sepStr];
        else
            nameStr = '';
        end
    end
    function valStr=sub_getCharVal(val)
        if showVals
            valStr = ['''' val '''']; %wrap in quote marks, e.g. foo => 'foo'
        else
            valStr = '';
        end
    end
    function valStr=sub_getNumVal(val) %convert class(numeric) => class(char)
        if showVals
            valStr = num2str(val);
        else
            valStr = '';
        end
    end
    function valStr=sub_getCellVals(val)
        if showVals
            vals = any2str(val{:});
            valStr = ['{' strjoin(', ',vals{:}) '}'];
        else
            valStr = '';
        end
    end     
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%



