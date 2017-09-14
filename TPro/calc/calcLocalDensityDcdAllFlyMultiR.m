% calculate local density (DCD)
function result = calcLocalDensityDcdAllFlyMultiR(X, Y, roiMask, multiR, cnR)
    flameMax = size(X, 1);
    flyNum = size(X, 2);
    
    rlen = length(multiR);
    result = zeros(flameMax,flyNum,rlen);
    tic;
    for j = 1:rlen
        r = multiR(j);
        for i = 1:flameMax
            % get detected points and roi points
            fx = X(i,:);
            fy = Y(i,:);
            fx(fx==0) = NaN;
            fy(fy==0) = NaN;

            [m, frResult] = calcLocalDensityDcdFrame(fy,fx,r,cnR);
            [result(i,:,j)] = frResult;
        end
        maxScore = max(max(result(:,:,j)));
        result(:,:,j) = result(:,:,j) / maxScore;
    end
    time = toc;
    disp(['calcLocalDensityDcdAllFly ... done : ' num2str(time) 's']);
end
