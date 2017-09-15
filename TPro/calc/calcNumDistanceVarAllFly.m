% calculate top num of distances and variance
function [means, vars] = calcNumDistanceVarAllFly(X, Y, roiMask, num)
    flameMax = size(X, 1);
    flyNum = size(X, 2);
    
    means = zeros(flameMax,flyNum);
    vars = zeros(flameMax,flyNum);
    tic;
    for i = 1:flameMax
        % get detected points and roi points
        fx = X(i,:);
        fy = Y(i,:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        [means(i,:), vars(i,:)] = calcNumDistanceVarFrame(fy',fx',num);
    end
    time = toc;
    disp(['calcNumDistanceVarFrameAllFly ... done : ' num2str(time) 's']);
end
