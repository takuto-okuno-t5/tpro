%%
function [paths, files, items] = getInputList()
    global gVideoPaths;
    global gVideoFiles;
    global gTebleItems;
    paths = {};
    files = {};
    items = {};
    if isempty(gVideoPaths)
        inputListFile = getInputListFile();
        if ~exist(inputListFile, 'file')
            return;
        end
        vl = load(inputListFile);
        if ~isfield(vl, 'videoPaths')
            return;
        end
        gVideoPaths = vl.videoPaths;
        gVideoFiles = vl.videoFiles;
        gTebleItems = {};

        for i = 1:size(gVideoFiles,1)
            row = {gVideoFiles{i}, gVideoPaths{i}};
            gTebleItems = [gTebleItems; row];
        end
    end
    paths = gVideoPaths;
    files = gVideoFiles;
    items = gTebleItems;
end