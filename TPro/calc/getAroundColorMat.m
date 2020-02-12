%%
function [ colors ] = getAroundColorMat(labelWingImage, labeledImage, cx, cy, phi, majlen, range, step, radiusRate)
    % get around color (maybe labeled wing)
    width = 1 + range*2;
    area = (width * width);
    stepNum = floor(360/step);
    colmat = zeros(3*width, stepNum*width);
    colors = zeros(3,stepNum);
    for j=1:3
        box = getCircleColors(labelWingImage, cx, cy, phi, majlen * (radiusRate-0.1+(j-1)*0.1), range, step);
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

    % to decrease touched blob error, most out circle colors are
    % subtracted by far side circle colors
    box = getCircleColors(labeledImage, cx, cy, phi, majlen * 0.95, range, step);
    box(box~=label) = 0;
    box(box==label) = 255;
    if sum(sum(box)) > 0
        farColors = zeros(1,stepNum);
        for k=1:stepNum
            colBox1 = box(1:width, width*(k-1)+1:width*k);
            farColors(1,k) = sum(sum(colBox1)) / area;
        end
        farColors0 = [0, farColors(1,2:stepNum-1), 0];
        farColors0(1,floor(stepNum/2):floor(stepNum/2)+1) = 0;
        colors = colors - [farColors0; farColors; farColors];
        colors(colors < 0) = 0;
    end
end
