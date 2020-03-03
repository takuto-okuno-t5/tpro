%%
function courtship = beCourtShipFilter(x, y, lv, dir, rWingAngle, lWingAngle, rwav, lwav, waTh, wavTh, lvTh, distTh, angTh)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    be_rmat = zeros(frame_num,fly_num);
    be_lmat = zeros(frame_num,fly_num);
    courtship = zeros(frame_num,fly_num);

    rwav = abs(rwav);
    lwav = abs(lwav);
    be_rmat(rWingAngle >= waTh & (isnan(lwav) | lwav < wavTh*2) & lv <= lvTh) = 1;
    be_lmat(lWingAngle >= waTh & (isnan(rwav) | rwav < wavTh*2) & lv <= lvTh) = 1;
    be_mat = be_rmat | be_lmat;

    % check distance and angle
    for i = 2:(frame_num - 1)
        % find target within distance
        pts = [x(i,:)', y(i,:)'];
        dist = pdist(pts);
        dist1 = squareform(dist); %make square
        dist1(dist1==0) = 9999; %dummy

        for fn = 1:fly_num
            % check if courtship or not
            if be_mat(i,fn) ~= 1
                continue;
            end
            dist2 = dist1(fn,:);
            target = find(dist2 <= distTh);
            target2 = [];

            % find target within direction
            for j = 1:length(target)
                k = target(j);
                
                dx = x(i,k) - x(i,fn);
                dy = y(i,k) - y(i,fn);
                ddir = atan2d(dy,dx);
                diff1 = mod(abs(-ddir - dir(i,fn)), 360);
                if diff1 > 180
                    diff1 = 360 - diff1;
                end
                if diff1 < angTh
                    target2 = [target2, k];
                end
            end

            if ~isempty(target2)
                courtship(i,fn) = 1; % target2(1); % it is possible to set target id instead.
            end
        end
    end
end
