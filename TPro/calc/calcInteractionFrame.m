%%
function [hhInt, haInt, hbInt, hx, hy, ax, ay] = calcInteractionFrame(X, Y, dir, ecc, br, ir, angleTh, eccTh)
    fn = length(X);
    hhInt = nan(1,fn);
    haInt = nan(1,fn);
    hbInt = nan(1,fn);
    hx = nan(1,fn);
    hy = nan(1,fn);
    ax = nan(1,fn);
    ay = nan(1,fn);
    for i=1:fn
        th = (-dir(i))/ 180 * pi;
        hx(i) = X(i) + br * cos(th);
        hy(i) = Y(i) + br * sin(th);
        th = (-dir(i)+180)/ 180 * pi;
        ax(i) = X(i) + br * cos(th);
        ay(i) = Y(i) + br * sin(th);
    end
    % find head to head
    pts = [hx', hy'; ax', ay'; X', Y'];
    dist = pdist(pts);
    dist1 = squareform(dist); %make square
    hhdist = dist1(1:fn,1:fn); 
    idx = find(hhdist<ir & hhdist>0);
    for i=1:length(idx)
        [row, col] = ind2sub(size(hhdist), idx(i));
        dir2 = mod(atan2(hy(row)-hy(col), hx(col)-hx(row)) / pi * 180 + 360, 360);
        dir3 = dir(row);
        ecc2 = ecc(row);
        if abs(dir2-dir3) <= angleTh && ecc2 >= eccTh
            hhInt(1,row) = col;
        end
    end
    % find head to ass
    hadist = dist1(1:fn,(fn+1):fn*2); 
    idx = find(hadist<ir & hadist>0);
    for i=1:length(idx)
        [row, col] = ind2sub(size(hadist), idx(i));
        dir2 = mod(atan2(hy(row)-ay(col), ax(col)-hx(row)) / pi * 180 + 360, 360);
        dir3 = dir(row);
        ecc2 = ecc(row);
        if abs(dir2-dir3) <= angleTh && ecc2 >= eccTh
            haInt(1,row) = col;
        end
    end
    % find head to body
    hbdist = dist1(1:fn,(fn*2+1):end); 
    idx = find(hbdist<ir & hbdist>0);
    for i=1:length(idx)
        [row, col] = ind2sub(size(hbdist), idx(i));
        if row ~= col
            dir2 = mod(atan2(hy(row)-Y(col), ax(col)-X(row)) / pi * 180 + 360, 360);
            dir3 = dir(row);
            ecc2 = ecc(row);
            if abs(dir2-dir3) <= angleTh && ecc2 >= eccTh
                hbInt(1,row) = col;
            end
        end
    end
end
