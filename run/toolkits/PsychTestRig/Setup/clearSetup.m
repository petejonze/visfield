function clearSetup(varargin)
%CLEARSETUP shortdescr.
%
% Description
%
% Example: none
%
% See also exportSetup, checkSetup
% 
% @Author: Pete R Jones
% @Date: 22/01/10

% distinguish between partial and complete setup?

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addOptional('forceClear', 0, @islogical);
    p.FunctionName = 'CLEARSETUP';
    p.parse(varargin{:});
    forceClear = p.Results.forceClear;
    %----------------------------------------------------------------------
    
%     if ~isempty(getPrefVal())
   	if isSetup()
        if (forceClear || getLogicalInput('!!!!!Are you sure you wish to clear the existing setup? ("y" to proceed/ "n" to abort): '))
            rmPrefVal();
            disp(' ');
        else
           error('Script terminated by user') 
        end
    end
    
    if isempty(getPrefVal())
        setupStruct = getBlankSetup();
        setPrefVals(fieldnames(setupStruct),struct2cell(setupStruct));
    end
        
end