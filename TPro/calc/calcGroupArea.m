% calculate group area
function [areas, groupAreas, groupCenterX, groupCenterY, groupOrient, groupPerimeter, groupFlyNum] = calcGroupArea(X, Y, groups, mmPerPixel)
    fn = size(X,2);
    frame = size(X,1);
    areas = zeros(frame,1);
    groupAreas = nan(frame,fn);
    groupCenterX = nan(frame,fn);
    groupCenterY = nan(frame,fn);
    groupOrient = nan(frame,fn);
    groupPerimeter = nan(frame,fn);
    groupFlyNum = nan(frame,fn);

    tic;
    for i = 1:frame
        % get detected points and roi points
        fx = X(i,:);
        fy = Y(i,:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;
        group = groups(i,:);

        [areas(i), groupAreas(i,:), groupCenterX(i,:), groupCenterY(i,:), groupOrient(i,:), groupPerimeter(i,:), groupFlyNum(i,:)] = calcGroupAreaFrame(fy,fx,group,mmPerPixel);

        if mod(i,200)==0
            rate = i/frame * 100;
            disp(['calcGroupArea : ' num2str(i) '(' num2str(rate) '%)']);
        end
    end
    time = toc;
    disp(['calcGroupArea ... done : ' num2str(time) 's']);
end
