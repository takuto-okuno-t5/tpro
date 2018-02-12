%% save detection PI result files
function saveDetectionPIResultText(dataFileName, result)
    write_file_pi = fopen([dataFileName '.txt'], 'wt');
    % output file
    for row_count = 1:size(result,1)
        % export dcd
        fprintf(write_file_pi, '%d\n', result(row_count));
    end
    fclose(write_file_pi);
end
