clc
dx = diff(linspace(0,13, 4+1))
yx = dx;
for i = 1:(length(dx)-1);
    round(dx(i))
    yx(i) = round(dx(i));
    dx(i+1) = dx(i+1) + (dx(i) - yx(i));
end
yx(end) = round(dx(end));
yx
    