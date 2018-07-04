%% generate format string
function save_string = generatePrintFormatCellString(data)
    save_string = '';
    for i = 1:length(data)
        if i>1
            save_string = [save_string '\t'];
        end
        if ischar(data{i})
            save_string = [save_string '%s'];
        elseif isinteger(data{i})
            save_string = [save_string '%d'];
        else
            save_string = [save_string '%.7f'];
        end
    end
    save_string = [save_string '\n'];
end