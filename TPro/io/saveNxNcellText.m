%% save NxN cell result file
function saveNxNcellText(dataFileName, header, result)
    fp = fopen([dataFileName '.txt'], 'wt');
    % output header
    if ~isempty(header)
        headerString = generatePrintHeaderString(header);
        fprintf(fp, headerString);
    end

    % output file
    line = result(1,:);
    fmtString = generatePrintFormatCellString(line);
    for i = 1:size(result,1)
        % export text data
        fprintf(fp, fmtString, result{i,:});
    end
    fclose(fp);
end
