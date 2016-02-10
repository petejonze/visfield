function [cursorMatrix, rect] = makeCross(npixels, rgba, penwidth, rgbaBackground)
    % parse inputs
    if nargin < 1 || isempty(npixels)
        npixels = 16; % (useful to be a power of two), should be even
    end
    if nargin < 2 || isempty(rgba)
        rgba = [255 255 255 255]; % white, non-trasparent
    end
  	if nargin < 3 || isempty(penwidth)
        penwidth = 2; % 2 pixels wide
    end
  	if nargin < 4 || isempty(rgbaBackground)
        rgbaBackground = [155 155 155 0]; % grey, transparent
    end

    % init
    if length(rgba) == 3
        rgba = [rgba 255]; % append alpha, assuming solid
    end
    stripeidx = npixels/penwidth + (0:(penwidth-1));
    
    % make (undoubtedly a more elegant way to write this)
    cursorMatrix = nan(npixels,npixels,4);
    %
    cursorMatrix(:,:,1) = rgbaBackground(1);
    cursorMatrix(:,:,2) = rgbaBackground(2);
    cursorMatrix(:,:,3) = rgbaBackground(3);
    cursorMatrix(:,:,4) = rgbaBackground(4);
    %
    cursorMatrix(:,stripeidx,1) = rgba(1);
    cursorMatrix(:,stripeidx,2) = rgba(2);
    cursorMatrix(:,stripeidx,3) = rgba(3);
    cursorMatrix(:,stripeidx,4) = rgba(4);
    %
    cursorMatrix(stripeidx,:,1) = rgba(1);
    cursorMatrix(stripeidx,:,2) = rgba(2);
    cursorMatrix(stripeidx,:,3) = rgba(3);
    cursorMatrix(stripeidx,:,4) = rgba(4);
    
    % finish up
    rect = [0 0 npixels npixels];
end