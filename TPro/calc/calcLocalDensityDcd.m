% calculate local density (DCD)
function result = calcLocalDensityDcd(CX, CY, roiMask, r, cnR)
    img_h = size(roiMask,1);
    img_w = size(roiMask,2);
    xsize = length(CX);
    result = zeros(length(xsize),1);
    tic;
    for row_count = 1:xsize
        % get detected points and roi points
        fx = CY{row_count}(:);
        fy = CX{row_count}(:);

        Y = round(fy);
        X = round(fx);
        nanIdxY = find((Y > img_h) | (Y < 1));
        nanIdxX = find((X > img_w) | (X < 1));
        roiIdx = (X-1).*img_h + Y;
        roiIdx(isnan(roiIdx)) = 1; % TOOD: set dummy. this might be bad with empty ROI.
        roiIdx(roiIdx > img_h*img_w) = 1; % remove outside of image
        roiIdx2 = find(roiMask(roiIdx) <= 0);
        nanIdx = unique([nanIdxY, nanIdxX, roiIdx2]);
        if ~isempty(nanIdx)
            fx(nanIdx) = NaN;
            fy(nanIdx) = NaN;
        end
        [result(row_count), dcdfly] = calcLocalDensityDcdFrame(fy,fx,r,cnR);
    end
    time = toc;
    disp(['calcLocalDensityDcd ... done : ' num2str(time) 's']);
end
