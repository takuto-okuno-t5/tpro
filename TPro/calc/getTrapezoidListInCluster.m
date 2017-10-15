%%
function t2 = getTrapezoidListInCluster(handles, t, clustered, type1, type2, type3, indexes)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    spikeNum = 0;
    for j = 1:size(indexes,2)
        spikeNum = spikeNum + sum(clustered==indexes(j));
    end
    
    t2 = cell(spikeNum,1);
    k = 1;
    for j = 1:size(clustered,1)
        c = clustered(j);
        if sum(c==indexes) > 0
            t5 = t{j}(1,:);
            fn = t5(1);
            fstart = t5(2);
            fend = t5(3);
            % clustering value 1
            switch type1
            case 'velocity'
                vxy = sharedInst.vxy(fstart:fend, fn);
                f2 = max(vxy);
                f1 = min(vxy);
                v1 = f2;
            end
            % clustering value 2
            switch type2
            case 'acceralation'
                v2 = abs((f2 - f1) / (fend - fstart));
            case 'circularity'
                v2 = (1 - min(sharedInst.ecc(fstart:fend, fn))) * 100;
            case 'angle_velocity'
                v2 = max(sharedInst.av(fstart:fend, fn));
            case 'sideways'
                v2 = max(sharedInst.sideways(fstart:fend, fn)) * 100;
            case 'sideways_velocity'
                v2 = max(sharedInst.sidewaysVelocity(fstart:fend, fn));
            end
            % clustering value 3
            v3 = 0;

            t2{k} = [fn fstart fend t5(4) v1 v2 v3];
            k = k + 1;
        end
    end    
end
