%% save NxN mat result files
function saveNxNmatText(dataFileName, keep_data, img_h, img_w, roiMask, flydata, typename)
    write_file_cha = fopen([dataFileName '_' typename '.txt'],'wt');

    % cook raw data before saving
    end_row = size(keep_data{2}, 1) - 2;
    for row_count = 1:end_row
        fx = keep_data{2}(row_count, :);
        fy = keep_data{1}(row_count, :);
        Y = round(fy);
        X = round(fx);
        nanIdxY = find((Y > img_h) | (Y < 1));
        nanIdxX = find((X > img_w) | (X < 1));
        roiIdx = (X-1).*img_h + Y;
        roiIdx(isnan(roiIdx)) = 1; % TOOD: set dummy. this might be bad with empty ROI.
        roiIdx2 = find(roiMask(roiIdx) <= 0);
        nanIdx = unique([nanIdxY, nanIdxX, roiIdx2]);

        % make save string
        dataRow = flydata(row_count, :);
        dataRow(nanIdx) = NaN;
        roiFlyNum = length(dataRow);
        fmtString = generatePrintFormatDString(roiFlyNum);
        fprintf(write_file_cha, fmtString, dataRow);
    end

    fclose(write_file_cha);
end
