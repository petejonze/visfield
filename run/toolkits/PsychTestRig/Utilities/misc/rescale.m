function y=rescale(x, newMin, newMax)
    y = (x-min(x)) .* (newMax-newMin)/(max(x)-min(x)) + newMin;
end