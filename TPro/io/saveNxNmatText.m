%% save NxN mat result file
function saveNxNmatText(dataFileName, header, result)
    fp = fopen([dataFileName '.txt'], 'wt');
    % output header
    if ~isempty(header)
        headerString = generatePrintHeaderString(header);
        fprintf(fp, headerString);
    end

    % output file
    flyNum = size(result,2);
    fmtString = generatePrintFormatDString(flyNum);
    for i = 1:size(result,1)
        % export text data
        fprintf(fp, fmtString, result(i,:));
    end
    fclose(fp);
end
