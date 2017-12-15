% calculate nearest neighbor clustering
function [groups, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(cluster)
    frame = size(cluster,1);
    fn = size(cluster,2);
    groups = nan(frame,fn);
    groupCount = zeros(frame,1);
    biggestGroup = zeros(frame,1);
    biggestGroupFlyNum = zeros(frame,1);
    singleFlyNum = zeros(frame,1);
    upn = [];
    
    % sort out groups
    tic;
    for j=1:fn
        upn = [upn, j];
    end
    for i=1:frame
        % find group
        row = cluster(i,:);
        [a,i1,i2] = unique(row);
        za = zeros(1,fn);
        za(i1') = upn(1,1:length(i1));
        ga = row - za;
        gidx = find(ga>0);
        gidx = unique(row(gidx));
        groupCount(i) = length(gidx);
        for j=1:length(gidx)
            g2 = find(row==gidx(j));
            groups(i,g2) = j;
            gfn = length(g2);
            if biggestGroupFlyNum(i) < gfn
                biggestGroupFlyNum(i) = gfn;
                biggestGroup(i) = j;
            end
        end
        singleFlyNum(i) = length(find(isnan(groups(i,:))));
    end
    time = toc;
    disp(['calcClusterNNGroups ... done : ' num2str(time) 's']);
end
