function userInput=getBooleanInput(promptText)
%GETBOOLEANINPUT command-line prompts user for boolean (yes/no) information
%
% getBooleanInput(promptText) returns 1 if the user indicates 'y', 't' or
% '1', or 0 if the user indicates 'n', 'f' or '0'. The prompt will loop for
% any other input, except 'q' which will terminate the entire script.
%
% Example: none
%
% See also getIntegerInput getNumericInput getStringInput
%
%   !!!!DEPRECIATED!!!! use getLogicalInput instead

warning('PsychToolbox2:depreciatedFunction','getBooleanInput is depreciated, use getLogicalInput instead');

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('prompt', @ischar);
    p.FunctionName = 'GETBOOLEANINPUT';
    p.parse(promptText); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    while(1)
        x = input(promptText,'s'); % get user input
        if (~isempty(x)) % not empty user input
            if (x(1) == 'q') 
                error('script terminated by user') 
            else
                if ((x(1) == 'y') || (x(1) == 't') || (x(1) == '1'))
                    userInput = 1;
                    break % return 'True'
                elseif ((x(1) == 'n') || (x(1) == 'f') || (x(1) == '0'))
                    userInput = 0;
                    break % return 'False'
                end
            end
        end 
    end 
    
end
