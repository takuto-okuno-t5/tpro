%%
function [ color1, color2 ] = getTopAndBottomColors(image, len, cosph, sinph, cx, cy, r)
    dx = len * cosph;
    dy = len * sinph;
    x1 = int64(cx+dx); y1 = int64(cy+dy);
    x2 = int64(cx-dx); y2 = int64(cy-dy);
    ymax = size(image,1);
    if (y1-r)<1 y1 = r+1; end
    if (y2-r)<1 y2 = r+1; end
    if (y1+r)>ymax y1 = ymax-r; end
    if (y2+r)>ymax y2 = ymax-r; end
    colBox1 = image(y1-r:y1+r, x1-r:x1+r);
    colBox2 = image(y2-r:y2+r, x2-r:x2+r);
    area = ((r*2+1) * (r*2+1));
    color1 = sum(sum(colBox1)) / area;
    color2 = sum(sum(colBox2)) / area;
end
