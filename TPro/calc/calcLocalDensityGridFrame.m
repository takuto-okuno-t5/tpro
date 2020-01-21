% ----- calculate local density (frame) -----
function [result, gridDensity] = calcLocalDensityGridFrame(x, y, gridAreas, img_w, img_h, width, height, mmPerPixel)
    map = zeros(img_h, img_w);
    for i=1:length(x)
        map(y(i),x(i)) = 1;
    end

    % calc local_dencity
    counts = zeros(1,sum(sum(gridAreas>0)));
    gridDensity = gridAreas;
    gridDensity(:,:) = 0;
    boxArea = (width * mmPerPixel) * (height * mmPerPixel);
    k = 1;
    for i=1:width:img_w
        iEnd = min([i+width-1, img_w]);
        for j=1:height:img_h
            area = gridAreas(ceil(j / height), ceil(i / width));
            if area > 0
                jEnd = min([j+height-1, img_h]);
                count = sum(sum(map(j:jEnd, i:iEnd)));
                counts(k) = count / boxArea;
                gridDensity(ceil(j / height), ceil(i / width)) = counts(k);
                k = k + 1;
            end
        end
    end
    result = var(counts, 1);
end
