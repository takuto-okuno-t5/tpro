% calculate local density (SSI)
function result = calcLocalDensitySsi(X, Y, roiMask, binSize, binNum)
    xsize = length(X);
    result = zeros(xsize,1);
    tic;
    for row_count = 1:xsize
        % get detected points and roi points
        fx = X{row_count}(:);
        fy = Y{row_count}(:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        histgram = calcLocalDensitySsiFrame(fy,fx,binSize,binNum);
        result(row_count) = (histgram(1) - histgram(2)) / sum(histgram);
    end
    time = toc;
    disp(['calcLocalDensitySsi ... done : ' num2str(time) 's']);
end
