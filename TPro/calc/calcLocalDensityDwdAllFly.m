% calculate local density (DWD)
function [means, result] = calcLocalDensityDwdAllFly(X, Y, roiMask, r, inverseSlope)
    flameMax = size(X, 1);
    flyNum = size(X, 2);
    
    means = zeros(flameMax,1);
    result = zeros(flameMax,flyNum);
    tic;
    for i = 1:flameMax
        % get detected points and roi points
        fx = X(i,:);
        fy = Y(i,:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        [means(i), result(i,:)] = calcLocalDensityDwdFrame(fy,fx,r,inverseSlope);
    end
    time = toc;
    disp(['calcLocalDensityDwdAllFly ... done : ' num2str(time) 's']);
end
