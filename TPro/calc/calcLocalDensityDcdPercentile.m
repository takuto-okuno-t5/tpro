% calculate local density percentile (DCD)
function result = calcLocalDensityDcdPercentile(dcdvals, flyCounts, hnums, hedges, hvalues)
    dsize = length(dcdvals);
    result = zeros(dsize,1);
    tic;
    for i = 1:dsize
        fcnt = flyCounts(i);
        dcd = dcdvals(i) * 1000000;
        if fcnt < 2
            result(i) = 0;
        elseif fcnt > length(hvalues)
            result(i) = NaN;
        else
            hedge = hedges{fcnt};
            if dcd < hedge(1)
                result(i) = 0;
            elseif hedge(hnums(fcnt)+1) <= dcd
                result(i) = 1;
            else
                for j = 2:length(hedge)
                    if hedge(j-1) <= dcd && dcd < hedge(j)
                        result(i) = hvalues{fcnt}(j-1);
                        break;
                    end
                end
            end
        end
    end
    time = toc;
    if dsize > 1
        disp(['calcLocalDensityDcdPercentile ... done : ' num2str(time) 's']);
    end
end
