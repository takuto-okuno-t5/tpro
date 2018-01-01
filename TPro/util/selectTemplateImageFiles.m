%% select template image files
function [fileCount] = selectTemplateImageFiles(confPath, basecount)
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
    imageFiles = {};
    for i = 1:fileCount
        if fileCount > 1
            fileName = fileNames{i};
        else
            fileName = fileNames;
        end
        imageFiles = [imageFiles; [imagePath fileName]];
    end

    % load and copy to working directory
    for i=1:fileCount
        fileName = imageFiles{i};
        if exist(fileName, 'file')
            try
                tmplImage = imread(fileName);
                if (i+basecount) == 1
                    outname = [confPath 'template.png'];
                else
                    outname = [confPath 'template' num2str(i+basecount) '.png'];
                end
                imwrite(tmplImage, outname);
            catch e
                errordlg(['failed to load a template image file : ' fileName], 'Error');
                fileCount = 0;
                return;
            end
        end
    end
end