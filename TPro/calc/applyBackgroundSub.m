%% image calcuration 
function outimage = applyBackgroundSub(handles, img)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    grayImg = rgb2gray(img);
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
    img = imadjust(img,[0.15;0.94]);
    img = imsharpen(img,'Radius',2,'Amount',1);
    outimage = img;
end
