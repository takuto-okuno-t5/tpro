%% image calcuration 
function outimage = applyBackgroundSub(handles, img)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    grayImg = rgb2gray(img);
    if ~isempty(sharedInst.bgImageMean)
        grayImg = grayImg + (sharedInst.bgImageMean - mean(mean(grayImg)));
        grayImageDouble = double(grayImg);
        img = sharedInst.bgImageDouble - grayImageDouble;
        img = uint8(img);
        img = imcomplement(img);
    else
        img = grayImg;
    end
    outimage = img;
end
