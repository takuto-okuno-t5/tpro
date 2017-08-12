%%
function gridAreas = getGridAreas(roiMask, img_w, img_h, width, height)
    mg = zeros(img_h, img_w);
    gridAreas = zeros(ceil(img_h / height), ceil(img_w / width));
    for i=1:width:img_w
        iEnd = min([i+width-1, img_w]);
        for j=1:height:img_h
            jEnd = min([j+height-1, img_h]);
            mg(:,:) = 0;
            mg(j:jEnd, i:iEnd) = 1;
            mg2 = mg .* roiMask;
            gridAreas(ceil(j / height), ceil(i / width)) = sum(sum(mg2));
        end
    end
end
