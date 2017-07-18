%%
function boxSize = findFlyImageBoxSize(handles, startFrame, endFrame)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    step = int64((endFrame - startFrame) / 12);
    count = 0;
    sumMajorAxis = 0;
    for frameNum = startFrame+step:step:endFrame-step % just use middle flames of movie
        img = TProRead(sharedInst.shuttleVideo, frameNum);
        step2Image = applyBackgroundSub(handles, img);
        step3Image = applyFilterAndRoi(handles, step2Image);
        step4Image = applyBinarizeAndAreaMin(handles, step3Image);

        [ blobPointY, blobPointX, blobAreas, blobCenterPoints, blobBoxes, ...
          blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( ...
              step3Image, step4Image, sharedInst.binaryTh/100, sharedInst.blobSeparateRate, ...
              1, 0, sharedInst.maxSeparate, sharedInst.isSeparate, sharedInst.delRectOverlap, sharedInst.maxBlobs, ...
              sharedInst.keepNear);
        sumMajorAxis = sumMajorAxis + mean(blobMajorAxis);
        count = count + 1;
    end
    meanMajorAxis = sumMajorAxis / count;
    boxSize = int64((meanMajorAxis * 1.5) / 8) * 8;
end
