% calculate local density (HWMD)
function result = calcLocalDensityHwmd(X, Y, roiMasks, currentROI)
    xsize = length(X);
    result = zeros(length(xsize),1);
    tic;
    for row_count = 1:xsize
        % get detected points and roi points
        fx = X{row_count}(:);
        fy = Y{row_count}(:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        result(row_count) = calcLocalDensityHwmdFrame(fy,fx);
    end
    time = toc;
    disp(['calcLocalDensityHwmd ... done : ' num2str(time) 's']);
end
