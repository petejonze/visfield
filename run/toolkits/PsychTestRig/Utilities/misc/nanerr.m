function x_err = nanerr(x,varargin)


	%----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('x', @isnumeric);
    p.addOptional('direction',1,@(x)isPositiveInt(x)); % std doesn't accept 3; @(x)isnumeric(x) && mod(x,1)==0
    p.addOptional('errortype','se',@(x)any(strcmpi(x,{'std','se','95ci'})));
    p.addOptional('excludeNaN', true,@ islogical);
    p.FunctionName = 'ERR';
    p.parse(x, varargin{:});
    %----------------------------------------------------------------------
    direction = p.Results.direction;
    errortype = p.Results.errortype;
    excludeNaN = p.Results.excludeNaN;
    %----------------------------------------------------------------------

    x_err = err(x, direction, errortype, excludeNaN);
    
end