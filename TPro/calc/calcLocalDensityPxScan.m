function result = calcLocalDensityPxScan(X, Y, roiMaskImage, r, hWaitBar)
    img_h = size(roiMaskImage,1);
    img_w = size(roiMaskImage,2);
    xsize = length(X);
    result = zeros(length(xsize),1);
    % for calc circle
    [rr cc] = meshgrid(1:img_w, 1:img_h);

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
        map(roiMaskImage==0) = 0;
        total = sum(sum(map));
        result(row_count) = total / length(fx);

        if ~isempty(hWaitBar)
            rate = row_count/xsize;
            waitbar(rate, hWaitBar, [num2str(int64(100*rate)) ' %']);
        end
    end
    % delete dialog bar
    if ~isempty(hWaitBar)
        delete(hWaitBar);
    end
end
