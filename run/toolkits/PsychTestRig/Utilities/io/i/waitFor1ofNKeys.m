function [responseKey,responseLatency,nKeyPresses]=waitFor1ofNKeys(keySet)
    nKeyPresses=0;
    responseLatency=0-GetSecs;
    % wait for key input
    while (1)
        [resptime, keyCode] = KbWait([], 2);
        
        responseLatency = responseLatency+resptime;
        nKeyPresses = nKeyPresses + 1;

        responseKey=KbName(keyCode);  %find out which key was pressed & translate code into letter (string)
        responseKey_first = (responseKey);
        
        if any(strcmpi(responseKey_first,keySet)) % proceed
            break
        end
     
        if any(strcmpi(responseKey,'ESCAPE')) && any(strcmpi(responseKey,'Q')) %press Q and Escape together to quit
            error('UserInput:Quit','Experiment aborted by user!!');
        end
    end
end   