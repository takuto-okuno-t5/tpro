%%
function piCounts = calcPI(X, Y, roiMasks)
    img_h = size(roiMasks{1},1);
    img_w = size(roiMasks{1},2);
    xsize = size(X, 2);
    piCounts = zeros(xsize,1);

    for row_count = 1:xsize
        count1 = calcRoiPIAtFrame(Y{row_count}(:), X{row_count}(:), img_h, img_w, roiMasks{1});
        count2 = calcRoiPIAtFrame(Y{row_count}(:), X{row_count}(:), img_h, img_w, roiMasks{2});
        piCounts(row_count) = (count1 - count2) / (count1 + count2);
    end
end
