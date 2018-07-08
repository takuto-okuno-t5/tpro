% calculate group area
function [area, groupAreas, groupCenterX, groupCenterY, groupOrient, groupPerimeter, groupEcc, groupFlyNum, groupFlyDir] = calcGroupAreaFrame(X, Y, dir, group, mmPerPixel)
    fn = length(X);
    maxGroup = max(group);
    groupAreas = nan(1,fn);
    groupCenterX = nan(1,fn);
    groupCenterY = nan(1,fn);
    groupOrient = nan(1,fn);
    groupPerimeter = nan(1,fn);
    groupEcc = nan(1,fn);
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
            ecc = 1;
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
            % getting long & short axis
            gx2 = gx - cx;
            gy2 = gy - cy;
            gx3 = gx2 .* cosd(-angle) - gy2 .* sind(-angle);
            gy3 = gx2 .* sind(-angle) + gy2 .* cosd(-angle);
            gx3long = max(gx3) - min(gx3);
            gy3long = max(gy3) - min(gy3);
            a = max(gx3long, gy3long);
            b = min(gx3long, gy3long);
            ecc = sqrt(1-(b*b)/(a*a));
        end
        groupAreas(j) = area;
        groupCenterX(j) = cx;
        groupCenterY(j) = cy;
        groupOrient(j) = angle;
        groupPerimeter(j) = perimeter;
        groupEcc(j) = ecc;
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
