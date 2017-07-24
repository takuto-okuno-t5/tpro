% ----- calculate local density (frame) -----
function result = calcLocalDensityHwmdFrame(x, y)
    xlen = length(x);
    ewd = zeros(xlen,1);
    ewd(:) = NaN;

    % calc local_dencity
    for i=1:xlen
        local_dencity = 0;
        if isnan(x(i))
            ewd(i) = NaN;
        else
            for j=1:xlen
                if i~=j && ~isnan(x(j))
                    dx = x(i) - x(j);
                    dy = y(i) - y(j);
                    fr = 1/sqrt(dx*dx + dy*dy);
                    local_dencity = local_dencity + fr;
                end
            end
            ewd(i) = local_dencity;
        end
    end
    result = nanmean(ewd);
end
