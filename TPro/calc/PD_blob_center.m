%%
function [ blobPointX, blobPointY, blobAreas, blobCenterPoints, blobBoxes, ...
           blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( ...
                        step2Image, step3Image, step4Image, blob_threshold, blobSeparateRate, blobAvgSizeIn,...
                        tmplMatchTh, tmplSepNum, tmplSepTh, tmplImages, isSeparate, delRectOverlap, maxBlobs, keepNear)
    hBlobAnls = vision.BlobAnalysis;
    hBlobAnls.MaximumCount = 100;
    hBlobAnls.MajorAxisLengthOutputPort = 1;
    hBlobAnls.MinorAxisLengthOutputPort = 1;
    hBlobAnls.OrientationOutputPort = 1;
    hBlobAnls.EccentricityOutputPort = 1;
    hBlobAnls.ExtentOutputPort = 1; % just dummy for matlab 2015a runtime. if removing this, referense error happens.

    [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(hBlobAnls, step4Image);
    origAreas = AREA;
    origCenterPoints = CENTROID;
    origBoxes = BBOX;
    origMajorAxis = MAJORAXIS;
    origMinorAxis = MINORAXIS;
    origOrient = ORIENTATION;
    origEcc = ECCENTRICITY;

    labeledImage = bwlabel(step4Image);   % label the image
    if (isnan(blobAvgSizeIn) || blobAvgSizeIn == 0) && ~isempty(origAreas)
        blobAvgSize = nanmedian(origAreas);
    else
        blobAvgSize = blobAvgSizeIn;
    end
    blob_num = size(origAreas,1);
    blobPointX = [];
    blobPointY = [];
    blobAreas = [];
    blobCenterPoints = [];
    blobBoxes = [];
    blobMajorAxis = [];
    blobMinorAxis = [];
    blobOrient = [];
    blobEcc = [];
    blobOrgIdx = [];

    % estimate fly numbers in each blob first
    total = -1;
    divRate = 1;
    while total < maxBlobs
        [expectNums, useTmplMatch, minNums] = blobNumEstimation(origAreas, blobAvgSize, blobSeparateRate, maxBlobs, tmplSepNum, divRate);
        total = sum(expectNums);
        divRate = divRate - 0.02;
    end

    % loop for checking all blobs
    for i = 1 : blob_num
        % check expected number of targets (animals)
        chooseOne = true;
        if expectNums(i) <= 1  % expect one
            % set output later
        elseif isSeparate
            label_mask = labeledImage==i;
            if useTmplMatch(i) > 0 && tmplSepNum > 0 && ~isempty(tmplImages) % big separation. use template matching
                blob_img_masked = step2Image .* uint8(label_mask);

                % trimmed from original gray scale image
                tmplImage = tmplImages{1};
                [blob_img_trimmed, rect] = getTemplateBoxImage(blob_img_masked, tmplImage, origBoxes(i,:));

                [nearNum, nearAREA, nearCENTROID, nearBBOX, nearMAJORAXIS, nearMINORAXIS, nearORIENTATION, nearECCENTRICITY] = ...
                    blobSeparationByTemplateMatch(blob_img_trimmed, expectNums(i), tmplImage, tmplSepTh, origAreas(i));

            else % small separation. use shading off blob separation
                blob_img_masked = step3Image .* label_mask;

                % trimmed from original gray scale image
                rect = origBoxes(i,:);
                blob_img_trimmed = imcrop(blob_img_masked, rect);

                [nearNum, nearAREA, nearCENTROID, nearBBOX, nearMAJORAXIS, nearMINORAXIS, nearORIENTATION, nearECCENTRICITY] = ...
                    blobSeparationByShadeOff(blob_img_trimmed, blob_threshold, expectNums(i), hBlobAnls);

                % shading off did not separate well. use template matching and check again
                if expectNums(i) > nearNum && tmplSepNum > 0 && ~isempty(tmplImages)
                    blob_img_masked = step2Image .* uint8(label_mask);

                    % trimmed from original gray scale image
                    tmplImage = tmplImages{1};
                    [blob_img_trimmed, rect] = getTemplateBoxImage(blob_img_masked, tmplImage, origBoxes(i,:));

                    [nearNum, nearAREA, nearCENTROID, nearBBOX, nearMAJORAXIS, nearMINORAXIS, nearORIENTATION, nearECCENTRICITY] = ...
                        blobSeparationByTemplateMatch(blob_img_trimmed, expectNums(i), tmplImage, tmplSepTh, origAreas(i));
                end
            end

            if nearNum > 0
                x_choose = nearCENTROID(1:nearNum,2);
                y_choose = nearCENTROID(1:nearNum,1);    % choose nearNum according to area (large)
                blobPointX = [blobPointX ; x_choose + double(rect(2))];
                blobPointY = [blobPointY ; y_choose + double(rect(1))];
                blobAreas = [blobAreas ; nearAREA(1:nearNum)];
                blobMajorAxis = [blobMajorAxis ; nearMAJORAXIS(1:nearNum)];
                blobMinorAxis = [blobMinorAxis ; nearMINORAXIS(1:nearNum)];
                blobOrient = [blobOrient ; nearORIENTATION(1:nearNum)];
                blobEcc = [blobEcc ; nearECCENTRICITY(1:nearNum)];
                for j=1 : nearNum
                    pt = nearCENTROID(j,:) + [double(rect(1)) double(rect(2))];
                    box = nearBBOX(j,:) + [int32(rect(1)) int32(rect(2)) 0 0];
                    blobCenterPoints = [blobCenterPoints ; pt];
                    blobBoxes = [blobBoxes ; box];
                    blobOrgIdx = [blobOrgIdx ; i];
                end
                chooseOne = false;
            end
        end
        if chooseOne
            % choose one
            blobPointX = [blobPointX ; origCenterPoints(i,2)];
            blobPointY = [blobPointY ; origCenterPoints(i,1)];
            blobAreas = [blobAreas ; origAreas(i)];
            blobCenterPoints = [blobCenterPoints ; origCenterPoints(i,:)];
            blobBoxes = [blobBoxes ; origBoxes(i,:)];
            blobMajorAxis = [blobMajorAxis ; origMajorAxis(i)];
            blobMinorAxis = [blobMinorAxis ; origMinorAxis(i)];
            blobOrient = [blobOrient ; origOrient(i)];
            blobEcc = [blobEcc ; origEcc(i)];
            blobOrgIdx = [blobOrgIdx ; i];
        end
    end

    % check rectangle overlap
    if delRectOverlap
        delIdx = [];
        for i=1:size(blobBoxes,1)
            for j=(i+1):size(blobBoxes,1)
                area = rectint(blobBoxes(i,:),blobBoxes(j,:));
                if area > 0
                    if blobAreas(i) > blobAreas(j)
                        delIdx = [delIdx j];
                    else
                        delIdx = [delIdx i];
                    end
                end
            end
        end
        if ~isempty(delIdx)
            blobPointX(delIdx) = [];
            blobPointY(delIdx) = [];
            blobAreas(delIdx) = [];
            blobCenterPoints(delIdx,:) = [];
            blobBoxes(delIdx,:) = [];
            blobMajorAxis(delIdx) = [];
            blobMinorAxis(delIdx) = [];
            blobOrient(delIdx) = [];
            blobEcc(delIdx) = [];
            blobOrgIdx(delIdx) = [];
        end
    end

    % template matching (NCC) with blobs to check actual fly image
    outputNum = length(blobPointX);
    if ~isempty(tmplImages) && tmplMatchTh > 0 && outputNum > 0
        delIdx = [];
        tmplNum = length(tmplImages);
        tmplEnergy = zeros(1,tmplNum);
        matchRate = zeros(1,outputNum);
        for j=1:tmplNum
            tmplImage = tmplImages{j};
            tmplEnergy(j) = sqrt(sum(tmplImage(:).^2));
        end
        for i=1:outputNum
            % pre calculation
            cx = blobCenterPoints(i,1);
            cy = blobCenterPoints(i,2);
            ph = -blobOrient(i);
            cosph =  cos(ph);
            sinph =  sin(ph);
            ncc = zeros(1,tmplNum);
            for j=1:length(tmplImages)
                tmplImage = tmplImages{j};
                len = size(tmplImage,1);
                vec = [len*cosph; len*sinph];
                trimmedImage = getOneFlyBoxImage_(step2Image, cx, cy, vec, size(tmplImage));
                trimmedImage = single(255 - trimmedImage);
                trimmedEnergy = sqrt(sum(trimmedImage(:).^2));
                mul = tmplImage .* trimmedImage;
                ncc(j) = sum(mul(:)) / (tmplEnergy(j) * trimmedEnergy);
            end
            idx = find(ncc >= tmplMatchTh);
            if isempty(idx)
                delIdx = [delIdx i];
            else
                matchRate(i) = max(ncc);
            end
        end
%{
        if maxBlobs > 0 && blobNum > maxBlobs
            [Y,I] = sort(matchRate);
            delIdx = [delIdx I(1:(blobNum-maxBlobs))];
            delIdx = unique(delIdx);
        end
%}
        if ~isempty(delIdx)
            blobPointX(delIdx) = [];
            blobPointY(delIdx) = [];
            blobAreas(delIdx) = [];
            blobCenterPoints(delIdx,:) = [];
            blobBoxes(delIdx,:) = [];
            blobMajorAxis(delIdx) = [];
            blobMinorAxis(delIdx) = [];
            blobOrient(delIdx) = [];
            blobEcc(delIdx) = [];
            blobOrgIdx(delIdx) = [];
        end
    end

    % check maximum blobs
    outputNum = length(blobPointX);
    if maxBlobs > 0 && outputNum > maxBlobs
        dist = pdist(blobCenterPoints);
        dist1 = squareform(dist); %make square
        delIdx = [];

        if keepNear
            % find bigest blob, then take nearest blobs
            [marea,i] = max(blobAreas);
            while maxBlobs < (outputNum - length(delIdx))
                [mm,m] = max(dist1(i,:));
                delIdx = [delIdx, m];
                dist1(i,m) = 0;
                delIdx = unique(delIdx);
            end
        else
            % find nearest neighbor, then delete smaller area
            dist1(dist1==0) = 9999; % set dummy
            while maxBlobs < (outputNum - length(delIdx))
                [mmin,m] = min(dist1);
                [nmin,n] = min(mmin);
                if blobAreas(m(n)) > blobAreas(n)
                    idx = n;
                else
                    idx = m(n);
                end
                orgIdx = blobOrgIdx(idx);
                if orgIdx > 0
                    minNum = minNums(orgIdx);
                    if length(find(blobOrgIdx==orgIdx)) > minNum
                        delIdx = [delIdx, idx];
                        blobOrgIdx(idx) = 0;
                        dist1(idx,:) = 9999;
                        dist1(:,idx) = 9999;
                    end
                end
                dist1(n,m(n)) = 9999; % set dummy
                dist1(m(n),n) = 9999; % set dummy
                delIdx = unique(delIdx);
            end
        end
        if ~isempty(delIdx)
            blobPointX(delIdx) = [];
            blobPointY(delIdx) = [];
            blobAreas(delIdx) = [];
            blobCenterPoints(delIdx,:) = [];
            blobBoxes(delIdx,:) = [];
            blobMajorAxis(delIdx) = [];
            blobMinorAxis(delIdx) = [];
            blobOrient(delIdx) = [];
            blobEcc(delIdx) = [];
            blobOrgIdx(delIdx) = [];
        end
    end
end
