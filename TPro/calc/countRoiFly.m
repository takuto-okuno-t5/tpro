%%
function count = countRoiFly(fx, fy, img_h, img_w, flyNum, roiMask)
    count = 0;
    for j = 1:flyNum
        y = round(fy(j));
        x = round(fx(j));
        if (y <= img_h) && (x <= img_w) && ~isnan(y) && ~isnan(x) && x >= 1 && y >= 1 && roiMask(y,x) > 0
            count = count + 1;
        end
    end
end
