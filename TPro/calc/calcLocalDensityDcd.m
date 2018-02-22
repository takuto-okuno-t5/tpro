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

        if ~isempty(roiMask)
            Y = round(fy);
            X = round(fx);
            nanIdxY = find((Y > img_h) | (Y < 1));
            nanIdxX = find((X > img_w) | (X < 1));
            roiIdx = (X-1).*img_h + Y;
            roiIdx(isnan(roiIdx)) = 1; % TOOD: set dummy. this might be bad with empty ROI.
            roiIdx(roiIdx > img_h*img_w) = 1; % remove outside of image
            nanIdx = find(roiMask(roiIdx) <= 0);
            if ~isempty(nanIdxY)
                nanIdx = [nanIdx, nanIdxY];
            end
            if ~isempty(nanIdxX)
                nanIdx = [nanIdx, nanIdxX];
            end
            if ~isempty(nanIdx)
                nanIdx = unique(nanIdx);
                fx(nanIdx) = NaN;
                fy(nanIdx) = NaN;
            end
        end
        [result(row_count), dcdfly] = calcLocalDensityDcdFrame(fy,fx,r,cnR);
    end
    time = toc;
    disp(['calcLocalDensityDcd ... done : ' num2str(time) 's']);
end
