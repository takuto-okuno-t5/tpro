% calculate distance from point
function [means, result] = calcDistanceFromPointAllFly(X, Y, px, py)
    flameMax = size(X, 1);
    flyNum = size(X, 2);
    
    means = zeros(flameMax,1);
    result = zeros(flameMax,flyNum);
    tic;
    for i = 1:flameMax
        % get detected points
        fx = X(i,:);
        fy = Y(i,:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        [means(i), result(i,:)] = calcDistanceFromPointFrame(fx,fy,px,py);
    end
    time = toc;
    disp(['calcDistanceFromPointAllFly ... done : ' num2str(time) 's']);
end
