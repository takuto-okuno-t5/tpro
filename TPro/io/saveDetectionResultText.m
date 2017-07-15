%% save tracking result files
function saveDetectionResultText(dataFileName, X, Y, i, img_h, roiMasks)
    write_file_cnt = fopen([dataFileName '_count.txt'], 'wt');
    write_file_x = fopen([dataFileName '_x.txt'], 'wt');
    write_file_y = fopen([dataFileName '_y.txt'], 'wt');

    % cook raw data before saving
    end_row = size(X, 2);
    for row_count = 1:end_row
        fy = X{row_count}(:);
        fx = Y{row_count}(:);
        flyNum = length(fx);
        for j = flyNum:-1:1
            y = round(fy(j));
            x = round(fx(j));
            if (y < 1) || (x < 1) || isnan(y) || isnan(x) || roiMasks{i}(y,x) <= 0
                fx(j) = [];
                fy(j) = [];
            end
        end
        % make save string
        flyNum = length(fx);
        fmtString = generatePrintFormatString(flyNum);

        fprintf(write_file_cnt, '%d\n', flyNum);
        fprintf(write_file_x, fmtString, fx);
        fprintf(write_file_y, fmtString, img_h - fy);
    end

    fclose(write_file_cnt);
    fclose(write_file_x);
    fclose(write_file_y);
end
