%%
function [ keep_direction, keep_angle ] = PD_direction3(grayImage, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient)
    % init
    areaNumber = size(blobAreas, 1);
    keep_direction = zeros(2, areaNumber, 'single'); % allocate memory
    keep_angle = zeros(1, areaNumber, 'single'); % allocate memory;

    % constant hidden params
    TH_WING_COLOR_MAX = 216;
    TH_WING_COLOR_MIN = 140;

    wingImage = grayImage;
    wingImage(wingImage >= TH_WING_COLOR_MAX) = 255;
    wingImage(wingImage <= TH_WING_COLOR_MIN) = 255;
    wingImage = 255 - wingImage;
    wingImage(wingImage > 0) = 255;

    % blur and cut again
    wingImage = imgaussfilt(wingImage, 1);
    wingImage(wingImage <= TH_WING_COLOR_MIN) = 0;
    wingImage(wingImage > TH_WING_COLOR_MIN) = 255;

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

        % get around color (maybe wing) colors
        [ colors ] = getCircleColors(wingImage, cx, cy, ph, majlen * 0.55, 1, 10);
        colLen = length(colors);

        frontTotal = sum(colors(1:floor(colLen/4))) + sum(floor(colLen/4*3)+1:colLen);
        backTotal = sum(colors(floor(colLen/4)+1:floor(colLen/4*3)));
        if frontTotal > backTotal
            vec = -vec;
        end
        keep_direction(:,i) = vec;
        keep_angle(:,i) = angle;
    end
end
