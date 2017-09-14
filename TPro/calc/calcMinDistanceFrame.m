% ----- calculate minimum distances (frame) -----
function [minDists, minIdxs] = calcMinDistanceFrame(x, y)
    xlen = length(x);
    minDists = zeros(xlen,1);
    minIdxs = zeros(xlen,1);
    minDists(:) = NaN;
    minIdxs(:) = NaN;

    % calc local_dencity
    pts = [x, y];
    dist = pdist(pts);
    dist1 = squareform(dist); %make square
    dist1(dist1==0) = 9999; %dummy
    for i=1:xlen
        if ~isnan(x(i))
            [md,k] = min(dist1(i,:));
            minDists(i) = md;
            minIdxs(i) = k;
        end
    end
end
