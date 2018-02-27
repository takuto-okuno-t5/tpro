%% generate format string
function save_string = generatePrintHeaderString(header)
    save_string = header{1};
    for i = 2:length(header)
        save_string = [save_string '\t' header{i}];
    end
    save_string = [save_string '\n'];
end