% ----- calculate chase behavior -----
function chase = beChaseFilter(x, y, lv, dir, updown, max_lv, min_lv, slope_th, beWalkGap, beDuration, min_dist, min_dir)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    chase = zeros(frame_num,fly_num);

   	walk = beWalkFilter(lv, updown, max_lv, min_lv, slope_th);
    walk = beGapFilter(walk, beWalkGap);
    walk = beDurationFilter(walk, beDuration); % duration filter: >= 5 frames

    % chase shold be WALK behavior
    for i = 2:(frame_num - 1)
        % find target within distance
        pts = [x(i,:)', y(i,:)'];
        dist = pdist(pts);
        dist1 = squareform(dist); %make square
        dist1(dist1==0) = 9999; %dummy

        for fn = 1:fly_num
            % check if walk or not
            if walk(i,fn) ~= 1
                continue;
            end
            dist2 = dist1(fn,:);
            target = find(dist2 <= min_dist);
            target2 = [];

            vx = x(i,fn) - x(i-1,fn);
            vy = y(i,fn) - y(i-1,fn);
            vdir = atan2d(vy,vx);

            % find target within direction
            for j = 1:length(target)
                k = target(j);
                % check if walk or not
                if walk(i,k) ~= 1
                    continue;
                end
                
                dx = x(i,k) - x(i,fn);
                dy = y(i,k) - y(i,fn);
                ddir = atan2d(dy,dx);

                vx2 = x(i,k) - x(i-1,k);
                vy2 = y(i,k) - y(i-1,k);
                vdir2 = atan2d(vy2,vx2);
                diff1 = abs(ddir - vdir);
                diff2 = abs(vdir2 - vdir);
                diff3 = abs(ddir - vdir2);
                if diff1 < min_dir && diff2 < min_dir && diff3 < min_dir
                    target2 = [target2, k];
                end
            end

            if length(target2) > 0
                chase(i,fn) = target2(1);
            end
        end
    end
end
