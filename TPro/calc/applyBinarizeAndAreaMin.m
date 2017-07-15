%%
function outimage = applyBinarizeAndAreaMin(handles, img)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    img = im2bw(img, sharedInst.binaryTh / 100);
    outimage = bwareaopen(img, sharedInst.binaryAreaPixel);   % delete blob that has area less than 50
end
