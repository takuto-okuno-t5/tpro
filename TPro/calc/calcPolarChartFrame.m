%%
function [hhPx, haPx, hhHist, haHist, hx, hy, ax, ay] = calcPolarChartFrame(X, Y, dir, ecc, br, r, eccTh)
    fn = length(X);
    hhPx = zeros(200,200);
    haPx = zeros(200,200);
    hhHist = zeros(1,36);
    haHist = zeros(1,36);
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
    pts = [hx', hy'; ax', ay'];
    dist = pdist(pts);
    dist1 = squareform(dist); %make square
    hhdist = dist1(1:fn,1:fn); % head to head
    hadist = dist1(1:fn,(fn+1):fn*2); % head to ass
    idx = find(hhdist<r & hhdist>0);
    for i=1:length(idx)
        cIdx = idx(i);
        [row, col] = ind2sub(size(hhdist), cIdx);
        dir2 = mod(atan2(hy(row)-hy(col), hx(col)-hx(row)) / pi * 180 + 360, 360);
        dir3 = dir(row);
        ecc2 = ecc(row);
        if ecc2 >= eccTh && hhdist(cIdx) < hadist(cIdx)
            dir4 = mod(dir2 - dir3 + 360, 360);
            dir4r = 1 + floor(dir4 / 10);
            dist4 = hhdist(cIdx);
            px = round(dist4 * cosd(dir4+90));
            py = round(dist4 * sind(dir4+90));
            hhHist(dir4r) = hhHist(dir4r) + 1;
            hhPx(100-py, 100+px) = hhPx(100-py, 100+px) + 1;
        end
    end
    % find head to ass
    idx = find(hadist<r & hadist>0);
    for i=1:length(idx)
        cIdx = idx(i);
        [row, col] = ind2sub(size(hadist), cIdx);
        dir2 = mod(atan2(hy(row)-ay(col), ax(col)-hx(row)) / pi * 180 + 360, 360);
        dir3 = dir(row);
        ecc2 = ecc(row);
        if ecc2 >= eccTh && hadist(cIdx) < hhdist(cIdx)
            dir4 = mod(dir2 - dir3 + 360, 360);
            dir4r = 1 + floor(dir4 / 10);
            dist4 = hadist(cIdx);
            px = round(dist4 * cosd(dir4+90));
            py = round(dist4 * sind(dir4+90));
            haHist(dir4r) = haHist(dir4r) + 1;
            haPx(100-py, 100+px) = haPx(100-py, 100+px) + 1;
        end
    end
end
