%%
function [hhPx, haPx, hcPx, hhHist, haHist, hcHist, hx, hy, ax, ay] = calcPolarChartFrame(X, Y, dir, ecc, br, r, eccTh)
    fn = length(X);
    sqsize = ceil(r/20) * 20 * 2;
    ct = sqsize / 2;
    hhPx = zeros(sqsize, sqsize);
    haPx = zeros(sqsize, sqsize);
    hcPx = zeros(sqsize, sqsize);
    hhHist = zeros(1,36);
    haHist = zeros(1,36);
    hcHist = zeros(1,36);
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
    % calc head to head / ass distances
    pts = [hx', hy'; ax', ay'];
    dist = pdist(pts);
    dist1 = squareform(dist); % make square
    hhdist = dist1(1:fn,1:fn); % head to head
    hadist = dist1(1:fn,(fn+1):fn*2); % head to ass
    % calc head to centroid distances
    pts2 = [hx', hy'; X', Y'];
    dist2 = pdist(pts2);
    dist2 = squareform(dist2); % make square
    hcdist = dist1(1:fn,(fn+1):fn*2); % head to centroid

    % find head to head / ass
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
            hhPx(ct-py, ct+px) = hhPx(ct-py, ct+px) + 1;
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
            haPx(ct-py, ct+px) = haPx(ct-py, ct+px) + 1;
        end
    end
    % find head to centroid
    idx = find(hcdist<r & hcdist>0);
    for i=1:length(idx)
        cIdx = idx(i);
        [row, col] = ind2sub(size(hcdist), cIdx);
        dir2 = mod(atan2(hy(row)-ay(col), ax(col)-hx(row)) / pi * 180 + 360, 360);
        dir3 = dir(row);
        dir4 = mod(dir2 - dir3 + 360, 360);
        dir4r = 1 + floor(dir4 / 10);
        dist4 = hcdist(cIdx);
        px = round(dist4 * cosd(dir4+90));
        py = round(dist4 * sind(dir4+90));
        hcHist(dir4r) = hcHist(dir4r) + 1;
        hcPx(ct-py, ct+px) = hcPx(ct-py, ct+px) + 1;
    end
end
