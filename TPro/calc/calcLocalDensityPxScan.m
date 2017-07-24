function result = calcLocalDensityPxScan(X, Y, roiMaskImage, r, hWaitBar)
    img_h = size(roiMaskImage,1);
    img_w = size(roiMaskImage,2);
    xsize = length(X);
    result = zeros(length(xsize),1);
    % for calc circle
    [rr cc] = meshgrid(1:img_w, 1:img_h);
    roiIdx = find(roiMaskImage==1);
    roiLen = length(roiIdx);

    tic;
    for row_count = 1:xsize
        % Check for Cancel button press
        if ~isempty(hWaitBar)
            isCancel = getappdata(hWaitBar, 'canceling');
            if isCancel
                break;
            end
        end
        % get detected points and roi points
        fx = X{row_count}(:);
        fy = Y{row_count}(:);
        map = calcLocalDensityPxScanFrame(fy, fx, rr, cc, r, img_h, img_w);
        mMean = mean(map(roiIdx));
        map = map - mMean;
        map = map .* map;
        total = sum(map(roiIdx));
        result(row_count) = total / roiLen;

        if ~isempty(hWaitBar)
            rate = row_count/xsize;
            waitbar(rate, hWaitBar, [num2str(int64(100*rate)) ' %']);
        end
    end
    time = toc;
    disp(['calcLocalDensityPxScan ... done : ' num2str(time) 's']);

    % delete dialog bar
    if ~isempty(hWaitBar)
        delete(hWaitBar);
    end
end
