function isValid=isValidPartID(expID,partID)
%ISVALIDPARTID description.
%
% desc
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10


    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('expID', @ischar);
    p.addRequired('partID');
    p.FunctionName = 'STARTNEWDATASESSION';
    p.parse(expID,partID); % Parse & validate all input args
    %----------------------------------------------------------------------

    % initial checks
    if isempty(partID)
        fprintf('Error: empty partID\n');
        isValid=false;
        return;
    end
    if ~isPositiveInt(partID)
        fprintf('Error: partID must be a positive integer\n');
        isValid=false;
        return;
    end

    isValid=true;
end