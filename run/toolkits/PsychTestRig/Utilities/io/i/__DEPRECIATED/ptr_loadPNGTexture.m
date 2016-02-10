function [texture, image]=ptr_loadPNGTexture(fullFn, winhandle)
    [image, ~, alpha] = imread(fullFn,'png');
    image(:,:,4) = alpha(:,:); % add the transparency layer to the image (for trans. back.)
    texture=Screen('MakeTexture', winhandle, image);
end
