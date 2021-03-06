% calculate local density (MD)
function result = calcLocalDensityMd(X, Y, roiMask)
    xsize = length(X);
    result = zeros(xsize,1);
    tic;
    for row_count = 1:xsize
        % get detected points and roi points
        fx = X{row_count}(:);
        fy = Y{row_count}(:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        result(row_count) = calcLocalDensityMdFrame(fy,fx);
    end
    time = toc;
    disp(['calcLocalDensityMd ... done : ' num2str(time) 's']);
end
