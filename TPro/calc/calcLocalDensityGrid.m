% calculate local density (HWMD)
function result = calcLocalDensityGrid(X, Y, roiMask, width, height)
    img_h = size(roiMask, 1);
    img_w = size(roiMask, 2);
    xsize = length(X);
    result = zeros(xsize,1);
    tic;
    % calcurate grid list
    gridAreas = getGridAreas(roiMask, img_w, img_h, width, height);

    % count each frame point
    for row_count = 1:xsize
        % get detected points and roi points
        fx = round(X{row_count}(:));
        fy = round(Y{row_count}(:));
        idx = find(fx==0|isnan(fx));
        if ~isempty(idx)
            fx(idx) = [];
            fy(idx) = [];
        end

        result(row_count) = calcLocalDensityGridFrame(fx, fy, gridAreas, img_w, img_h, width, height);
    end
    time = toc;
    disp(['calcLocalDensityGrid ... done : ' num2str(time) 's']);
end
