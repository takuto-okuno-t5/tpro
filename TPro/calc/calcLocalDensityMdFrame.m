% ----- calculate local density (frame) -----
function result = calcLocalDensityMdFrame(x, y)
    xlen = length(x);
    ewd = zeros(xlen,1);
    ewd(:) = NaN;

    % calc local_dencity
    pts = [x, y];
    dist = pdist(pts);
    dist1 = squareform(dist); %make square
    dist1(dist1==0) = 9999; %dummy
    for i=1:xlen
        if isnan(x(i))
            ewd(i) = NaN;
        else
            [md,i] = min(dist1(i,:));
            ewd(i) = 1 / md;
        end
    end
    result = nanmean(ewd);
end
