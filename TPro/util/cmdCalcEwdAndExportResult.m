%%
function cmdCalcEwdAndExportResult(handles)
    inputListFile = 'etc/input_videos.mat';
    if ~exist(inputListFile, 'file')
        errordlg('please select movies before operation.', 'Error');
        return;
    end
    vl = load(inputListFile);
    videoPath = vl.videoPath;
    videoFiles = vl.videoFiles;

    % read tpro configuration
    radius = 5;
    tproConfig = 'etc/tproconfig.csv';
    if exist(tproConfig, 'file')
        tproConfTable = readtable(tproConfig,'ReadRowNames',true);
        values = tproConfTable{'ewdRadius',1};
        if size(values,1) > 0
            radius = values(1);
        end
    end

    % load configuration files
    videoFileNum = size(videoFiles,1);
    records = {};
    for i = 1:videoFileNum
        confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
        if ~exist(confFileName, 'file')
            errordlg(['configuration file not found : ' confFileName], 'Error');
            return;
        end

        confTable = readtable(confFileName);
        C = table2cell(confTable);
        records = [records; C];
    end

    % calc ewd score
    for data_th = 1:size(records,1)
        if ~records{data_th, 1}
            continue;
        end
        name = records{data_th, 2};
        roiNum = records{data_th, 10};
        mmPerPixel = records{data_th, 9};
        r = radius / mmPerPixel;

        % get path of output folder
        confPath = [videoPath videoFiles{data_th} '_tpro/'];
        filename = [sprintf('%05d',records{data_th,4}) '_' sprintf('%05d',records{data_th,5})];

        % load background image
        bgImageFile = [confPath 'background.png'];
        if exist(bgImageFile, 'file')
            bgImage = imread(bgImageFile);
            img_h = size(bgImage,1);
            img_w = size(bgImage,2);
        else
            img_h = 1024;
            img_w = 1024;
        end
    
        % load roi image file
        roiMasks = {};
        csvFileName = [confPath 'roi.csv'];
        if exist(csvFileName, 'file')
            roiTable = readtable(csvFileName,'ReadVariableNames',false);
            roiFiles = table2cell(roiTable);
        end
        for i=1:roiNum
            if exist(csvFileName, 'file')
                roiFileName = roiFiles{i};
            else
                if i==1 idx=''; else idx=num2str(i); end
                roiFileName = [confPath 'roi' idx '.png'];
            end
            if exist(roiFileName, 'file')
                img = imread(roiFileName);
                roiMasks = [roiMasks, im2double(img)];
            end
        end

        % load detection & tracking result
        load(strcat(confPath,'multi/track_',filename,'.mat'));

        % save data as text
        for i=1:roiNum
            outputPath = [confPath 'detect_output/' filename '_roi' num2str(i) '/'];
            dataFileName = [outputPath name '_' filename];
            saveDetectionEwdResultText(dataFileName, keep_data{1}, keep_data{2}, i, roiMasks, r);

            outputPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
            dataFileName = [outputPath name '_' filename];
            saveTrackingEwdResultText(dataFileName, keep_data, img_h, img_w, roiMasks{i}, r);
        end
    end
end