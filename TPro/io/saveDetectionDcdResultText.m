%% save detection dcd result files
function saveDetectionDcdResultText(dataFileName, X, Y, i, roiMasks, r, cnr)
    write_file_dcd = fopen([dataFileName '_dcd.txt'], 'wt');

    % cook raw data before saving
    end_row = size(X, 2);
    for row_count = 1:end_row
        fy = X{row_count};
        fx = Y{row_count};
        flyNum = length(fx);
        for j = flyNum:-1:1
            y = round(fy(j));
            x = round(fx(j));
            if (y < 1) || (x < 1) || isnan(y) || isnan(x) || roiMasks{i}(y,x) <= 0
                fx(j) = [];
                fy(j) = [];
            end
        end

        [dcd, dcdfly] = calcLocalDensityDcdFrame(fy,fx,r,cnr);
        % export dcd
        fprintf(write_file_dcd, '%d\n', dcd);
    end
    fclose(write_file_dcd);
end
