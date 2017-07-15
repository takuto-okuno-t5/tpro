%%
function trimmedImage = getOneFlyBoxImage(image, pointX, pointY, direction, boxSize, i)
    trimSize = boxSize * 1.5;
    rect = [pointX(i)-(trimSize/2) pointY(i)-(trimSize/2) trimSize trimSize];
    trimmedImage = imcrop(image, rect);

    % rotate image
    if isempty(direction) || direction(1,i) == 0
        angle = 0;
    else
        rt = direction(2,i) / direction(1,i);
        angle = atan(rt) * 180 / pi;

        if direction(1,i) >= 0
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
