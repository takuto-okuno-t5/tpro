% calculate group area
function [area, groupAreas, groupCenterX, groupCenterY, groupOrient, groupPerimeter, groupFlyNum, groupFlyDir] = calcGroupAreaFrame(X, Y, dir, group, mmPerPixel)
    fn = length(X);
    maxGroup = max(group);
    groupAreas = nan(1,fn);
    groupCenterX = nan(1,fn);
    groupCenterY = nan(1,fn);
    groupOrient = nan(1,fn);
    groupPerimeter = nan(1,fn);
    groupFlyNum = nan(1,fn);
    groupFlyDir = nan(1,fn);

    for j=1:maxGroup
        idx = find(group==j);
        if isempty(idx)
            continue;
        end
        flyNum = length(idx);
        gx = double(X(idx))';
        gy = double(Y(idx))';
        if length(idx)==2
            cx = mean(gx);
            cy = mean(gy);
            perimeter = sqrt(diff(gx).^2 + diff(gy).^2) * mmPerPixel * 2;
            area = 0; % perimeter * 1.5; % 1.5mm
            angle = atan2(diff(gy),diff(gx)) / pi * 180;
        else
            dt = delaunayTriangulation(gx,gy);
            fe = freeBoundary(dt)';
            fe = fe(1,:);
            [ geom, iner, cpmo ] = polygeom(gx(fe),gy(fe));
            cx = geom(2);
            cy = geom(3);
            perimeter = geom(4) * mmPerPixel;
            area = geom(1) * (mmPerPixel^2);% + perimeter * 1.5; % 1.5mm
            angle = cpmo(2) / pi * 180;
        end
        groupAreas(j) = area;
        groupCenterX(j) = cx;
        groupCenterY(j) = cy;
        groupOrient(j) = angle;
        groupPerimeter(j) = perimeter;
        groupFlyNum(j) = flyNum;
        % calc each fly "head" direction from group centroid
        for k=1:length(gx)
            dir2 = mod(atan2(cy-gy(k), gx(k)-cx) / pi * 180 + 180 + 360, 360); %  flip +180
            fidx = idx(k);
            groupFlyDir(fidx) = mod(dir(fidx) - dir2 + 360, 360);
        end
    end

    area = nansum(groupAreas);
end
