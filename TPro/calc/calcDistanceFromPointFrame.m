% ----- calculate distatnce from frame (frame) -----
function [means, distance] = calcDistanceFromPointFrame(x, y, px, py)
    xlen = length(x);
    distance = zeros(xlen,1);
    distance(:) = NaN;

    % calc local_dencity
    for i=1:xlen
        if isnan(x(i))
            distance(i) = NaN;
        else
            dx = x(i) - px;
            dy = y(i) - py;
            distance(i) = sqrt(dx*dx + dy*dy);
        end
    end
    means = nanmean(distance);
end
