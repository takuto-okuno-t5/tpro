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
    reject_dist = sharedInst.reject_dist;
    isInvert = sharedInst.isInvert;
    rRate = sharedInst.rRate;
    gRate = sharedInst.gRate;
    bRate = sharedInst.bRate;
    keepNear = sharedInst.keepNear;
    fixedTrackNum = sharedInst.fixedTrackNum;
    fixedTrackDir = sharedInst.fixedTrackDir;
    contMin = sharedInst.contMin;
    contMax = sharedInst.contMax;
    sharpRadius = sharedInst.sharpRadius;
    sharpAmount = sharedInst.sharpAmount;
    templateCount = sharedInst.templateCount;
    tmplMatchTh = sharedInst.tmplMatchTh;
    tmplSepNum = sharedInst.tmplSepNum;
    tmplSepTh = sharedInst.tmplSepTh;
    overlapTh = sharedInst.overlapTh;

    B = {1, name, '', sharedInst.startFrame, sharedInst.endFrame, frameNum, frameRate, ...
        (binaryTh / 100), mmPerPixel, sharedInst.roiNum, reject_dist, isInvert, ...
        gaussH, gaussSigma, binaryAreaPixel, frameSteps, blobSeparateRate, ...
        filterType, maxSeparate, isSeparate, maxBlobs, delRectOverlap, ...
        rRate, gRate, bRate, keepNear, fixedTrackNum, fixedTrackDir ...
        contMin, contMax, sharpRadius, sharpAmount, ...
        templateCount, tmplMatchTh, tmplSepNum, tmplSepTh, overlapTh ...
        };

    status = saveInputControlFile(sharedInst.confFileName, B);
    if status
        try
            % save last detection setting
            save('etc/last_detect_config.mat','frameSteps','gaussH','gaussSigma','binaryTh','binaryAreaPixel','blobSeparateRate', ...
                'mmPerPixel','filterType','maxSeparate','isSeparate','maxBlobs','delRectOverlap','reject_dist','isInvert', ...
                'rRate', 'gRate', 'bRate', 'keepNear', 'fixedTrackNum', 'fixedTrackDir', ...
                'contMin', 'contMax', 'sharpRadius', 'sharpAmount', ...
                'templateCount', 'tmplMatchTh', 'tmplSepNum', 'tmplSepTh', 'overlapTh' ...
                );
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
