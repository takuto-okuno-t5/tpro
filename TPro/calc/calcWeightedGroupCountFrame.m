% calculate weighted group count
function wcount = calcWeightedGroupCountFrame(tree, plen, height)
    wcount = 0;
    if isempty(tree) || plen <= 0
        return;
    end
    dlen = size(tree,1);
    dend = nan(plen*2,6);
    idx = plen + 1;
    for i=1:dlen
        t1 = tree(i,1);
        t2 = tree(i,2);
        dend(idx,1) = idx;
        dend(idx,2) = t1;
        dend(idx,3) = t2;
        dend(idx,5) = tree(i,3);
        if t1 <= plen
            dend(t1,4) = 1;
            t1cnt = 1;
        else
            t1cnt = dend(t1,4);
        end
        if t2 <= plen
            dend(t2,4) = 1;
            t2cnt = 1;
        else
            t2cnt = dend(t2,4);
        end
        dend(idx,4) = t1cnt + t2cnt;
        idx = idx + 1;
    end
    hwidth = height / 2;
    h1 = height - hwidth;
    h2 = height + hwidth;
    h3 = height - hwidth / 2;
    idx3 = find(dend(:,5)<=h2);
    dendIn = dend(idx3,:);
    for i=1:size(dendIn,1)
        c1 = dendIn(i,2);
        c2 = dendIn(i,3);
        idx1 = dendIn(1,1);
        if dendIn(i,4) == 2
            if dendIn(i,5) < height  % h3
                dendIn(i,6) = 1;
%            elseif dendIn(i,5) < height
%                rate = (dendIn(i,5) - h3) / (height - h3);
%                dendIn(i,6) = 1 - rate;
            else
                dendIn(i,6) = 0;
            end
        elseif dendIn(i,4) == 3
            if dendIn(i,5) < h1
                dendIn(i,6) = 1;
            else
                if c1 > plen
                    dendIn(i,6) = dendIn(c1-idx1+1, 6);
                elseif c2 > plen
                    dendIn(i,6) = dendIn(c2-idx1+1, 6);
                end
            end
        elseif dendIn(i,4) > 3
            if c1 > plen && c2 > plen
                rate = (dendIn(i,5) - h1) / (h2 - h1);
                halfScore = (1 + rate) / 2;
                dendIn(i,6) = dendIn(c1-idx1+1, 6)*halfScore + dendIn(c2-idx1+1, 6)*halfScore;
            elseif c1 > plen
                dendIn(i,6) = dendIn(c1-idx1+1, 6);
            elseif c2 > plen
                dendIn(i,6) = dendIn(c2-idx1+1, 6);
            end
        end
        if c1 > plen
            dendIn(c1-idx1+1, 6) = 0;
        end
        if c2 > plen
            dendIn(c2-idx1+1, 6) = 0;
        end
    end
    if ~isempty(dendIn)
        wcount = nansum(dendIn(:,6));
    end
end

