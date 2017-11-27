%%
function [ blobPointX, blobPointY, blobAreas, blobCenterPoints, blobBoxes, ...
           blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( ...
                        step2Image, step3Image, step4Image, blob_threshold, blobSeparateRate, blobAvgSizeIn,...
                        tmplMatchTh, tmplSepTh, tmplImages, isSeparate, delRectOverlap, maxBlobs, keepNear)
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
        blobAvgSize = nanmedian(origAreas) * 0.95;
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
    expectNums = zeros(1,blob_num);
    useTmplMatch = zeros(1,blob_num);

    % estimate fly numbers in each blob first
    for i = 1 : blob_num
        % check blobAreas dimension of current blob and how bigger than avarage.
        area_ratio = double(origAreas(i))/double(blobAvgSize);
        if (mod(area_ratio,1) >= blobSeparateRate)
            expect_num = area_ratio + (1-mod(area_ratio,1));
        else
            expect_num = floor(area_ratio); % floor to the nearest integer
        end
        if expect_num >= tmplMatchTh
            % usually, this kind of big blob becomes smaller area than times of single blob
            % so, expect_num is recalculated.
            area_ratio = double(origAreas(i))/double(blobAvgSize*0.92);
            if (mod(area_ratio,1) >= blobSeparateRate)
                expect_num = area_ratio + (1-mod(area_ratio,1));
            else
                expect_num = floor(area_ratio); % floor to the nearest integer
            end
            useTmplMatch(i) = 1;
        end
        expectNums(i) = expect_num;
    end
    total = sum(expectNums);
    if maxBlobs > 0 && maxBlobs > total
        % maxBlobs mode. total number is less than maxBlobs. so add a shortage
        idx = find(expectNums >= tmplMatchTh);
        k = 0;
        if ~isempty(idx)
            for j = 1:(maxBlobs - total)
                expectNums(idx(k+1)) = expectNums(idx(k+1)) + 1;
                k = mod(k+1, length(idx));
            end
        elseif ~isempty(origAreas)
            [B, idx] = sort(origAreas,'descend');
            for j = 1:(maxBlobs - total)
                expectNums(idx(k+1)) = expectNums(idx(k+1)) + 1;
                useTmplMatch(idx(k+1)) = 1; % force to use template matching
                k = mod(k+1, length(idx));
            end
        end
    end
    
    % loop for checking all blobs
    for i = 1 : blob_num
        % check expected number of targets (animals)
        chooseOne = true;
        if expectNums(i) <= 1  % expect one
            % set output later
        elseif isSeparate
            label_mask = labeledImage==i;
            if useTmplMatch(i) > 0 && ~isempty(tmplImages) % big separation. use template matching
                blob_img_masked = step2Image .* uint8(label_mask);

                % trimmed from original gray scale image
                tmplImage = tmplImages{1};
                rect = origBoxes(i,:);
                w = max(size(tmplImage,1), size(tmplImage,2));
                rect = rect + int32([-w/2, -w/2, w, w]);
                if rect(3) < w*2
                    rect(3) = w*2 + 2;
                elseif rect(4) < w*2
                    rect(4) = w*2 + 2;
                end
                blob_img_trimmed = imcrop(blob_img_masked, rect);
                blob_img_trimmed(blob_img_trimmed==0) = 255;

                [nearNum, nearAREA, nearCENTROID, nearBBOX, nearMAJORAXIS, nearMINORAXIS, nearORIENTATION, nearECCENTRICITY] = ...
                    blobSeparationByTemplateMatch(blob_img_trimmed, expectNums(i), tmplImage, tmplSepTh, origAreas(i));

            else % small separation. use shading off blob separation
                blob_img_masked = step3Image .* label_mask;

                % trimmed from original gray scale image
                rect = origBoxes(i,:);
                blob_img_trimmed = imcrop(blob_img_masked, rect);

                [nearNum, nearAREA, nearCENTROID, nearBBOX, nearMAJORAXIS, nearMINORAXIS, nearORIENTATION, nearECCENTRICITY] = ...
                    blobSeparationByShadeOff(blob_img_trimmed, blob_threshold, expectNums(i), hBlobAnls);
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
        end
    end
    
    % check maximum blobs
    blobNum = length(blobPointX);
    if maxBlobs > 0 && blobNum > maxBlobs
        dist = pdist(blobCenterPoints);
        dist1 = squareform(dist); %make square
        delIdx = [];

        if keepNear
            % find bigest blob, then take nearest blobs
            [marea,i] = max(blobAreas);
            while maxBlobs < (blobNum - length(delIdx))
                [mm,m] = max(dist1(i,:));
                delIdx = [delIdx, m];
                dist1(i,m) = 0;
                delIdx = unique(delIdx);
            end
        else
            % find nearest neighbor, then delete smaller area
            dist1(dist1==0) = 9999; % set dummy
            while maxBlobs < (blobNum - length(delIdx))
                [mmin,m] = min(dist1);
                [nmin,n] = min(mmin);
                if blobAreas(m(n)) > blobAreas(n)
                    delIdx = [delIdx, n];
                else
                    delIdx = [delIdx, m(n)];
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
        end
    end
end
