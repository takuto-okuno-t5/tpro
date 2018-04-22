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
    idx3 = find(dend(:,5)<=h2);
    dendIn = dend(idx3,:);
    for i=size(dendIn,1):-1:1
        if dendIn(i,4) == 2
            if dendIn(i,5) >= h1
                dendIn(i,6) = 1 - (dendIn(i,5) - h1) / (h2 - h1);
            else
                dendIn(i,6) = 1;
            end
        elseif dendIn(i,4) == 3
            dendIn(i,6) = 1;
        elseif dendIn(i,4) > 3
            if dendIn(i,2) > plen && dendIn(i,3) > plen
                if dendIn(i,5) >= h1
                    dendIn(i,6) = 1 + (dendIn(i,5) - h1) / (h2 - h1);
                else
                    dendIn(i,6) = 1;
                end
            else
                dendIn(i,6) = 1;
            end
        end
        dendIn = removeChildCount(dendIn, i, plen);
    end
    if ~isempty(dendIn)
        wcount = nansum(dendIn(:,6));
    end
end

function dendIn = removeChildCount(dendIn, i, plen)
    if i <= 0
        return;
    end
    c1 = dendIn(i,2);
    c2 = dendIn(i,3);
    if c1 > plen
        dendIn = removeChildCount(dendIn, c1-dendIn(1,1)+1, plen);
    end
    if c2 > plen
        dendIn = removeChildCount(dendIn, c2-dendIn(1,1)+1, plen);
    end
    dendIn(i,4) = 0;
end
