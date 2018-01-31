%%
function [ keep_direction, keep_angle, keep_wings ] = PD_direction3(grayImage, blobAreas, blobCenterPoints, blobMajorAxis, blobOrient, blobEcc, params)
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
    wingImage = grayImage;
    wingImage(wingImage >= wingColorMax) = 255;
    wingImage(wingImage <= wingColorMin) = 255;
    wingImage = 255 - wingImage;
    wingImage(wingImage > 0) = 255;

    % blur and cut again
    wingImage = imgaussfilt(wingImage, 1);
    wingImage(wingImage <= wingColorMin) = 0;
    wingImage(wingImage > wingColorMin) = 255;

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
        [ colors ] = getCircleColors(wingImage, cx, cy, ph, majlen * radiusRate, range, step);
        colLen = length(colors);

        frontTotal = sum(colors(1:floor(colLen/4))) + sum(floor(colLen/4*3)+1:colLen);
        backTotal = sum(colors(floor(colLen/4)+1:floor(colLen/4*3)));
        if frontTotal > backTotal
            vec = -vec;
            angle = angle + 180;
            colors = [colors(floor(colLen/2)+1:colLen), colors(1:floor(colLen/2))];
        end
        keep_direction(:,i) = vec;

        % find right wing
        WING_COL_TH = 80;
        colors = movmean(colors, 3);
        rstart = floor(60/step) + 1;
        rend = floor(180/step) + 1; % 19 should be 180 degree
        wb = NaN; we = NaN;
        for j=rstart:rend
            if((colors(j) >= WING_COL_TH) && (colors(j+1) >= WING_COL_TH))
                if isnan(wb)
                    wb = j;
                end
                we = j+1;
            elseif((colors(j) < WING_COL_TH) && (colors(j+1) < WING_COL_TH)) && ~isnan(wb)
                break;
            end
        end
        if ~isnan(wb) && ~isnan(we)
            wangle = (wb+we)/2 * step;
            keep_wings(1,i) = angle + wangle;
        end

        % find left wing
        lstart = colLen + 2 - rstart;
        lend = colLen +2 - rend;
        wb = NaN; we = NaN;
        for j=lstart:-1:lend
            if((colors(j) >= WING_COL_TH) && (colors(j-1) >= WING_COL_TH))
                if isnan(wb)
                    wb = j;
                end
                we = j-1;
            elseif((colors(j) < WING_COL_TH) && (colors(j-1) < WING_COL_TH)) && ~isnan(wb)
                break;
            end
        end
        if ~isnan(wb) && ~isnan(we)
            wangle = (colLen - (wb+we)/2) * step;
            keep_wings(2,i) = angle - wangle;
        end        
    end
end
