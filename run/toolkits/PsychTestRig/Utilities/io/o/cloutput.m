function cloutput(textToDisplay, varargin)
%CLOUTPUT shortdescr.
%
% Description
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 04/02/10

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('textToDisplay',@ischar);
    p.addOptional('carriageReturn', true, @islogical);
    p.addOptional('indentAmount', 0, @(x)x>=0 && mod(x,1)==0);
    p.FunctionName = 'CLOUTPUT';
    p.parse(textToDisplay, varargin{:}); % Parse & validate all input args
    carriageReturn = p.Results.carriageReturn;
    indentAmount = p.Results.indentAmount;
    %----------------------------------------------------------------------
    
    if (regexp(textToDisplay,'^%'))
       if strcmp(textToDisplay, '%dline')
            disp([blanks(indentAmount) '=========================================================='])
       elseif strcmp(textToDisplay, '%line')
            disp([blanks(indentAmount) '----------------------------------------------------------'])
        end
    else
        
        textToDisplay = [blanks(indentAmount) textToDisplay];
        textToDisplay = regexprep(textToDisplay, '\\n', ['\\n' blanks(indentAmount)]);
        textToDisplay = deblank(textToDisplay); %strip out trailing white space
        
        if carriageReturn
            textToDisplay = regexprep(textToDisplay, '\\n', char(10));  
            disp(char(cellstr(textwrap({textToDisplay},80))))
        else
            fprintf(textToDisplay)
        end
    end
    
end