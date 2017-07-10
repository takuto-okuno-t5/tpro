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

    B = {1, name, '', sharedInst.startFrame, sharedInst.endFrame, frameNum, frameRate, ...
        (binaryTh / 100), mmPerPixel, sharedInst.roiNum, 200, 0, ...
        gaussH, gaussSigma, binaryAreaPixel, frameSteps, blobSeparateRate};

    try
        T = cell2table(B);
        confTable = readtable(sharedInst.confFileName);
        T.Properties.VariableNames = confTable.Properties.VariableNames;
        writetable(T,sharedInst.confFileName);

        % save last detection setting
        save('./last_detect_config.mat','frameSteps','gaussH','gaussSigma','binaryTh','binaryAreaPixel','blobSeparateRate','mmPerPixel');
        status = true;
    catch e
        status = false;
        errordlg(['failed to save configuration file : ' sharedInst.confFileName], 'Error');
    end
    if status 
        sharedInst.isModified = false;
        setappdata(handles.figure1,'sharedInst',sharedInst); % update shared
    end
end
