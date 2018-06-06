%%
function [keep_data, groupIds] = trackingPoints(X, Y, reject_dist, duration, img_h, img_w)
    MAX_FLIES = readTproConfig('trackingFlyMax', 800); % maxmum number of flies
    RECURSION_LIMIT = readTproConfig('recursionLimit', 500); % maxmum number of recursion limit
    IGNORE_NAN_COUNT = readTproConfig('ignoreNaNCount', 20); % maxmum NaN count of fly (removed from tracking pair-wise)
    STRIKE_TRACK_TH = 3;
    KEEP_DATA_MAX = 4;
    frameNum = size(X,1);
    min_dist_threshold = reject_dist;

    % set recursion limit
    set(0,'RecursionLimit',RECURSION_LIMIT);

    u = 0; % no acceleration
    dt = 1;  % sampling rate
    noise_process = 1; % process noise
    noise_meas_x = .1;  % measurement noise in x direction
    noise_meas_y = .1;  % measurement noise in y direction
    Ez = [noise_meas_x 0; 0 noise_meas_y];
    Ex = [dt^4/4 0 dt^3/2 0; ...
        0 dt^4/4 0 dt^3/2; ...
        dt^3/2 0 dt^2 0; ...
        0 dt^3/2 0 dt^2].*noise_process^2; % Ex convert the process noise (stdv) into covariance matrix

    P = Ex; % estimate of initial position variance (covariance matrix)

    %% update equations in 2-D
    A = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1];
    B = [(dt^2/2); (dt^2/2); dt; dt];
    C = [1 0 0 0; 0 1 0 0];

    % init keep_data
    keep_data = cell(1,KEEP_DATA_MAX);  % x y vx vy
    for i = 1:KEEP_DATA_MAX
        keep_data{i} = nan(frameNum, MAX_FLIES, 'single');
    end

    tic % start timer
    disp('start trackingPoints');

    % initialize result variables
    Q_loc_meas = []; % location measure

    % initialize estimation variables for two dimensions
    Q = single([X(1,:); Y(1,:); zeros(1,length(X(1,:))); zeros(1,length(X(1,:)))]);
    Q_estimate = nan(4, MAX_FLIES, 'single');
    Q_estimate(:,1:size(Q,2)) = Q;  % initial location
    nancount = zeros(1, MAX_FLIES); % counting NaN each fly
    strk_trks = zeros(1, MAX_FLIES);  % counter of how many strikes a track has gotten
    flyNum = find(isnan(Q_estimate(1,:))==1,1) - 1; % initize number of track estimates
    groupIds = nan(size(X,1),size(X,2));

    for t = 1:frameNum
        % make the given detections matrix
        fx = X(t,:);
        fy = Y(t,:);
        fx(isnan(fx)) = [];
        fy(isnan(fy)) = [];
        Q_loc_meas = [fx' fy'];

        Q_estimate(3:4,:) = 0; % do not use velocity. set zero
        %for F = 1:flyNum
        %    Q_estimate(:,F) = A * Q_estimate(:,F) + B * u;
        %end

        %predict next covariance
        P = A * P* A' + Ex;
        % Kalman Gain
        K = P*C'*inv(C*P*C'+Ez);

        % assign the detections to estimated track positions
        %make the distance (cost) matrice between all pairs rows = tracks, coln =
        %detections
        if ~isempty(Q_loc_meas)
            nanidx = find(isnan(Q_estimate(1,1:flyNum)));
            nancount(nanidx) = nancount(nanidx) + 1;
            idx = find(nancount(1,1:flyNum) < IGNORE_NAN_COUNT);
            idxlen = length(idx);

            est_dist0 = pdist([Q_estimate(1:2,idx)'; Q_loc_meas]);
            est_dist0 = squareform(est_dist0); %make square
            est_dist1 = est_dist0(1:idxlen,idxlen+1:end) ; %limit to just the tracks to detection distances

            [asgnT, cost] = assignmentoptimal(est_dist1); %do the assignment with hungarian algo
            asgn = zeros(1,flyNum);
            invIdx = zeros(1,flyNum);
            if idxlen == 0
                asgn = asgnT;
            else
                for i=1:idxlen
                    fn = idx(i);
                    asgn(fn) = asgnT(i);
                    invIdx(fn) = i;
                end
            end

            %check 1: is the detection far from the observation? if so, reject it.
            rej = [];
            for F = 1:flyNum
                if ~isempty(asgn) && asgn(F) > 0  % if track F has pair asgn(F)
                    estF = invIdx(F);
                    rej(F) = est_dist1(estF,asgnT(estF)) < reject_dist;
                else
                    rej(F) = 0;
                end
            end
            if size(asgn,2) > 0 && ~isempty(rej)
                asgn = asgn.*rej;
            end

            %apply the assingment to the update
            k = 1;
            for F = 1:length(asgn)
                asgnF = asgn(F);
                if asgnF > 0  % found its match
                    Q_estimate(:,k) = Q_estimate(:,k) + K * (Q_loc_meas(asgnF,:)' - C * Q_estimate(:,k)); % same as asgn
                elseif asgnF == 0 % assignment for no assignment
                    y = round(Q_estimate(1,k));
                    x = round(Q_estimate(2,k));
                    if (y > img_h) || (x > img_w) || (y < 1) || (x < 1) || isnan(y) || isnan(x)
                        % if the predict is out of bound then delete
                        Q_estimate(:,k) = NaN;
                    else
                        estF = invIdx(k);
                        if estF > 0
                            [m,i] = min(est_dist1(estF,:));
                            % find non assigned detection point and nearest measurement within min_dist_threshold, then estimate next point
                            if isempty(find(asgn==i)) && m < min_dist_threshold
                                Q_estimate(:,k) = Q_estimate(:,k) + K * (Q_loc_meas(i,:)' - C * Q_estimate(:,k));
                            end
                        end
                    end
                end
                k = k + 1;
            end

        end % end of if ~isempty(Q_loc_meas)

        % update covariance estimation.
        P =  (eye(4)-K*C)*P;

        % keep data from Q_estimate
        keep_data{1}(t,1:flyNum) = Q_estimate(1,1:flyNum);    % x
        keep_data{2}(t,1:flyNum) = Q_estimate(2,1:flyNum);    % y
        keep_data{3}(t,1:flyNum) = Q_estimate(3,1:flyNum);    % vx
        keep_data{4}(t,1:flyNum) = Q_estimate(4,1:flyNum);    % vy

        if ~isempty(Q_loc_meas)
            %find the new detections. basically, anything that doesn't get assigned is a new tracking
            new_trk = Q_loc_meas(~ismember(1:size(Q_loc_meas,1),asgn),:)';
            if ~isempty(new_trk)
                Q_estimate(:,flyNum+1:flyNum+size(new_trk,2))=  [new_trk; zeros(2,size(new_trk,2))];
                flyNum = flyNum + size(new_trk,2);  % number of track estimates with new ones included
            end
        end  % end of if ~isempty(Q_loc_meas)

        %give a strike to any tracking that didn't get matched up to a detection
        if exist('asgn', 'var')
            aIdx = find(asgn>0);
            for j = 1:length(aIdx)
                k = aIdx(j);
                y = round(Q_estimate(1,k));
                x = round(Q_estimate(2,k));
                if (y > img_h) || (x > img_w) || (y < 1) || (x < 1) || isnan(y) || isnan(x)
                    % if the predict is out of bound then delete
                    asgn(k) = 0;
                end
            end

            % group Ids
            idx = find(asgn>0);
            for j = 1:length(idx)
                k = asgn(idx(j));
                groupIds(t,k) = idx(j);
            end
            % consecutive strike
            % if the strike is not consecutive then reset
            prev_strk_trks = strk_trks;
            no_trk_list = find(asgn==0);
            if ~isempty(no_trk_list)
                % check 1 or few frame detection. sometimes it increase fly
                % number too much. so find such noise and clean fly number.
                if ~isempty(find(flyNum==no_trk_list)) && strk_trks(flyNum) == 0
                    if t <= 10
                        chkst = 1;
                    else
                        chkst = t - 10;
                    end
                    keep_data_x_fly = keep_data{1}(chkst:t,flyNum);
                    len = length(find(~isnan(keep_data_x_fly)));
                    if len > 0 && len <= 3
                        % remove old 1 tracking frames
                        for j = 1:KEEP_DATA_MAX
                            keep_data{j}(chkst:t,flyNum) = NaN;
                        end
                        flyNum = flyNum - 1;
                    else
                        strk_trks(no_trk_list) = strk_trks(no_trk_list) + 1;
                    end
                else
                    strk_trks(no_trk_list) = strk_trks(no_trk_list) + 1;
                end
            end
            strk_trks(strk_trks == prev_strk_trks) = 0;

            %if a track has a strike greater than 3, delete the tracking. i.e.
            %make it nan first vid = 3
            bad_trks = find(strk_trks > STRIKE_TRACK_TH);
            if ~isempty(bad_trks)
                Q_estimate(:,bad_trks) = NaN;

                bad_trks = find(strk_trks ==(STRIKE_TRACK_TH+1));
                if ~isempty(bad_trks)
                    % remove old 3 tracking frames
                    for j = 1:KEEP_DATA_MAX
                        keep_data{j}((t-(STRIKE_TRACK_TH-1)):t,bad_trks) = NaN;
                    end
                end
            end
        end

        % show processing
        if mod(t,200) == 0
            rate = t / frameNum;
            disp(['processing : t : ' num2str(t) ' : ' num2str(100*rate) '%  fn : ' num2str(flyNum)]);
        end
    end

    % organize keep_data
    moveIdx = 1:flyNum;
    for j = 1:KEEP_DATA_MAX
        keep_data{j} = keep_data{j}(:,moveIdx);
    end
    % check duration
    for k = flyNum:-1:1
        keep_data_x_fly = keep_data{1}(:,k);
        len = length(find(~isnan(keep_data_x_fly)));
        if len < duration
            for j = 1:KEEP_DATA_MAX
                keep_data{j}(:,k) = [];
            end
            disp(['removed by duration : fn : ' num2str(k) ' (len=' num2str(len) ')']);
        end
    end

    % show end text
    time = toc;
    disp(['trackingPoints ... done!     t =',num2str(time),'s']);
end
