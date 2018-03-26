%%
function data = processCountByRoi(X, Y, roiMask)
    img_h = size(roiMask,1);
    img_w = size(roiMask,2);
    xsize = size(X, 2);
    data = zeros(xsize,1);

    for row_count = 1:xsize
        data(row_count) = calcRoiPIAtFrame(Y{row_count}(:), X{row_count}(:), img_h, img_w, roiMask);
    end
end
