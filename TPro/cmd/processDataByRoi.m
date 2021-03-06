%%
function data = processDataByRoi(keep_data, img_h, img_w, roiMask, data)
    for i = 1:size(data,1)
        fx = keep_data{2}(i, :);
        fy = keep_data{1}(i, :);
        Y = round(fy);
        X = round(fx);
        nanIdxY = find((Y > img_h) | (Y < 1));
        nanIdxX = find((X > img_w) | (X < 1));
        roiIdx = (X-1).*img_h + Y;
        roiIdx(isnan(roiIdx)) = 1; % TOOD: set dummy. this might be bad with empty ROI.
        roiIdx2 = find(roiMask(roiIdx) <= 0);
        nanIdx = unique([nanIdxY, nanIdxX, roiIdx2]);

        % make save string
        dataRow = data(i, :);
        dataRow(nanIdx) = NaN;
        data(i, :) = dataRow;
    end
end
