%%
function outimage = applyFilterAndRoi(handles, img)
    % apply gaussian filter
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    img = PD_blobfilter(img, sharedInst.gaussH, sharedInst.gaussSigma, sharedInst.filterType);

    % apply ROI
    if ~isempty(sharedInst.roiMaskImage)
        img = img .* sharedInst.roiMaskImage;
    end
    outimage = img;
end
