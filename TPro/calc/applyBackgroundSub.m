%% image calcuration 
function outimage = applyBackgroundSub(handles, img)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if size(img,3) == 1
        grayImg = img;
    else
        grayImg = rgb2gray(img);
    end
    if sharedInst.isInvert
        grayImg = imcomplement(grayImg);
    end
    if ~isempty(sharedInst.bgImageMean)
        grayImg = grayImg + (sharedInst.bgImageMean - mean(mean(grayImg)));
        grayImageDouble = double(grayImg);
        img = sharedInst.bgImageDouble - grayImageDouble;
        img = uint8(img);
        img = imcomplement(img);
    else
        img = grayImg;
    end
    % sharp and consrast filters
    if sharedInst.contMin > 0 && sharedInst.contMax > 0
        img = imadjust(img, [sharedInst.contMin; sharedInst.contMax]);
    end
    if sharedInst.sharpRadius > 0 && sharedInst.sharpAmount > 0
        img = imsharpen(img, 'Radius',sharedInst.sharpRadius, 'Amount',sharedInst.sharpAmount);
    end
    outimage = img;
end
