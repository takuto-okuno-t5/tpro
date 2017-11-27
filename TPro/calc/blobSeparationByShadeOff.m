%%
function [nearNum, nearAREA, nearCENTROID, nearBBOX, nearMAJORAXIS, nearMINORAXIS, nearORIENTATION, nearECCENTRICITY] = ...
    blobSeparationByShadeOff(blob_img_trimmed, blob_threshold, expect_num, H)
    % find separated area
    blob_threshold2 = blob_threshold / 2 - 0.1;
    if blob_threshold2 < 0, blob_threshold2 = 0; end % should be positive

    % stronger gaussian again
    blob_img_trimmed = imgaussfilt(blob_img_trimmed, 2);
    blob_th_max = max(max(blob_img_trimmed));
    blob_img_trimmed = blob_img_trimmed / blob_th_max;

    %peakImg = imregionalmax(blob_img_trimmed);
    NEARBLOBMAX = 999;
    nearCount = NEARBLOBMAX;
    nearNum = 0;

    for th_i = 1 : 60
        blob_threshold2 = blob_threshold2 + 0.02;
        if blob_threshold2 > 1
            break;
        end

        blob_img_trimmed2 = im2bw(blob_img_trimmed, blob_threshold2);
        [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(H, blob_img_trimmed2);
        count = (expect_num - size(AREA, 1));

        if nearCount > count
            nearCount = count;
            nearNum = size(AREA, 1);
            nearAREA = AREA;
            nearCENTROID = CENTROID;
            nearBBOX = BBOX;
            nearMAJORAXIS = MAJORAXIS;
            nearMINORAXIS = MINORAXIS;
            nearORIENTATION = ORIENTATION;
            nearECCENTRICITY = ECCENTRICITY;
            if nearNum >= expect_num
                nearNum = expect_num;
                break;
            end
        end
    end
end
