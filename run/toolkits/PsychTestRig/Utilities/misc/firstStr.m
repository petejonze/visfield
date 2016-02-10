function y = firstStr(x,dim)
%FIRST   first value.

if iscell(x)
    y = x{1};
else
    y = x;
end