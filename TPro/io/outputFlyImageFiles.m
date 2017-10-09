%%
function outputFlyImageFiles(handles, startFrame, endFrame, boxSize)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % create output directory
    path = strcat(sharedInst.confPath,'detect_flies/');
    mkdir(path);

    for frameNum = startFrame:endFrame
        img = TProRead(sharedInst.shuttleVideo, frameNum);
        step2Image = applyBackgroundSub(handles, img);
        step3Image = applyFilterAndRoi(handles, step2Image);
        step4Image = applyBinarizeAndAreaMin(handles, step3Image);

        [ blobPointY, blobPointX, blobAreas, blobCenterPoints, blobBoxes, ...
          blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( ...
              step3Image, step4Image, sharedInst.binaryTh/100, sharedInst.blobSeparateRate, ...
              1, 0, sharedInst.maxSeparate, sharedInst.isSeparate, sharedInst.delRectOverlap, sharedInst.maxBlobs, ...
              sharedInst.keepNear);
        
        if sharedInst.useDeepLearning
            [flyDirection, flyAngle] = PD_direction_deepLearning(step2Image, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, ...
                sharedInst.netForFrontBack, sharedInst.classifierFrontBack);
        else
            [flyDirection, flyAngle] = PD_direction2(step2Image, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient);
        end

        blobNumber = size(blobPointY,1);
        for i = 1:blobNumber
            trimmedImage = getOneFlyBoxImage(step2Image, blobPointX, blobPointY, flyDirection, boxSize, i);
            filename = [sprintf('%05d_%02d', frameNum,i) '.png'];
            imwrite(trimmedImage, strcat(path,'/',filename));
            pause(0.01);
        end
        disp(strcat('output fly images >', num2str(frameNum), ' : ', num2str(100*(frameNum-startFrame)/(endFrame-startFrame+1)), '%', '     detect : ', num2str(blobNumber)));
        pause(0.1);
    end
end
