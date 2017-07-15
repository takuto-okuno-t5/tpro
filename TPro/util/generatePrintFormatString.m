%% generate format string
function save_string = generatePrintFormatString(flyNum)
    save_string = [];
    for s_count = 1:flyNum
        save_string = [save_string '%.4f\t'];
    end
    save_string = [save_string '\n'];
end