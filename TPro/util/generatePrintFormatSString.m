%% generate format string
function save_string = generatePrintFormatSString(flyNum)
    save_string = '%s';
    for s_count = 2:flyNum
        save_string = [save_string '\t%s'];
    end
    save_string = [save_string '\n'];
end