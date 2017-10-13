%%
function boxSize = findFlyImageBoxSize(meanBlobmajor, mmPerPixel)
    boxSize = round((meanBlobmajor / mmPerPixel) * 1.25 / 16) * 16;
    if boxSize < 48
        boxSize = 48;
    end
end
