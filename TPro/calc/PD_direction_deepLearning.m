%%
function [ keep_direction, keep_angle ] = PD_direction_deepLearning(glayImage, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, netForFrontBack, classifierFrontBack)
    % init
    areaNumber = size(blobAreas, 1);
    keep_direction = zeros(2, areaNumber); % allocate memory
    keep_angle = zeros(1, areaNumber); % allocate memory;

    % find direction for every blobs
    for i = 1:areaNumber
        % pre calculation
        cx = blobCenterPoints(i,1);
        cy = blobCenterPoints(i,2);
        ph = -blobOrient(i);
        cosph =  cos(ph);
        sinph =  sin(ph);
        len = blobMajorAxis(i) * 0.35;
        vec = [len*cosph; len*sinph];

        angle = -blobOrient(i)*180 / pi;

%        boxSize = int64((blobMajorAxis(i) * 1.25 * 1.5) / 16) * 16; % wing may not in blob so body*1.25
        boxSize = 64;

        trimmedImage = getOneFlyBoxImage_(glayImage, cx, cy, vec, boxSize);
        img = readAndPreprocessImage(trimmedImage);

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

%%
function Iout = readAndPreprocessImage(I)
    % Some images may be grayscale. Replicate the image 3 times to
    % create an RGB image. 
    %    if ismatrix(I)
    %        I = cat(3,I,I,I);
    %    end

    % Resize the image as required for the CNN. 
    if size(I,1) ~= 64 || size(I,2) ~= 64
        Iout = imresize(I, [64 64]);  
    else
        Iout = I;
    end
end