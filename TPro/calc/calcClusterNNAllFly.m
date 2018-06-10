% calculate nearest neighbor clustering
function [result, wgcount] = calcClusterNNAllFly(X, Y, roiMask, method, distance)
    flameMax = size(X, 1);
    flyNum = size(X, 2);
    
    result = zeros(flameMax,flyNum);
    wgcount = zeros(flameMax,1);
    tic;
    for i = 1:flameMax
        % get detected points and roi points
        fx = X(i,:);
        fy = Y(i,:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        [result(i,:), wgcount(i)] = calcClusterNNFrame(fx',fy',method, distance);
    end
    time = toc;
    disp(['calcClusterNNAllFly ... done : ' num2str(time) 's']);
end
