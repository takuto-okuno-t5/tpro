% ----- calculate local density (frame) -----
function [result, dwd] = calcLocalDensityDwdFrame(x, y, r, cnR)
    xlen = length(x);
    dwd = zeros(xlen,1);
    dwd(:) = NaN;

    r2 = r*r;
    rev_pI_r = 1 / (pi * r2);
    slope = -1 / (r - cnR);
    % calc local_dencity
    for i=1:xlen
        local_dencity = 0;
        if isnan(x(i))
            dwd(i) = NaN;
        else
            for j=1:xlen
                if ~isnan(x(j))
                    dx = x(i) - x(j);
                    dy = y(i) - y(j);
                    distance = sqrt(dx*dx + dy*dy) - cnR;
                    fr = 1 + distance * slope;
                    if fr < 0, fr = 0; end
                    if fr > 1, fr = 1; end
                    local_dencity = local_dencity + fr;
                end
            end
            dwd(i) = rev_pI_r * local_dencity;
        end
    end
    result = nanmean(dwd);
end
