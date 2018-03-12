%%
function cmdCalcDcdAndExportResult(handles)
    [videoPaths, videoFiles, tebleItems] = getInputList();
    if isempty(videoPaths)
        errordlg('please select movies before operation.', 'Error');
        return;
    end

    % read tpro configuration
    dcdRadius = readTproConfig('dcdRadius', 7.5);
    dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);

    % load configuration files
    videoFileNum = size(videoFiles,1);
    records = {};
    for i = 1:videoFileNum
        confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
        if ~exist(confFileName, 'file')
            errordlg(['configuration file not found : ' confFileName], 'Error');
            return;
        end

        confTable = readtable(confFileName);
        C = table2cell(confTable);
        C = checkConfigCompatibility(C);
        records = [records; C];
    end

    disp('start to export DCD');
    tic;
    % calc ewd score
    for data_th = 1:size(records,1)
        if ~records{data_th, 1}
            continue;
        end
        name = records{data_th, 2};
        roiNum = records{data_th, 10};
        mmPerPixel = records{data_th, 9};
        r = dcdRadius / mmPerPixel;
        cnr = dcdCnRadius / mmPerPixel;

        % get path of output folder
        confPath = [videoPaths{data_th} videoFiles{data_th} '_tpro/'];
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
                roiMasks = [roiMasks, im2single(img)];
            end
        end

        % load detection & tracking result
        matFile = [confPath 'multi/detect_' filename,'.mat'];
        if exist(matFile,'file')
            load(matFile);
            means = calcLocalDensityDcd(X, Y, [], r, cnr); % empty roiMask
            means = means';
        end
        matFile = [confPath 'multi/track_' filename,'.mat'];
        if exist(matFile,'file')
            load(matFile);
            [means, results] = calcLocalDensityDcdAllFly(keep_data{1}, keep_data{2}, [], r, cnr); % empty roiMask
        end

        % save data as text
        for i=1:roiNum
            % export file
            if exist('X', 'var')
                if isempty(handles.export)
                    outputPath = [confPath 'detect_output/' filename '_roi' num2str(i) '/'];
                    dataFileName = [outputPath name '_' filename];
                else
                    outputPath = [handles.export '/'];
                    dataFileName = [outputPath name '_' filename '_roi' num2str(i)];
                end
                disp(['exporting a file : ' dataFileName]);
                saveNxNmatRoiText2(dataFileName, X, Y, img_h, img_w, roiMasks{i}, means, 1, size(X,2), 'dcd');
            end

            % export file
            if exist('keep_data', 'var')
                if isempty(handles.export)
                    outputPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
                    dataFileName = [outputPath name '_' filename];
                else
                    outputPath = [handles.export '/'];
                    dataFileName = [outputPath name '_' filename '_track_roi' num2str(i)];
                end
                disp(['exporting a file : ' dataFileName]);
                saveNxNmatRoiText(dataFileName, keep_data, img_h, img_w, roiMasks{i}, results, 1, size(results,1), 'dcd');
            end
        end
    end
    time = toc;
    disp(['exporting DCD ... done : ' num2str(time) 's']);
end