% ----- calculate local density (frame) -----
function result = calcLocalDensityMdFrame(x, y)
    xlen = length(x);
    mds = zeros(xlen,1);
    mds(:) = NaN;

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
            mds(i) = 1 / md;
        end
    end
    result = nanmean(mds);
end
