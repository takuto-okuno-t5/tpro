%%
function [nearNum, nearAREA, nearCENTROID, nearBBOX, nearMAJORAXIS, nearMINORAXIS, nearORIENTATION, nearECCENTRICITY] = ...
    blobSeparationByShadeOff(blob_img_trimmed, blob_threshold, expect_num, H)
    % find separated area
    blob_threshold2 = blob_threshold / 2 - 0.1;
    if blob_threshold2 < 0, blob_threshold2 = 0; end % should be positive

    % stronger gaussian again
    blob_img_trimmed = imgaussfilt(blob_img_trimmed, 3);
    blob_th_max = max(max(blob_img_trimmed));
    blob_img_trimmed = blob_img_trimmed / blob_th_max;

    %peakImg = imregionalmax(blob_img_trimmed);
    NEARBLOBMAX = 999;
    nearNum = 0;

    for th_i = 1 : 60
        blob_threshold2 = blob_threshold2 + 0.02;
        if blob_threshold2 > 1
            break;
        end

        blob_img_trimmed2 = im2bw(blob_img_trimmed, blob_threshold2);
        [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(H, blob_img_trimmed2);

        if expect_num == 2
            if size(AREA,1) <= expect_num
                n = size(AREA,1);
            else
                n = expect_num;
            end
            if n > nearNum
                nearNum = n;
                nearAREA = AREA(1:n); nearCENTROID = single(CENTROID(1:n,:)); nearBBOX = BBOX(1:n,:);
                nearMAJORAXIS = single(MAJORAXIS(1:n)); nearMINORAXIS = single(MINORAXIS(1:n));
                nearORIENTATION = single(ORIENTATION(1:n)); nearECCENTRICITY = single(ECCENTRICITY(1:n));
                if n > 1
                    break; % end of loop
                end
            end

        else
            if size(AREA,1) == 1
                n = 1;
            elseif size(AREA,1) == 2
                % separate bigger one to small
                [a, i1] = max(AREA);
                [b, i2] = min(AREA);
                if a == b % oops! that causes bug!!
                    idx = 1:length(AREA);
                    i1not = find(idx~=i1);
                    i2 = i1not(1);
                end
                est1 = round(expect_num * single(AREA(i1)) / single(sum(AREA)));
                if est1 == expect_num
                    est1 = expect_num - 1;
                end
                est2 = expect_num - est1;

                labeledImage = bwlabel(blob_img_trimmed2);   % label the image

                % est1 (bigger one, so it must be separated)
                r1 = BBOX(i1,:);
                label_mask = labeledImage==i1;
                blob_img_trimmed2 = blob_img_trimmed .* label_mask;
                blob_img_trimmed3 = imcrop(blob_img_trimmed2, r1);
                [nn1, area1, cntr1, bbox1, majr1, minr1, ori1, ecc1] = blobSeparationByShadeOff(blob_img_trimmed3, blob_threshold, est1, H); 

                % est2 (smaller one, it might be 1 or bigger)
                if est2 == 1
                    r2 = int32([0 0 0 0]); nn2 = 1;
                    area2=AREA(i2); cntr2=CENTROID(i2,:); bbox2=BBOX(i2,:);
                    majr2 = MAJORAXIS(i2); minr2 = MINORAXIS(i2);
                    ori2 = ORIENTATION(i2); ecc2 = ECCENTRICITY(i2);
                else
                    r2 = BBOX(i2,:);
                    label_mask = labeledImage==i2;
                    blob_img_trimmed2 = blob_img_trimmed .* label_mask;
                    blob_img_trimmed3 = imcrop(blob_img_trimmed2, r2);
                    [nn2, area2, cntr2, bbox2, majr2, minr2, ori2, ecc2] = blobSeparationByShadeOff(blob_img_trimmed3, blob_threshold, est2, H); 
                end

                n = nn1 + nn2;
                AREA = [area1 ; area2];
                CENTROID = [cntr1+repmat(single(r1(1:2)),nn1,1) ; cntr2+repmat(single(r2(1:2)),nn2,1)];
                BBOX = [bbox1+repmat([r1(1:2) 0 0],nn1,1) ; bbox2+repmat([r2(1:2) 0 0],nn2,1)];
                MAJORAXIS = [majr1 ; majr2]; MINORAXIS = [minr1 ; minr2];
                ORIENTATION = [ori1 ; ori2]; ECCENTRICITY = [ecc1 ; ecc2];
            else
                if size(AREA,1) <= expect_num
                    n = size(AREA,1);
                else
                    n = expect_num;
                end
            end
            if n > nearNum
                nearNum = n;
                nearAREA = AREA(1:n); nearCENTROID = single(CENTROID(1:n,:)); nearBBOX = BBOX(1:n,:);
                nearMAJORAXIS = single(MAJORAXIS(1:n)); nearMINORAXIS = single(MINORAXIS(1:n));
                nearORIENTATION = single(ORIENTATION(1:n)); nearECCENTRICITY = single(ECCENTRICITY(1:n));
                if n > 1
                    break; % end of loop
                end
            end
        end
    end
end
