%%
function inputListFile = getTproEtcFile(filename)
    global exePath;
    if ~isempty(exePath)
        inputListFile = [exePath '/etc/' filename];
    else
        inputListFile = ['etc/' filename];
    end
end