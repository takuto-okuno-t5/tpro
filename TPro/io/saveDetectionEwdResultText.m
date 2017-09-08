%% save detection ewd result files
function saveDetectionEwdResultText(dataFileName, X, Y, i, roiMasks, r)
    write_file_ewd = fopen([dataFileName '_ewd.txt'], 'wt');

    % cook raw data before saving
    end_row = size(X, 1) - 2;
    for row_count = 1:end_row
        fy = X(row_count,:);
        fx = Y(row_count,:);
        flyNum = length(fx);
        for j = flyNum:-1:1
            y = round(fy(j));
            x = round(fx(j));
            if (y < 1) || (x < 1) || isnan(y) || isnan(x) || roiMasks{i}(y,x) <= 0
                fx(j) = [];
                fy(j) = [];
            end
        end

        [ewd, ewdfly] = calcLocalDensityEwdFrame(fy,fx,r);
        % export ewd
        fprintf(write_file_ewd, '%d\n', ewd);
    end
    fclose(write_file_ewd);
end
