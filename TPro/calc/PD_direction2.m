%%
function [ keep_direction, keep_angle, keep_wings ] = PD_direction2(grayImage, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient)
    % init
    areaNumber = size(blobAreas, 1);
    keep_direction = nan(2, areaNumber, 'single'); % allocate memory
    keep_angle = nan(1, areaNumber, 'single'); % allocate memory
    keep_wings = []; % allocate memory

    % constant hidden params
    TH_OVER_HEAD_COLOR = 245;
    TH_WING_COLOR_MAX = 232;
    TH_WING_COLOR_MIN = 195;
    TH_HEAD_WING_DIFF_COLOR = 15; % between head and wing
    TH_WING_BG_DIFF_COLOR = 25;   % between wing and background

    % find direction for every blobs
    for i = 1:areaNumber
        % pre calculation
        angle = -blobOrient(i)*180 / pi;
        cx = blobCenterPoints(i,1);
        cy = blobCenterPoints(i,2);
        ph = -blobOrient(i);
        cosph =  cos(ph);
        sinph =  sin(ph);
        majlen = blobMajorAxis(i);
        vec = [majlen*cosph*0.5; majlen*sinph*0.5];

        % get head and tail colors
        [ c1, c2 ] = getTopAndBottomColors(grayImage, majlen * 0.35, cosph, sinph, cx, cy, 2);

        % get over head and over tail (maybe wing) colors
        [ c3, c4 ] = getTopAndBottomColors(grayImage, majlen * 0.6, cosph, sinph, cx, cy, 2);

        % 1st step. find head and wing on long axis line (just check 4 points' color) 
        [ vec, found ] = check4PointsColorsOnBody(vec, c1, c2, c3, c4, TH_OVER_HEAD_COLOR, TH_WING_COLOR_MAX, TH_WING_COLOR_MIN);

        if ~found
            % 1st step - check one more points
            [ c1a, c2a ] = getTopAndBottomColors(grayImage, majlen * 0.4, cosph, sinph, cx, cy, 1);
            [ c3a, c4a ] = getTopAndBottomColors(grayImage, majlen * 0.5, cosph, sinph, cx, cy, 1);
            [ vec, found ] = check4PointsColorsOnBody(vec, c1a, c2a, c3a, c4a, TH_OVER_HEAD_COLOR, TH_WING_COLOR_MAX, TH_WING_COLOR_MIN);
        end

        % 2nd step. find side back wing
        if ~found
            for j=1:3
                % check -30 and +30
                if j==2 continue; end
                ph2 = ph + pi/180 * (j-2)*30;
                cosph2 =  cos(ph2);
                sinph2 =  sin(ph2);
                [ c5, c6 ] = getTopAndBottomColors(grayImage, majlen * 0.45, cosph2, sinph2, cx, cy, 2);
                if abs(c5 - c6) > TH_WING_BG_DIFF_COLOR
                    % wing should connected body and over-wing should white
                    % because some time miss-detects next side body.
                    [ c7, c8 ] = getTopAndBottomColors(grayImage, majlen * 0.4, cosph2, sinph2, cx, cy, 2);
                    [ c9, c10 ] = getTopAndBottomColors(grayImage, majlen * 0.6, cosph2, sinph2, cx, cy, 2);
                    % if c6 is wing, check colors on line.
                    if (c6 - c8) > -5 && (c10 - c6) > 5
                        found = true;
                        break;
                    % if c5 is wing, check colors on line.
                    elseif (c5 - c7) > -5 && (c9 - c5) > 5
                        vec = -vec;
                        found = true;
                        break;
                    end
                end
            end
        end

        % 3rd step. check long (body) axis colors
        if ~found
            for j=0.40:0.05:0.55
                [ c5, c6 ] = getTopAndBottomColors(grayImage, majlen * j, cosph, sinph, cx, cy, 2);
                if c6 > TH_OVER_HEAD_COLOR && TH_WING_COLOR_MIN < c5 && c5 < TH_WING_COLOR_MAX % c5 should be wing & c6 should be over head
                    vec = -vec;
                    found = true;
                    break
                elseif c5 > TH_OVER_HEAD_COLOR && TH_WING_COLOR_MIN < c6 && c6 < TH_WING_COLOR_MAX % c6 should be wing & c5 should be over head
                    found = true;
                    break;
                elseif (c5 - c6) > TH_HEAD_WING_DIFF_COLOR && TH_WING_COLOR_MIN < c5
                    % c6 should be head. so flip now
                    vec = -vec;
                    found = true;
                    break;
                elseif (c6 - c5) > TH_HEAD_WING_DIFF_COLOR && TH_WING_COLOR_MIN < c6
                    % c5 should be head.
                    found = true;
                    break;
                end
            end
        end
        % hmm...not detected well
        if ~found
            vec = vec * 0;
        end
        keep_direction(:,i) = vec;
        keep_angle(:,i) = angle;
    end
end
