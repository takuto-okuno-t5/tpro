%%
function [headAngle, keep_data] = fixHeadAndWingAngle(v, ecc, headAngleIn, keep_data, vTh, eccTh, fps, startFrame)
    % init
    headAngle = headAngleIn;
    rWingAngle = keep_data{9};
    lWingAngle = keep_data{10};
    frame_num = size(headAngle, 1);
    fly_num = size(headAngle, 2);
    range = int32(fps * 5); % maximus duration of angle flip (5 sec)

    % get jumping and climing peak to reset head angle
    v(v>=vTh) = 0;
    v(v~=0) = 1;
    ecc(ecc>eccTh) = 1;
    ecc(ecc~=1) = 0;
    mask = v & ecc;
    % after jumping or climing, sometime head angle flip happens.
    % so expand 3 frames of mask to remove such kind of flips
    mask = mask & circshift(mask,1,1) & circshift(mask,2,1) & circshift(mask,3,1);

    % find flips
    haShift = circshift(headAngle,1,1);
    rwShift = circshift(rWingAngle,1,1); rwShift(1,:) = 0;
    lwShift = circshift(lWingAngle,1,1); lwShift(1,:) = 0;
    haflip = mod((haShift+360) - headAngle, 360);
    rwflip = mod((rwShift+360) - rWingAngle, 360);
    lwflip = mod((lwShift+360) - lWingAngle, 360);
    haflip(haflip < 135 | haflip > 225) = 0;
    rwflip(rwflip < 135 | rwflip > 225) = 0;
    lwflip(lwflip < 135 | lwflip > 225) = 0;
    haflip(haflip>0) = 1;
    rwflip(rwflip>0) = 1;
    lwflip(lwflip>0) = 1;
    haflip = haflip .* mask;
    rwflip = rwflip .* mask;
    lwflip = lwflip .* mask;
    for i=1:fly_num
        st = 1;
        haFlipFly = haflip(:,i);
        while true
            if st >= frame_num
                break; % out of frame
            end
            % find first flip
            flipIdx = find(haFlipFly(st:end)>0, 1, 'first');
            if isempty(flipIdx)
                break; % no more flip. finish this fly.
            end
            flipIdx = st - 1 + flipIdx;
            endIdx = (flipIdx+range);
            if length(haFlipFly) < endIdx
                endIdx = length(haFlipFly);
            end
            % find next flip
            flipEndIdx = find(haFlipFly((flipIdx+1):endIdx)>0, 1, 'first');
            if isempty(flipEndIdx)
                % not found a flip in the range. find next flip
                st = flipIdx+range+1;
                continue;
            end
            flipEndIdx = flipIdx + flipEndIdx;
            nanIdx = find(isnan(haFlipFly(flipIdx:flipEndIdx)), 1);
            if ~isempty(nanIdx)
                st = flipEndIdx+1;
                continue;
            end
            % flip head direction and wing right <-> left
            flipRange = flipIdx:(flipEndIdx-1);
            headAngle(flipRange,i) = mod(headAngle(flipRange,i)+180,360);
            keep_data{5}(flipRange,i) = -keep_data{5}(flipRange,i);
            keep_data{6}(flipRange,i) = -keep_data{6}(flipRange,i);
            if rwflip(flipIdx) && lwflip(flipIdx)
                rWingAngle(flipRange,i) = mod(rWingAngle(flipRange,i)+180,360);
                lWingAngle(flipRange,i) = mod(lWingAngle(flipRange,i)+180,360);
            else
                tmp = rWingAngle(flipRange,i);
                rWingAngle(flipRange,i) = lWingAngle(flipRange,i);
                lWingAngle(flipRange,i) = tmp;
            end
            disp(['flip head & wing : fly=' num2str(i) ' frame=' num2str(startFrame+flipIdx-1) ' to ' num2str(startFrame+flipEndIdx-2)]);
            st = flipEndIdx+1;
        end
    end
    % remove wing flip noise
    rwflip = 180 - mod(headAngle + 360 - angleAxis2def(rWingAngle), 360);
    lwflip = mod(headAngle + 360 - angleAxis2def(lWingAngle), 360) - 180;
    rwflip(rwflip < 160 & rwflip > -30) = 0;
    lwflip(lwflip < 160 & lwflip > -30) = 0;
    rwflip(rwflip ~= 0) = 1;
    lwflip(lwflip ~= 0) = 1;
    rWingAngle = mod(rWingAngle + rwflip .* 180, 360);
    lWingAngle = mod(lWingAngle + lwflip .* 180, 360);
    keep_data{9} = rWingAngle;
    keep_data{10} = lWingAngle;
end

