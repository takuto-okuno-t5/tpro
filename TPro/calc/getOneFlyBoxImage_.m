%%
function trimmedImage = getOneFlyBoxImage_(image, ptX, ptY, dir, boxSize)
    trimSize = boxSize * 1.5;
    rect = [ptX-(trimSize/2) ptY-(trimSize/2) trimSize trimSize];
    trimmedImage = imcrop(image, rect);

    % rotate image
    if isempty(dir) || dir(1) == 0
        angle = 0;
    else
        rt = dir(2) / dir(1);
        angle = atan(rt) * 180 / pi;

        if dir(1) >= 0
            angle = angle + 90;
        else
            angle = angle + 270;
        end
    end
    rotatedImage = imrotate(trimmedImage, angle, 'crop', 'bilinear');

    % trim again
    rect = [(trimSize-boxSize)/2 (trimSize-boxSize)/2 boxSize boxSize];
    trimmedImage = imcrop(rotatedImage, rect);
    [x,y,col] = size(trimmedImage);
    if x > boxSize
        if col == 3
            trimmedImage(:,boxSize+1,:) = [];
            trimmedImage(boxSize+1,:,:) = [];
        else
            trimmedImage(:,boxSize+1) = [];
            trimmedImage(boxSize+1,:) = [];
        end
    end
end
