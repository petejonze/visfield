function synchDatabase(varargin)
%SYNCHDATABASE shortdescr.
%
% Description
%
% Example: none
%
% See also


    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addOptional('supressOutput', false, @islogical);
    p.addParamValue('indent', 0, @(x)x>=0 && mod(x,1)==0);
    p.FunctionName = 'SYNCHDATABASE';
    p.parse(varargin{:}); % Parse & validate all input args
    supressOutput = p.Results.supressOutput;
    indentNum = p.Results.indent;
    %----------------------------------------------------------------------
    
    %initialise local variables
    indentStr = blanks(indentNum);
    
    %print intro message
    sub_output('Attempting to synchronise database with home directory...');
    
    %check connected
    if (mysql('status')) %if IS NOT connected
        connectToDatabaseServer('indent',indentNum+3,'tries',1);
    end
        
    try
        %select db
        msg=mysql('use psychtestrig');
        
        %retrieve experiments
        [name]=mysql('SELECT name FROM experiments');
        
        %check that all the db experiments can be found
        % ???????????????????????
        
        %check that all the experiments are in the db
        exps=getDirs(getPrefVal('homeDir'),true);
        checks=ismember(exps,name);
        failures={exps{~checks}};
        addAll = false;
        for i = 1:size(failures,2) %allow for exp not in db to be added
            exp = failures{i};
            disp(' ')
            sub_output(['   Unknown experiment directory found: "' exp '".'])
            if ~addAll
                usrInput = get1ofMInput([indentStr '   |   add experiment "' exp '" to database? [y/n/A(ll)/N(one)]: '],{'y','n','A','N'});
                if strcmp(usrInput,'N')
                    break
                elseif strcmpi(usrInput,'a')
                    addAll = true;
                end
            end
            if addAll || strcmpi(usrInput,'y')
                addExperimentToDatabase(exp);
                sub_output('   |   ammending default details..')
                ammendExperimentRecord(exp);
                sub_output('   added')
            else
                sub_output('   not added')
            end
        end
    catch
        mysql('close')                    
        rethrow(lasterror)
    end

    sub_output('...Synchronise successful.');
	mysql('close')   
    
    %%%%%%%%%%%%%%%%%%%%
    %%% SUBFUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%
    
    function sub_output(str)
        if ~supressOutput
            str = [indentStr str]; %blanks to indent
            cloutput(str)
        end
    end

end


