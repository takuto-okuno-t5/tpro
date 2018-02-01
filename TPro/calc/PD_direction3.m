%%
function [ keep_direction, keep_angle, keep_wings ] = PD_direction3(step2Image, blobAreas, blobCenterPoints, blobMajorAxis, blobOrient, blobEcc, params)
    % init
    areaNumber = size(blobAreas, 1);
    keep_direction = nan(2, areaNumber, 'single'); % allocate memory
    keep_angle = nan(1, areaNumber, 'single'); % allocate memory
    keep_wings = nan(2, areaNumber, 'single'); % allocate memory

    % constant params
    wingColorMin = params{1};
    wingColorMax = params{2};
    radiusRate = params{3};
    range = params{4};
    step = params{5};
    ignoreEccTh = params{6};

    %
    wingImage = applyWingFilter(step2Image, wingColorMin, wingColorMax);

    % find direction for every blobs
    for i = 1:areaNumber
        % pre calculation
        angle = -blobOrient(i)*180 / pi;
        cx = blobCenterPoints(i,1);
        cy = blobCenterPoints(i,2);
        ph = -blobOrient(i);
        cosph =  cos(ph);
        sinph =  sin(ph);
        majlen = blobMajorAxis(i);
        vec = [majlen*cosph*0.5; majlen*sinph*0.5];

        keep_angle(:,i) = angle;

        % check ecc - ignore at jumping / climbing
        if blobEcc(i) < ignoreEccTh
            continue;
        end

        % get around color (maybe wing) colors
        colors(1,:) = getCircleColors(wingImage, cx, cy, ph, majlen * (radiusRate-0.1), range, step);
        colors(2,:) = getCircleColors(wingImage, cx, cy, ph, majlen * radiusRate, range, step);
        colors(3,:) = getCircleColors(wingImage, cx, cy, ph, majlen * (radiusRate+0.1), range, step);
        colLen = size(colors,2);

        frontTotal = sum(sum(colors(:,1:floor(colLen/4)))) + sum(sum(colors(:,floor(colLen/4*3)+1:colLen)));
        backTotal = sum(sum(colors(:,floor(colLen/4)+1:floor(colLen/4*3))));
        if frontTotal > backTotal
            vec = -vec;
            angle = angle + 180;
            colors = [colors(:,floor(colLen/2)+1:colLen), colors(:,1:floor(colLen/2))];
        end
        keep_direction(:,i) = vec;

        % find right wing
        WING_COL_TH = 80;
        colors = movmean(colors, 3);
        rstart = floor(60/step) + 1;
        rend = floor(180/step) + 1; % 19 should be 180 degree
        wb = nan(1,3); we = nan(1,3);
        for k=1:size(colors,1)
            for j=rstart:rend
                if((colors(k,j) >= WING_COL_TH) && (colors(k,j+1) >= WING_COL_TH))
                    if isnan(wb(k))
                        wb(k) = j;
                    end
                    we(k) = j+1;
                elseif((colors(k,j) < WING_COL_TH) && (colors(k,j+1) < WING_COL_TH)) && ~isnan(wb(k))
                    break;
                end
            end
        end
        wangle = ((wb+we)./2 - 1) .* step;
        keep_wings(1,i) = angle + nanmean(wangle);

        % find left wing
        lstart = colLen + 2 - rstart;
        lend = colLen +2 - rend;
        wb = nan(1,3); we = nan(1,3);
        for k=1:size(colors,1)
            for j=lstart:-1:lend
                if((colors(k,j) >= WING_COL_TH) && (colors(k,j-1) >= WING_COL_TH))
                    if isnan(wb(k))
                        wb(k) = j;
                    end
                    we(k) = j-1;
                elseif((colors(k,j) < WING_COL_TH) && (colors(k,j-1) < WING_COL_TH)) && ~isnan(wb(k))
                    break;
                end
            end
        end
        wangle = (colLen - ((wb+we)./2 - 1)) .* step;
        keep_wings(2,i) = angle - nanmean(wangle);
    end
end
