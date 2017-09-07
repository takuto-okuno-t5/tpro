% ----- calculate local density (frame) -----
function [result, dwd] = calcLocalDensityDwdFrame(x, y, r, inverseSlope)
    xlen = length(x);
    dwd = zeros(xlen,1);
    dwd(:) = NaN;

    r2 = r*r;
    rev_pI_r = 1 / (pi * r2);
    % calc local_dencity
    for i=1:xlen
        local_dencity = 0;
        if isnan(x(i))
            dwd(i) = NaN;
        else
            for j=1:xlen
                if i~=j && ~isnan(x(j))
                    dx = x(i) - x(j);
                    dy = y(i) - y(j);
                    fr = 1 - sqrt(dx*dx + dy*dy) / inverseSlope;
                    if fr < 0, fr = 0; end
                    local_dencity = local_dencity + fr;
                end
            end
            dwd(i) = rev_pI_r * local_dencity;
        end
    end
    result = nanmean(dwd);
end
