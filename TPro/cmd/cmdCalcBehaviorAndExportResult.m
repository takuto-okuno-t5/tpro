%%
function cmdCalcBehaviorAndExportResult(handles)
    inputListFile = getInputListFile();
    if ~exist(inputListFile, 'file')
        errordlg('please select movies before operation.', 'Error');
        return;
    end
    vl = load(inputListFile);
    videoPath = vl.videoPath;
    videoFiles = vl.videoFiles;

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

    disp('start to export behavior');
    tic;
    % calc ewd score
    for data_th = 1:size(records,1)
        if ~records{data_th, 1}
            continue;
        end
        name = records{data_th, 2};
        fpsNum = records{data_th, 7};
        roiNum = records{data_th, 10};
        mmPerPixel = records{data_th, 9};

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
                roiMasks = [roiMasks, im2single(img)];
            end
        end

        % load detection & tracking result
        matFile = [confPath 'multi/track_' filename,'.mat'];
        if exist(matFile,'file')
            load(matFile);
        end

        % calc velocity etc
        [vxy, accVxy, updownVxy, dir, sideways, sidewaysVelocity, av, ecc, rWingAngle, lWingAngle, rWingAngleV, lWingAngleV] = calcVelocityDirEtc(keep_data, fpsNum, mmPerPixel);
        trackingInfo = struct;
        trackingInfo.fpsNum = fpsNum;
        trackingInfo.vxy = vxy;
        trackingInfo.accVxy = accVxy;
        trackingInfo.updownVxy = updownVxy;
        trackingInfo.dir = dir;
        trackingInfo.sideways = sideways;
        trackingInfo.sidewaysVelocity = sidewaysVelocity;
        trackingInfo.av = av;
        trackingInfo.ecc = ecc;
        trackingInfo.rWingAngle = rWingAngle;
        trackingInfo.lWingAngle = lWingAngle;
        trackingInfo.rWingAngleV = rWingAngleV;
        trackingInfo.lWingAngleV = lWingAngleV;
        behavior = trapezoidBehaviorClassifier(trackingInfo);

        % save data as text
        for i=1:roiNum
            % export file
            if isempty(handles.export)
                outputPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
                dataFileName = [outputPath name '_' filename];
            else
                outputPath = [handles.export '/'];
                dataFileName = [outputPath name '_' filename '_roi' num2str(i)];
            end
            disp(['exporting a file : ' dataFileName]);
            saveNxNmatRoiText(dataFileName, keep_data, img_h, img_w, roiMasks{i}, behavior, 'be');
        end
    end
    time = toc;
    disp(['exporting behavior ... done : ' num2str(time) 's']);
end