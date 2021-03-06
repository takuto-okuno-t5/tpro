%%
function [ keep_direction, keep_angle, keep_wings ] = PD_direction3(step2Image, blobAreas, blobCenterPoints, blobMajorAxis, blobOrient, blobEcc, params)
    % init
    areaNumber = size(blobAreas, 1);
    keep_direction = nan(2, areaNumber, 'single'); % allocate memory
    keep_angle = nan(1, areaNumber, 'single'); % allocate memory
    keep_wings = nan(4, areaNumber, 'single'); % allocate memory

    % constant params
    wingColorMin = params{1};
    wingColorMax = params{2};
    radiusRate = params{3};
    range = params{4};
    step = params{5};
    ignoreEccTh = params{6};

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
        colors = getAroundColorMat(labelWingImage, labeledImage, cx, cy, ph, majlen, range, step, radiusRate);
        stepNum = size(colors,2);

        % decide front & back side
        frontTotal = sum(sum(colors(:,1:floor(stepNum/4)))) + sum(sum(colors(:,floor(stepNum/4*3)+1:stepNum)));
        backTotal = sum(sum(colors(:,floor(stepNum/4)+1:floor(stepNum/4*3))));
%idx = find(colors(2:3,:)>0);
%disp(['flynum=' num2str(i) ' : ' num2str(size(idx)) ' : ' num2str(sum(sum(colors(2:3,:)))) ' : ' num2str(blobEcc(i))]);
        if frontTotal > backTotal
            vec = -vec;
            angle = angle + 180;
            colors = [colors(:,floor(stepNum/2)+1:stepNum), colors(:,1:floor(stepNum/2))];
        end
        keep_direction(:,i) = vec;

        % find wings both head & tail side (head angle might be flipped by tracking)
        keep_wings(1:2,i) = findWingAngle(angle, colors, step);

        colors2(:,19:36) = colors(:,1:18);
        colors2(:,1:18) = colors(:,19:36);
        angle = mod(angle + 180, 360);
        keep_wings(3:4,i) = findWingAngle(angle, colors2, step);
    end
end
