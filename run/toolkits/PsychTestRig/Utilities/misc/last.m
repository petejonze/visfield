function y = last(x,dim)
%LAST   last value.
% see first()

if iscell(x)
    y = x{length(x)};
else
    y = x(length(x));
end