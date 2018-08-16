%% save tracking result files
function saveDetectionEccAxesResultText(dataFileName, X, Y, i, img_h, roiMasks, keep_ecc_sorted, keep_major_axis, keep_minor_axis)
    write_file_x = fopen([dataFileName '_x.txt'], 'wt');
    write_file_y = fopen([dataFileName '_y.txt'], 'wt');
    write_file_ecc = fopen([dataFileName '_ecc.txt'], 'wt');
    write_file_major = fopen([dataFileName '_major.txt'], 'wt');
    write_file_minor = fopen([dataFileName '_minor.txt'], 'wt');

    % cook raw data before saving
    end_row = size(X, 2);
    for row_count = 1:end_row
        fy = X{row_count}(:);
        fx = Y{row_count}(:);
        ecc = keep_ecc_sorted{row_count}(:);
        major = keep_major_axis{row_count}(:);
        minor = keep_minor_axis{row_count}(:);
        flyNum = length(fx);
        for j = flyNum:-1:1
            y = round(fy(j));
            x = round(fx(j));
            if (y < 1) || (x < 1) || isnan(y) || isnan(x) || (~isempty(roiMasks) && roiMasks{i}(y,x) <= 0) ...
                || ecc(j) <= 0.92
                fx(j) = [];
                fy(j) = [];
                ecc(j) = [];
                major(j) = [];
                minor(j) = [];
            end
        end
        % make save string
        flyNum = length(fx);
        fmtString = generatePrintFormatString(flyNum);

        fprintf(write_file_x, fmtString, fx);
        fprintf(write_file_y, fmtString, img_h - fy);
        fprintf(write_file_ecc, fmtString, ecc);
        fprintf(write_file_major, fmtString, major);
        fprintf(write_file_minor, fmtString, minor);
    end

    fclose(write_file_x);
    fclose(write_file_y);
    fclose(write_file_ecc);
    fclose(write_file_major);
    fclose(write_file_minor);
end
