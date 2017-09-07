% calculate local density (DWD)
function result = calcLocalDensityDwd(X, Y, roiMask, r, inverseSlope)
    xsize = length(X);
    result = zeros(length(xsize),1);
    tic;
    for row_count = 1:xsize
        % get detected points and roi points
        fx = X{row_count}(:);
        fy = Y{row_count}(:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        [result(row_count), dwdfly] = calcLocalDensityDwdFrame(fy,fx,r,inverseSlope);
    end
    time = toc;
    disp(['calcLocalDensityDwd ... done : ' num2str(time) 's']);
end
