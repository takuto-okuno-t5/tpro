%%
function [ colors ] = getCircleColors(image, cx, cy, phi, radius, range, step)
    colors = zeros(1,360/step);
    ymax = size(image,1);
    area = ((range*2+1) * (range*2+1));

    for i=1:length(colors)
        ph = phi + (i-1)*step/180 * pi;
        cosph =  cos(ph);
        sinph =  sin(ph);
        dx = radius * cosph;
        dy = radius * sinph;
        x1 = int64(cx+dx); y1 = int64(cy+dy);
        if (y1-range)<1 y1 = range+1; end
        if (y1+range)>ymax y1 = ymax-range; end
        colBox1 = image(y1-range:y1+range, x1-range:x1+range);
        colors(i) = sum(sum(colBox1)) / area;
%        image(y1-range:y1+range, x1-range:x1+range) = 255;
    end
end
