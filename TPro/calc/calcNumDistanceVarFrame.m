% ----- calculate top num of distances and variance (frame) -----
function [means, vars] = calcNumDistanceVarFrame(x, y, num)
    xlen = length(x);
    means = zeros(xlen,1);
    vars = zeros(xlen,1);
    means(:) = NaN;
    vars(:) = NaN;
    mins = zeros(num,1);

    % calc local_dencity
    pts = [x, y];
    dist = pdist(pts);
    dist1 = squareform(dist); %make square
    dist1(dist1==0) = 9999; %dummy
    for i=1:xlen
        if ~isnan(x(i))
            for j=1:num
                [mins(j),k] = min(dist1(i,:));
                dist1(i,k) = 9999;
            end
            means(i) = mean(mins);
            vars(i) = var(mins,1);
        end
    end
end
