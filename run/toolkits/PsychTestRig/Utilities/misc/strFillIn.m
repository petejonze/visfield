function bufferedStr=strFillIn(inputStr,totalLength,bufferSymbol)
%STRFILLOUT shortdescr.
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
    p.addRequired('inputStr',@ischar);
    p.addRequired('totalLength',@(x)x>0 && mod(x,1)==0); %integer
    p.addRequired('bufferSymbol',@ischar);
    p.FunctionName = 'STRFILLOUT';
    p.parse(inputStr,totalLength,bufferSymbol);
    %----------------------------------------------------------------------
    
    if length(inputStr) >= totalLength
        bufferedStr=inputStr;
        return
    end
    
    buffNum = totalLength - length(inputStr);
    buffNum = floor(buffNum / length(bufferSymbol));
    bufferStr = regexprep(blanks(buffNum),' ',bufferSymbol);
    bufferedStr = [bufferStr inputStr];

end