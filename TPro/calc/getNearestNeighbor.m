%%
function list = getNearestNeighbor(trapezoids, hierarchy)
    MAX_DIST = 9999;
    sz = length(trapezoids);
    mat = zeros(sz,sz) + MAX_DIST;
    list = cell(floor(sz/2),1);
    x = zeros(floor(sz/2),1);
    y = zeros(floor(sz/2),1);

    % get distance matrix
    for i=1:(sz-1)
        for j=(i+1):sz
            dx = trapezoids{i}(1,5) - trapezoids{j}(1,5);
            dy = trapezoids{i}(1,6) - trapezoids{j}(1,6);
            mat(i,j) = sqrt(dx*dx + dy*dy);
        end
    end
    % get pairs
    for j = 1:floor(sz/2)
        mat_min = min(min(mat));
        if mat_min == MAX_DIST 
          break;
        end
        min_pair = find(mat==mat_min);
        p = rem(min_pair(1), sz);
        q = floor(min_pair(1) / sz) + 1;
        if trapezoids{p}(1,5) > trapezoids{q}(1,5)
            maxvalue = trapezoids{p}(1,5);
            slope = trapezoids{p}(1,6);
        else
            maxvalue = trapezoids{q}(1,5);
            slope = trapezoids{q}(1,6);
        end
        list{j} = [trapezoids{p}(1,1), p, q, mat(min_pair(1)), maxvalue, slope];
        x(j) = maxvalue;
        y(j) = slope;
        mat(p,:) = MAX_DIST;
        mat(q,:) = MAX_DIST;
        mat(:,p) = MAX_DIST;
        mat(:,q) = MAX_DIST;
    end
    if j < floor(sz/2)
        list(j:spikeNum) = [];
    end
%    T = cell2table(list);
%    writetable(T,['testout' num2str(hierarchy) '.csv'],'WriteVariableNames',false);
end
