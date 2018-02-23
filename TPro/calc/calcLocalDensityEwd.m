% calculate local density (EWD)
function result = calcLocalDensityEwd(X, Y, roiMask, r)
    xsize = length(X);
    result = zeros(xsize,1);
    tic;
    for row_count = 1:xsize
        % get detected points and roi points
        fx = X{row_count}(:);
        fy = Y{row_count}(:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        [result(row_count), ewdfly] = calcLocalDensityEwdFrame(fy,fx,r);
    end
    time = toc;
    disp(['calcLocalDensityEwd ... done : ' num2str(time) 's']);
end
