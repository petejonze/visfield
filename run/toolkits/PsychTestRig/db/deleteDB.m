function deleteDB(varargin)
%CONNECTTODB shortdescr.
%
% Description
%
% Example: none
%
% See also

    %----------------------------------------------------------------------
    p = inputParser;
    p.addOptional('forceOpen', false, @islogical); %if true then opens a new connection regardless if already connected. This may be useful if worried about an inner function closing the connection
    p.addOptional('isSilent', false, @islogical); 
    p.FunctionName = 'CONNECTTODB';
    p.parse(varargin{:}); % Parse & validate all input args
    forceOpen=p.Results.forceOpen;
    isSilent=p.Results.isSilent;
    %----------------------------------------------------------------------
   
    if (forceOpen)
        connectToDatabaseServer(isSilent);
    elseif (mysql('status')) %if IS NOT already connected
        fprintf('   ')
        connectToDatabaseServer(isSilent);
    end

    if getLogicalInput('Are you sure you want to delete the psychtestrig database? (y/n): ')
        if getLogicalInput('Are you REALLY sure?? (y/n): ')
            bkupFn = sprintf('psychtestrig_%s.sql',regexprep(datestr(now(),20),'/','-'));
            %fprintf('making backup "%s"...\n',bkupFn);
            %msg=mysql(sprintf('mysqldump -u root -ppassword psychtestrig > %s',bkupFn) );
            %system(sprintf('mysqldump -u root -ppassword psychtestrig > %s',bkupFn));
            msg=mysql('DROP DATABASE psychtestrig');
            fprintf('database deleted\n');
        end
    end
        
end