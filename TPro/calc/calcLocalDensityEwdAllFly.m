% calculate local density (EWD)
function [means, result] = calcLocalDensityEwdAllFly(X, Y, roiMask, r)
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

        [means(i), result(i,:)] = calcLocalDensityEwdFrame(fy,fx,r);
    end
    time = toc;
    disp(['calcLocalDensityEwdAllFly ... done : ' num2str(time) 's']);
end
