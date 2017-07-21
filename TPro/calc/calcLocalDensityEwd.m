% calculate local density (EWD)
function result = calcLocalDensityEwd(X, Y, roiMasks, currentROI, r)
    xsize = length(X);
    result = zeros(length(xsize),1);
    for row_count = 1:xsize
        % get detected points and roi points
        fy = X{row_count}(:);
        fx = Y{row_count}(:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        result(row_count) = calcLocalDensityEwdFrame(fx,fy,r);
    end
end
