%% save tracking result files
function saveDetectionResultText(dataFileName, X, Y, i, img_h, roiMasks, dcdparam)
    write_file_cnt = fopen([dataFileName '_count.txt'], 'wt');
    write_file_x = fopen([dataFileName '_x.txt'], 'wt');
    write_file_y = fopen([dataFileName '_y.txt'], 'wt');
    if ~isempty(dcdparam)
        write_file_dcd = fopen([dataFileName '_dcd.txt'], 'wt');
        if exist(dcdparam{3},'file')
            write_file_dcdp = fopen([dataFileName '_dcdp.txt'], 'wt');
            load(dcdparam{3}); % load percentile file
        end
    end

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

        if ~isempty(dcdparam)
            [dcd, dcdfly] = calcLocalDensityDcdFrame(fy,fx,dcdparam{1},dcdparam{2});
            fprintf(write_file_dcd, '%d\n', dcd);
            
            % output percentile value
            if exist(dcdparam{3},'file')
                % count flynums
                flyCounts = length(fx);
                dcdp = calcLocalDensityDcdPercentile(dcd, flyCounts, numValues, edges, values);
                fprintf(write_file_dcdp, '%d\n', dcdp);
            end
        end
    end

    fclose(write_file_cnt);
    fclose(write_file_x);
    fclose(write_file_y);
    if ~isempty(dcdparam)
        fclose(write_file_dcd);
        if exist(dcdparam{3},'file')
            fclose(write_file_dcdp);
        end
    end
end
