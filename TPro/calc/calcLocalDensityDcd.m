% calculate local density (DCD)
function result = calcLocalDensityDcd(X, Y, roiMask, r, cnR)
    xsize = length(X);
    result = zeros(length(xsize),1);
    tic;
    for row_count = 1:xsize
        % get detected points and roi points
        fx = X{row_count}(:);
        fy = Y{row_count}(:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        [result(row_count), dcdfly] = calcLocalDensityDcdFrame(fy,fx,r,cnR);
    end
    time = toc;
    disp(['calcLocalDensityDcd ... done : ' num2str(time) 's']);
end
