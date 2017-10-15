% ----- calculate local density (frame) -----
function result = calcLocalDensitySsiFrame(x, y, binSize, binNum)
    xlen = length(x);
    mds = zeros(xlen,1);
    mds(:) = NaN;
    result = zeros(binNum,1);

    % calc local_dencity
    pts = [x, y];
    dist = pdist(pts);
    dist1 = squareform(dist); %make square
    dist1(dist1==0) = 9999; %dummy
    for i=1:xlen
        if isnan(x(i))
            mds(i) = NaN;
        else
            [md,k] = min(dist1(i,:));
            mds(i) = md;
        end
    end
    minbin = 0;
    maxbin = binSize;
    for i=1:binNum
        result(i) = length(find(minbin <= mds & mds < maxbin));
        minbin = maxbin;
        maxbin = maxbin + binSize;
    end
end
