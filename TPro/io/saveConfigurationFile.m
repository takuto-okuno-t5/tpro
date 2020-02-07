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
    wingColorMin = sharedInst.wingColorMin;
    wingColorMax = sharedInst.wingColorMax;
    wingRadiusRate = sharedInst.wingRadiusRate;
    wingColorRange = sharedInst.wingColorRange;
    wingCircleStep = sharedInst.wingCircleStep;
    ignoreEccTh = sharedInst.ignoreEccTh;
    auto1st1 = sharedInst.auto1st1;
    auto1st1val = sharedInst.auto1st1val;
    auto1st2 = sharedInst.auto1st2;
    auto1st2val = sharedInst.auto1st2val;
    bodyColorMin = sharedInst.bodyColorMin;
    bodyColorMax = sharedInst.bodyColorMax;
    bodyRadiusRate = sharedInst.bodyRadiusRate;
    bodyColorRange = sharedInst.bodyColorRange;
    bodyCircleStep = sharedInst.bodyCircleStep;

    B = {1, name, '', sharedInst.startFrame, sharedInst.endFrame, frameNum, frameRate, ...
        (binaryTh / 100), mmPerPixel, sharedInst.roiNum, reject_dist, isInvert, ...
        gaussH, gaussSigma, binaryAreaPixel, frameSteps, blobSeparateRate, ...
        filterType, maxSeparate, isSeparate, maxBlobs, delRectOverlap, ...
        rRate, gRate, bRate, keepNear, fixedTrackNum, fixedTrackDir ...
        contMin, contMax, sharpRadius, sharpAmount, ...
        templateCount, tmplMatchTh, tmplSepNum, tmplSepTh, overlapTh, ...
        wingColorMin, wingColorMax, wingRadiusRate, wingColorRange, wingCircleStep, ignoreEccTh, ...
        auto1st1, auto1st1val, auto1st2, auto1st2val, ...
        bodyColorMin, bodyColorMax, bodyRadiusRate, bodyColorRange, bodyCircleStep ...
        };

    status = saveInputControlFile(sharedInst.confFileName, B);
    if status
        try
            % save last detection setting
            lastConfigName = getTproEtcFile('last_detect_config.mat');
            save(lastConfigName,'frameSteps','gaussH','gaussSigma','binaryTh','binaryAreaPixel','blobSeparateRate', ...
                'mmPerPixel','filterType','maxSeparate','isSeparate','maxBlobs','delRectOverlap','reject_dist','isInvert', ...
                'rRate', 'gRate', 'bRate', 'keepNear', 'fixedTrackNum', 'fixedTrackDir', ...
                'contMin', 'contMax', 'sharpRadius', 'sharpAmount', ...
                'templateCount', 'tmplMatchTh', 'tmplSepNum', 'tmplSepTh', 'overlapTh', ...
                'wingColorMin', 'wingColorMax', 'wingRadiusRate', 'wingColorRange', 'wingCircleStep', 'ignoreEccTh', ...
                'auto1st1', 'auto1st1val', 'auto1st2', 'auto1st2val', ...
                'bodyColorMin', 'bodyColorMax', 'bodyRadiusRate', 'bodyColorRange', 'bodyCircleStep' ...
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
