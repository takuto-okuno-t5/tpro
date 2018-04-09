%%
function groups = matchingGroupAndFly(nn_groups, group_keep_data, groupCenterX, groupCenterY)
    frameNum = size(group_keep_data{1},1);
    groups = nan(frameNum, size(nn_groups,2));
    for t=1:frameNum
        group = nn_groups(t,:);
        maxGroup = max(group);
        if isnan(maxGroup)
            continue;
        end
        grcenter = [groupCenterX(t,1:maxGroup)' groupCenterY(t,1:maxGroup)'];
        keepcenter = [group_keep_data{1}(t,:)' group_keep_data{2}(t,:)'];
        idxlen = size(grcenter,1);
        est_dist0 = pdist([grcenter; keepcenter]);
        est_dist0 = squareform(est_dist0); %make square
        est_dist1 = est_dist0(1:idxlen,idxlen+1:end) ; %limit to just the tracks to detection distances
        for j=1:maxGroup
            gidx = find(est_dist1(j,:) < 10);
            if ~isempty(gidx)
                idx = find(group==j);
                groups(t,idx) = gidx(1);
            end
        end
        % show processing
        if mod(t,200) == 0
            rate = t / frameNum;
            disp(['match group and fly : t : ' num2str(t) ' : ' num2str(100*rate) '%']);
        end
    end
end
