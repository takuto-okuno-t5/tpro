%% select ROI files
function [count, figureWindow] = selectRoiFiles(csvFileName, shuttleVideo, grayImage)
    if exist(csvFileName, 'file')
        roiTable = readtable(csvFileName,'ReadVariableNames',false);
        roiFiles = table2cell(roiTable);
        fileCount = length(roiFiles);
    else
        % show file select modal
        [fileNames, imagePath, filterIndex] = uigetfile( {  ...
            '*.*',  'All Files (*.*)'}, ...
            'Pick a file', ...
            'MultiSelect', 'on', '.');

        if ~filterIndex
            fileCount = 0;
        elseif ischar(fileNames)
            fileCount = 1;
        else
            fileCount = size(fileNames,2);
        end

        % process all selected files
        roiFiles = {};
        for i = 1:fileCount
            if fileCount > 1
                fileName = fileNames{i};
            else
                fileName = fileNames;
            end
            roiFiles = [roiFiles; [imagePath fileName]];
        end
    end

    for i=1:fileCount
        % create new roi window
        figureWindow = figure('name','selecting roi','NumberTitle','off');
        set(figureWindow, 'name', ['select roi for ', shuttleVideo.name, ' (' num2str(i) ')']);

        roiFileName = roiFiles{i};
        if exist(roiFileName, 'file')
            try
                roiImage = imread(roiFileName);
                roiImage = im2double(roiImage);
                img = double(grayImage).*(imcomplement(roiImage*0.5));
                img = uint8(img);
            catch e
                errordlg(['failed to load a ROI image file : ' roiFileName], 'Error');
                count = 0;
                return;
            end
            imshow(img)
        end
        pause(0.1);
    end

    % save roi.csv
    T = array2table(roiFiles);
    writetable(T,csvFileName,'WriteVariableNames',false);
    count = fileCount;

    selection = questdlg('Do you finish to select ROI images?',...
                         'Confirmation',...
                         'Yes','Reset','Yes');
    switch selection
    case 'Reset'
        delete(csvFileName);
        count = -1;
    end
end