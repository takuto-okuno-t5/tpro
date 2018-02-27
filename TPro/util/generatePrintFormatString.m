%% generate format string
function save_string = generatePrintFormatString(flyNum)
    save_string = '%d';
    for s_count = 2:flyNum
        save_string = [save_string '\t%.4f'];
    end
    save_string = [save_string '\n'];
end