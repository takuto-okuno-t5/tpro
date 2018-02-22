%% save Nx1 mat result file
function saveNx1matText(dataFileName, result)
    fp = fopen([dataFileName '.txt'], 'wt');
    % output file
    for row_count = 1:size(result,1)
        % export text data
        fprintf(fp, '%d\n', result(row_count));
    end
    fclose(fp);
end
