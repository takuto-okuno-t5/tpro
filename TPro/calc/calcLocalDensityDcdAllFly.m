% calculate local density (DCD)
function [means, result] = calcLocalDensityDcdAllFly(X, Y, roiMask, r, cnR)
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

        [means(i), result(i,:)] = calcLocalDensityDcdFrame(fy,fx,r,cnR);
    end
    time = toc;
    disp(['calcLocalDensityDcdAllFly ... done : ' num2str(time) 's']);
end
