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
    wingColorTh = [90, 130, 130]; % circle wing color detection threshold

    %
    wingImage = applyWingFilter(step2Image, wingColorMin, wingColorMax);
    
    % label image (for mask blob)
    img2 = imgaussfilt(step2Image,2);
    img2(img2>=wingColorMax) = 255;
    img2 = 255 - img2;
    img2 = im2bw(img2, 0.01);
    labeledImage = uint8(bwlabel(img2));   % label the image

    % get labeled wingImage
    wingImage(wingImage>0) = 1;
    labelWingImage = single(wingImage .* labeledImage);
    labelWingImage(labelWingImage==0) = NaN;
    labeledImage(labeledImage==0) = NaN;

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

        % get around color (maybe labeled wing)
        width = 1 + range*2;
        area = (width * width);
        stepNum = floor(360/step);
        colmat = zeros(3*width, stepNum*width);
        colors = zeros(3,stepNum);
        for j=1:3
            box = getCircleColors(labelWingImage, cx, cy, ph, majlen * (radiusRate-0.1+(j-1)*0.1), range, step);
            colmat(width*(j-1)+1:width*j,:) = box;
        end
        % find most used labeled and fill it white, otherwise black. then
        % get mean of 3x3 box -> 1 avarage color
        label = mode(colmat(:));
        colmat(colmat~=label) = 0;
        colmat(colmat==label) = 255;
        for j=1:3
            for k=1:stepNum
                colBox1 = colmat(width*(j-1)+1:width*j, width*(k-1)+1:width*k);
                colors(j,k) = sum(sum(colBox1)) / area;
            end
        end
        colLen = size(colors,2);

        % to decrease touched blob error, most out circle colors are
        % subtracted by far side circle colors
        box = getCircleColors(labeledImage, cx, cy, ph, majlen * 0.95, range, step);
        box(box~=label) = 0;
        box(box==label) = 255;
        if sum(sum(box)) > 0
            farColors = zeros(1,stepNum);
            for k=1:stepNum
                colBox1 = box(1:width, width*(k-1)+1:width*k);
                farColors(1,k) = sum(sum(colBox1)) / area;
            end
            farColors0 = [0, farColors(1,2:stepNum-1), 0];
            farColors0(1,floor(colLen/2):floor(colLen/2)+1) = 0;
            colors = colors - [farColors0; farColors; farColors];
            colors(colors < 0) = 0;
        end

        % decide front & back side
        frontTotal = sum(sum(colors(:,1:floor(colLen/4)))) + sum(sum(colors(:,floor(colLen/4*3)+1:colLen)));
        backTotal = sum(sum(colors(:,floor(colLen/4)+1:floor(colLen/4*3))));
%idx = find(colors(2:3,:)>0);
%disp(['flynum=' num2str(i) ' : ' num2str(size(idx)) ' : ' num2str(sum(sum(colors(2:3,:)))) ' : ' num2str(blobEcc(i))]);
        if frontTotal > backTotal
            vec = -vec;
            angle = angle + 180;
            colors = [colors(:,floor(colLen/2)+1:colLen), colors(:,1:floor(colLen/2))];
        end
        keep_direction(:,i) = vec;

        % find right wing
        for k=1:3
            colors(k,:) = smooth(colors(k,:), 3, 'moving');
        end
        rstart(1) = floor(80/step) + 1;
        rstart(2) = floor(70/step) + 1;
        rstart(3) = floor(60/step) + 1;
        rend = floor(180/step) + 1; % 19 should be 180 degree
        wb = nan(1,3); we = nan(1,3);
        for k=1:3
            WING_COL_TH = wingColorTh(k);
            for j=rstart(k):rend
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
        for k=1:3
            WING_COL_TH = wingColorTh(k);
            for j=lstart(k):-1:lend
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
