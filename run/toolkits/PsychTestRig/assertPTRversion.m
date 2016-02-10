function [] = assertPTRversion(expectedVer)
    if verLessThan('PsychTestRig', any2str(expectedVer))
        v = ver('PsychTestRig');
        error('assertPTRversion:Failed','Specified PTR version number ["%s"] does not match the installed version number ["%s"]', any2str(expectedVer), v.Version);
    end
    if verGreaterThan('PsychTestRig',any2str(expectedVer))
        v = ver('PsychTestRig');
        str = sprintf('Specified PTR version number ["%s"] does not match the installed version number ["%s"]', any2str(expectedVer), v.Version);
        if ~getLogicalInput([str '\nContinue (y/n)?'])
            error('assertPTRversion:Failed','Specified PTR version number ["%s"] does not match the installed version number ["%s"]', any2str(expectedVer), v.Version);
        end
    end

end