%%
function [ colors ] = getCircleColors(image, cx, cy, phi, radius, range, step)
    width = 1+2*range;
    stepNum = floor(360/step);
    colors = zeros(width, stepNum*width);
    ymax = size(image,1);
    xmax = size(image,2);

    for i=1:stepNum
        ph = phi + (i-1)*step/180 * pi;
        cosph =  cos(ph);
        sinph =  sin(ph);
        dx = radius * cosph;
        dy = radius * sinph;
        x1 = int64(cx+dx); y1 = int64(cy+dy);
        if (y1-range)<1 y1 = range+1; end
        if (y1+range)>ymax y1 = ymax-range; end
        if (x1-range)<1 x1 = range+1; end
        if (x1+range)>xmax x1 = xmax-range; end
        colors(:, ((i-1)*width+1):(i*width)) = image(y1-range:y1+range, x1-range:x1+range);
%        image(y1-range:y1+range, x1-range:x1+range) = 255;
    end
end
