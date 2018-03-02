% calculate group area
function [areas, groupAreas, groupCenterX, groupCenterY, groupOrient, groupEcc, groupFlyNum] = calcGroupArea(X, Y, groups, roiMask, height)
    fn = size(X,2);
    frame = size(X,1);
    areas = zeros(frame,1);
    groupAreas = nan(frame,fn);
    groupCenterX = nan(frame,fn);
    groupCenterY = nan(frame,fn);
    groupOrient = nan(frame,fn);
    groupEcc = nan(frame,fn);
    groupFlyNum = nan(frame,fn);
    hBlobAnls = getVisionBlobAnalysis();

    tic;
    for i = 1:frame
        % get detected points and roi points
        fx = X(i,:);
        fy = Y(i,:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;
        group = groups(i,:);

        [areas(i), groupAreas(i,:), groupCenterX(i,:), groupCenterY(i,:), groupOrient(i,:), groupEcc(i,:), groupFlyNum(i,:)] = calcGroupAreaFrame(fy,fx,group,roiMask,height,hBlobAnls);
        release(hBlobAnls);

        if mod(i,100)==0
            rate = i*100 / frame;
            disp(['calcGroupArea : ' num2str(i) '(' num2str(rate) '%)']);
        end
    end
    time = toc;
    disp(['calcGroupArea ... done : ' num2str(time) 's']);
end
