%%
function trimmedImage = getOneFlyBoxImage_(image, ptX, ptY, dir, boxSize)
    trimSize = max(boxSize) * 1.5;
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
    if length(boxSize) == 1
        boxSize = [boxSize boxSize];
    end
    rect = [round((trimSize-boxSize(2))/2) round((trimSize-boxSize(1))/2) boxSize(2) boxSize(1)];
    trimmedImage = imcrop(rotatedImage, rect);
    [x,y,col] = size(trimmedImage);
    if x > boxSize(1) || y > boxSize(2)
        if col == 3
            trimmedImage(:,(boxSize(2)+1):end,:) = [];
            trimmedImage((boxSize(1)+1):end,:,:) = [];
        else
            trimmedImage(:,(boxSize(2)+1):end) = [];
            trimmedImage((boxSize(1)+1):end,:) = [];
        end
    end
    if x < boxSize(1) || y < boxSize(2)
        if col == 3
            trimmedImage(boxSize(1),boxSize(2),:) = 0;
        else
            trimmedImage(boxSize(1),boxSize(2)) = 0;
        end
    end
end
