% calculate density map (Grid)
function gridCounts = calcDensityMapGrid(X, Y, img_w, img_h, width, height)
    flameMax = size(X, 1);
    gridCounts = zeros(ceil(img_h / height), ceil(img_w / width));
    tic;

    % count each frame point
    for i = 1:flameMax
        % get detected points and roi points
        fx = ceil(X(i,:));
        fy = ceil(Y(i,:));
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        counts = calcDensityMapGridFrame(fx, fy, img_w, img_h, width, height);
        gridCounts = gridCounts + counts;
    end
    time = toc;
    disp(['calcDensityMapGrid ... done : ' num2str(time) 's']);
end
