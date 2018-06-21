%%
function target = mergeColumns(target, src)
    sj = size(target,1);
    sr = size(src,1);
    if sj > sr
        src((sr+1):sj,1) = NaN;
    elseif sj < sr
        target((sj+1):sr,1:end) = NaN;
    end
    target = [target, src];
end
