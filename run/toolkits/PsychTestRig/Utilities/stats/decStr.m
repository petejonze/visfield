function strings = decStr(nums, nDec)

    if nargin < 2 || isempty(nDec)
        nDec = 2;
    end
    
    format = sprintf('%%1.%if\n',nDec);
    c = strread(sprintf(format,nums),'%s','delimiter','\n');
    %strings = cellfun(@(x)x(2:end),c,'UniformOutput',false); <-- doesn't work with minus values
    strings = regexprep(c,'\d+(?=\.)','');
    
end