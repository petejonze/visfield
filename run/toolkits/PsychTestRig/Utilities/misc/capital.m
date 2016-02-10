% example: capital('hello') => 'Hello'
% see also: lower, upper
function y = capital(str)
    if length(str) == 1
        y = upper(str);
    else
        y = [upper(str(1)) lower(str(2:end))];
    end

end