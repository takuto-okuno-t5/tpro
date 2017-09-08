%% generate format string
function save_string = generatePrintFormatDString(flyNum)
    save_string = [];
    for s_count = 1:flyNum
        save_string = [save_string '%d\t'];
    end
    save_string = [save_string '\n'];
end