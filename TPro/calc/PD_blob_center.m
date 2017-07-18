%%
function [ blobPointX, blobPointY, blobAreas, blobCenterPoints, blobBoxes, ...
           blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( ...
                        blob_img, blob_img_logical, blob_threshold, blobSeparateRate, frameCount, blobAvgSizeIn,...
                        maxSeparate, isSeparate, delRectOverlap, maxBlobs, keepNear)
    H = vision.BlobAnalysis;
    H.MaximumCount = 100;
    H.MajorAxisLengthOutputPort = 1;
    H.MinorAxisLengthOutputPort = 1;
    H.OrientationOutputPort = 1;
    H.EccentricityOutputPort = 1;
    H.ExtentOutputPort = 1; % just dummy for matlab 2015a runtime. if removing this, referense error happens.

    [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(H, blob_img_logical);
    origAreas = AREA;
    origCenterPoints = CENTROID;
    origBoxes = BBOX;
    origMajorAxis = MAJORAXIS;
    origMinorAxis = MINORAXIS;
    origOrient = ORIENTATION;
    origEcc = ECCENTRICITY;

    labeledImage = bwlabel(blob_img_logical);   % label the image

    area_mean = mean(origAreas);
    blobAvgSize = (area_mean + blobAvgSizeIn * (frameCount - 1)) / frameCount;
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

    % loop for checking all blobs
    for i = 1 : blob_num
        % check blobAreas dimension of current blob and how bigger than avarage.
        area_ratio = double(origAreas(i))/blobAvgSize;
        if (mod(area_ratio,1) > blobSeparateRate)
            expect_num = area_ratio + (1-mod(area_ratio,1));
        else
            expect_num = floor(area_ratio); % floor to the nearest integer
        end

        % check expected number of targets (animals)
        chooseOne = true;
        if expect_num <= 1  % expect one
            % set output later
        elseif expect_num > maxSeparate % too big! isn't it?
            chooseOne = false;
        elseif expect_num > 1 && isSeparate
            % find separated area
            blob_threshold2 = blob_threshold - 0.2;
            if blob_threshold2 < 0, blob_threshold2 = 0; end % should be positive

            label_mask = labeledImage==i;
            blob_img_masked = blob_img .* label_mask;

            % trimmed from original gray scale image
            rect = origBoxes(i,:);
            blob_img_trimmed = imcrop(blob_img_masked, rect);

            % stronger gaussian again
            blob_img_trimmed = imgaussfilt(blob_img_trimmed, 2);
            blob_th_max = max(max(blob_img_trimmed));
            blob_img_trimmed = blob_img_trimmed / blob_th_max;

            for th_i = 1 : 40
                blob_threshold2 = blob_threshold2 + 0.05;
                if blob_threshold2 > 1
                    break;
                end

                blob_img_trimmed2 = im2bw(blob_img_trimmed, blob_threshold2);
                [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(H, blob_img_trimmed2);

                if expect_num <= size(AREA, 1) % change from <= to == 20161015
                    x_choose = CENTROID(1:expect_num,2);
                    y_choose = CENTROID(1:expect_num,1);    % choose expect_num according to area (large)
                    blobPointX = [blobPointX ; x_choose + double(rect(2))];
                    blobPointY = [blobPointY ; y_choose + double(rect(1))];
                    blobAreas = [blobAreas ; AREA(1:expect_num)];
                    blobMajorAxis = [blobMajorAxis ; MAJORAXIS(1:expect_num)];
                    blobMinorAxis = [blobMinorAxis ; MINORAXIS(1:expect_num)];
                    blobOrient = [blobOrient ; ORIENTATION(1:expect_num)];
                    blobEcc = [blobEcc ; ECCENTRICITY(1:expect_num)];
                    for j=1 : expect_num
                        pt = CENTROID(j,:) + [double(rect(1)) double(rect(2))];
                        box = BBOX(j,:) + [int32(rect(1)) int32(rect(2)) 0 0];
                        blobCenterPoints = [blobCenterPoints ; pt];
                        blobBoxes = [blobBoxes ; box];
                    end
                    chooseOne = false;
                    break
                end
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
