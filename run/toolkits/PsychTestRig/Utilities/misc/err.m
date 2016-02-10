function x_err = err(x, varargin)
%ERR shortdesc.
%
%   calculate error
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        <blank>
% 
% @Author:          Pete R Jones
%
% @Creation Date:	14/10/10
% @Last Update:     14/10/10
%
% @Todo:            Everything!

	%----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('x', @isnumeric);
    p.addOptional('direction',1,@(x)isPositiveInt(x)); % std doesn't accept 3; @(x)isnumeric(x) && mod(x,1)==0
    p.addOptional('errortype','se',@(x)any(strcmpi(x,{'std','se','95ci'})));
    p.addOptional('excludeNaN', false,@ islogical);
    p.FunctionName = 'ERR';
    p.parse(x, varargin{:});
    %----------------------------------------------------------------------
    direction = p.Results.direction;
    errortype = p.Results.errortype;
    excludeNaN = p.Results.excludeNaN;
    %----------------------------------------------------------------------

    if excludeNaN
        n = sum(~isnan(x),direction);
        
        if strcmpi(errortype,'std')
            x_err = nanstd(x,[],direction);
        elseif strcmpi(errortype,'se')
            x_err = nanstd(x,[],direction) ./ sqrt(n);

%             x_err = bootci(2000,{@nanmean,x},'alpha',0.3180); % i.e., 1-.682
%             experimental_code
        elseif strcmpi(errortype,'95ci')
            x_err  = 1.96 * nanstd(x,[],direction) ./ sqrt(n);
            
%             x_err = bootci(2000,{@nanmean,x},'alpha',0.05); % i.e., 1-.682
%             experimental_code
        else
            error('err:unrecogType','unrecognised errortype "%s"',errortype);
        end
    else
        n = sum(ones(size(x)),direction); % size(x,direction);
        
        if strcmpi(errortype,'std')
            x_err = std(x,[],direction);
        elseif strcmpi(errortype,'se')
            x_err = std(x,[],direction) ./ sqrt(n);
            
%             x_err = bootci(2000,{@mean,x},'alpha',0.3180); % i.e., 1-.682
%             experimental_code
        elseif strcmpi(errortype,'95ci')
            x_err  = 1.96 * std(x,[],direction) ./ sqrt(n);
            
            x_err = bootci(2000,{@mean,x},'alpha',0.05); % i.e., 1-.682
%             experimental_code
        else
            error('err:unrecogType','unrecognised errortype "%s"',errortype);
        end
    end
    
    
    % OLD:
    %         if excludeNaN
    %             n = sum(~isnan(x),direction);
    % 
    %             if strcmpi(errortype,'std')
    %                 x_err = nanstd(x,[],direction);
    %             elseif strcmpi(errortype,'se')
    %                 x_err = nanstd(x,[],direction) ./ sqrt(n);
    %             elseif strcmpi(errortype,'95ci')
    %                 x_err  = 1.96 * nanstd(x,[],direction) ./ sqrt(n);
    %             else
    %                 error('err:unrecogType','unrecognised errortype "%s"',errortype);
    %             end
    %         else
    %             n = sum(ones(size(x)),direction); % size(x,direction);
    % 
    %             if strcmpi(errortype,'std')
    %                 x_err = std(x,[],direction);
    %             elseif strcmpi(errortype,'se')
    %                 x_err = std(x,[],direction) ./ sqrt(n);
    %             elseif strcmpi(errortype,'95ci')
    %                 x_err  = 1.96 * std(x,[],direction) ./ sqrt(n);
    %             else
    %                 error('err:unrecogType','unrecognised errortype "%s"',errortype);
    %             end
    %         end
end