function connectToDb(varargin)
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
        
    %select db
    msg=mysql('use psychtestrig');
        
end