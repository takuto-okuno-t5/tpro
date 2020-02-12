%%
function [ wing_angles ] = findWingAngle(angle, colors, step)
    % init
    wing_angles = nan(2, 1, 'single'); % allocate memory

    % constant params
    wingColorTh = [90, 130, 130]; % circle wing color detection threshold
    stepNum = size(colors,2);

    % find right wing
    for k=1:3
        colors(k,:) = smooth(colors(k,:), 3, 'moving');
    end
    rstart(1) = floor(80/step) + 1;
    rstart(2) = floor(70/step) + 1;
    rstart(3) = floor(60/step) + 1;
    rend = floor(180/step) + 1; % 19 should be 180 degree
    wb = nan(1,3); we = nan(1,3);
    for k=1:3
        WING_COL_TH = wingColorTh(k);
        for j=rstart(k):rend
            if((colors(k,j) >= WING_COL_TH) && (colors(k,j+1) >= WING_COL_TH))
                if isnan(wb(k))
                    wb(k) = j;
                end
                we(k) = j+1;
            elseif((colors(k,j) < WING_COL_TH) && (colors(k,j+1) < WING_COL_TH)) && ~isnan(wb(k))
                break;
            end
        end
    end
    wangle = ((wb+we)./2 - 1) .* step;
    wing_angles(1,1) = angle + nanmean(wangle);

    % find left wing
    lstart = stepNum + 2 - rstart;
    lend = stepNum +2 - rend;
    wb = nan(1,3); we = nan(1,3);
    for k=1:3
        WING_COL_TH = wingColorTh(k);
        for j=lstart(k):-1:lend
            if((colors(k,j) >= WING_COL_TH) && (colors(k,j-1) >= WING_COL_TH))
                if isnan(wb(k))
                    wb(k) = j;
                end
                we(k) = j-1;
            elseif((colors(k,j) < WING_COL_TH) && (colors(k,j-1) < WING_COL_TH)) && ~isnan(wb(k))
                break;
            end
        end
    end
    wangle = (stepNum - ((wb+we)./2 - 1)) .* step;
    wing_angles(2,1) = angle - nanmean(wangle);
end
