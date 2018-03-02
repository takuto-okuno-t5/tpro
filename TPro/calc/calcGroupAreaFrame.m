% calculate group area
function [area, groupAreas, groupCenterX, groupCenterY, groupOrient, groupEcc, groupFlyNum] = calcGroupAreaFrame(X, Y, group, roiMask, height, hBlobAnls)
    fn = length(X);
    img_h = size(roiMask,1);
    img_w = size(roiMask,2);
    [columnsInImage, rowsInImage] = meshgrid(1:img_h, 1:img_w);
    maxGroup = max(group);
    frameImage = zeros(img_h, img_w);
    groupAreas = nan(1,fn);
    groupCenterX = nan(1,fn);
    groupCenterY = nan(1,fn);
    groupOrient = nan(1,fn);
    groupEcc = nan(1,fn);
    groupFlyNum = nan(1,fn);

    for j=1:maxGroup
        img = zeros(img_h, img_w);
        idx = find(group==j);
        if isempty(idx)
            continue;
        end
        flyNum = length(idx);
        for i=1:flyNum
            circlePixels = (rowsInImage - X(idx(i))).^2 + (columnsInImage - Y(idx(i))).^2 <= height.^2;
            img = img | circlePixels';
        end
        
        [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(hBlobAnls, img);
        groupAreas(j) = AREA;
        groupCenterX(j) = CENTROID(1);
        groupCenterY(j) = CENTROID(2);
        groupOrient(j) = ORIENTATION;
        groupEcc(j) = ECCENTRICITY;
        groupFlyNum(j) = flyNum;

        frameImage = frameImage | img;
    end

    area = length(find(frameImage>0));
end
