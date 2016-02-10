function [] = AssertPTR()
% todo: change function name?

    s = dbstack();
    [~,expID] = fileparts(fileparts(fileparts(fileparts(which(s(end).file)))));

    if length(dbstack) <= 2
        try
            exampleConfig = getConfigIDs(expID,1);
            exampleConfig = exampleConfig{1};
        catch %#ok
            exampleConfig = 'MyConfigFileName';
        end
        error('AssertPTR:invalidInvocation', 'The experiment script should not be called directly, but rather should be run via PsychTestRig\n\n e.g., ptr -run %s\n e.g., ptr -run %s -from %s -pid 99 -sid 1 -skipLogin true -autoStart true', expID, expID, exampleConfig);
    end
end