%%
function status = saveConfigurationFile(handles)
    % save configuration file
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    name = sharedInst.shuttleVideo.Name;
    frameNum = sharedInst.shuttleVideo.NumberOfFrames;
    frameRate = sharedInst.shuttleVideo.FrameRate;
    frameSteps = sharedInst.frameSteps;
    gaussH = sharedInst.gaussH;
    gaussSigma = sharedInst.gaussSigma;
    binaryTh = sharedInst.binaryTh;
    binaryAreaPixel = sharedInst.binaryAreaPixel;
    blobSeparateRate = sharedInst.blobSeparateRate;
    mmPerPixel = sharedInst.mmPerPixel;
    filterType = sharedInst.filterType;
    maxSeparate = sharedInst.maxSeparate;
    isSeparate = sharedInst.isSeparate;
    maxBlobs = sharedInst.maxBlobs;
    delRectOverlap = sharedInst.delRectOverlap;

    B = {1, name, '', sharedInst.startFrame, sharedInst.endFrame, frameNum, frameRate, ...
        (binaryTh / 100), mmPerPixel, sharedInst.roiNum, 200, 0, ...
        gaussH, gaussSigma, binaryAreaPixel, frameSteps, blobSeparateRate, filterType, ...
        maxSeparate, isSeparate, maxBlobs, delRectOverlap};

    status = saveInputControlFile(sharedInst.confFileName, B);
    if status
        try
            % save last detection setting
            save('etc/last_detect_config.mat','frameSteps','gaussH','gaussSigma','binaryTh','binaryAreaPixel','blobSeparateRate', ...
                'mmPerPixel','filterType','maxSeparate','isSeparate','maxBlobs','delRectOverlap');
            status = true;
        catch e
            status = false;
            errordlg(['failed to save configuration file : ' sharedInst.confFileName], 'Error');
        end
    end
    if status 
        sharedInst.isModified = false;
        setappdata(handles.figure1,'sharedInst',sharedInst); % update shared
    end
end
