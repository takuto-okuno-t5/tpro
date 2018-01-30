%%
function [ keep_direction, keep_angle, keep_wings ] = PD_direction_deepLearning(glayImage, blobAreas, blobCenterPoints, blobBoxes, meanBlobmajor, mmPerPixel, blobOrient, netForFrontBack, classifierFrontBack)
    % init
    areaNumber = size(blobAreas, 1);
    keep_direction = nan(2, areaNumber, 'single'); % allocate memory
    keep_angle = nan(1, areaNumber, 'single'); % allocate memory
    keep_wings = []; % allocate memory

    % find direction for every blobs
    for i = 1:areaNumber
        % pre calculation
        cx = blobCenterPoints(i,1);
        cy = blobCenterPoints(i,2);
        ph = -blobOrient(i);
        cosph =  cos(ph);
        sinph =  sin(ph);
        len = meanBlobmajor / mmPerPixel * 0.35;
        vec = [len*cosph; len*sinph];

        angle = -blobOrient(i)*180 / pi;

        boxSize = findFlyImageBoxSize(meanBlobmajor, mmPerPixel);

        trimmedImage = getOneFlyBoxImage_(glayImage, cx, cy, vec, boxSize);
        img = resizeImage64ForDL(trimmedImage);

        % Extract image features using the CNN
        imageFeatures = activations(netForFrontBack, img, 11);

        % Make a prediction using the classifier
        label = predict(classifierFrontBack, imageFeatures);
        if label == 'fly_back'
            vec = -vec;
            if angle > 0
                angle = angle - 180;
            else
                angle = angle + 180;
            end
        end

        keep_direction(:,i) = vec;
        keep_angle(:,i) = angle;
    end
end
