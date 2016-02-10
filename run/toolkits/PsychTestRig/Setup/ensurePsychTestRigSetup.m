function ensurePsychTestRigSetup()
    if (~isSetup())
        error('PsychTestRig:ensurePsychTestRigSetup:Fail', '/*****Script Terminated:\n   PsychTestRig has not been configured.\n   Please type "PsychTestRig -setup" before proceeding\n   Or type "checkSetup" for more details\n*****/')
    end
end
    

