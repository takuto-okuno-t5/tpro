%%
function [trimmedImage, rect] = getTemplateBoxImage(blob_img_masked, tmplImage, rectIn)
    w = max(size(tmplImage,1), size(tmplImage,2));
    rect = rectIn + int32([-w/2, -w/2, w, w]);
    if rect(3) < w*2
        rect(3) = w*2 + 4;
    end
    if rect(4) < w*2
        rect(4) = w*2 + 4;
    end
    trimmedImage = uint8(zeros(rect(4),rect(3)));
    cimg = imcrop(blob_img_masked, rect); % sometime edge may be cut
    trimmedImage(1:size(cimg,1),1:size(cimg,2)) = cimg;
    trimmedImage(trimmedImage==0) = 255;
end