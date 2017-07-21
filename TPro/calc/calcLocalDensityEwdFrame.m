% ----- calculate local density (frame) -----
function result = calcLocalDensityEwdFrame(x, y, r)
    xlen = length(x);
    ewd = zeros(xlen,1);
    ewd(:) = NaN;

    r2 = r*r;
    rev_pI_r = 1 / (pi * r2);
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
                    fr = exp(-(dx*dx + dy*dy)/r2);
                    local_dencity = local_dencity + fr;
                end
            end
            ewd(i) = rev_pI_r * local_dencity;
        end
    end
    result = nanmean(ewd);
end
