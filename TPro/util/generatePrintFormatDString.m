%% generate format string
function save_string = generatePrintFormatDString(flyNum)
    save_string = '%d';
    for s_count = 2:flyNum
        save_string = [save_string '\t%d'];
    end
    save_string = [save_string '\n'];
end