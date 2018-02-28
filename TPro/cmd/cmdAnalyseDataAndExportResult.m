%%
function cmdAnalyseDataAndExportResult(handles)
    inputListFile = getInputListFile();
    if ~exist(inputListFile, 'file')
        errordlg('please select movies before operation.', 'Error');
        return;
    end
    vl = load(inputListFile);
    videoPath = vl.videoPath;
    videoFiles = vl.videoFiles;

    % read tpro configuration
    dcdRadius = readTproConfig('dcdRadius', 7.5);
    dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);
    nnHeight = readTproConfig('nnHeight', 5);
    nnAlgorithm = readTproConfig('nnAlgorithm', 'single');

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

    disp('start to analyse data');
    tic;
    % analysing process
    joinHeader = {};
    joinData = [];
    for data_th = 1:size(records,1)
        if ~records{data_th, 1}
            continue;
        end
        name = records{data_th, 2};
        fpsNum = records{data_th, 7};
        roiNum = records{data_th, 10};
        mmPerPixel = records{data_th, 9};
        height = nnHeight / mmPerPixel;
        algorithm = nnAlgorithm; 

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
        if ~exist(matFile,'file')
            continue;
        end
        load(matFile);
        % load group analysing result
        matFile = [confPath 'multi/nn_groups.mat'];
        if exist(matFile,'file')
            grp = load(matFile);
        else
            grp = [];
        end

        % calc velocity etc
        [vxy, accVxy, updownVxy, dir, sideways, sidewaysVelocity, av, ecc, rWingAngle, lWingAngle, rWingAngleV, lWingAngleV] = calcVelocityDirEtc(keep_data, fpsNum, mmPerPixel);
        data = [];

        % get data
        switch(handles.analyseSrc)
        case 'x'
            data = keep_data{2};
        case 'y'
            data = keep_data{1};
        case 'vxy'
            data = vxy;
        case 'dir'
            data = dir;
        case 'av'
            data = av;
        case 'ecc'
            data = ecc;
        case 'rwa'
            data = rWingAngle;
        case 'lwa'
            data = lWingAngle;
        case 'chase'
            trackingInfo = struct;
            trackingInfo.fpsNum = fpsNum;
            trackingInfo.mmPerPixel = mmPerPixel;
            trackingInfo.keep_data = keep_data;
            trackingInfo.vxy = vxy;
            trackingInfo.accVxy = accVxy;
            trackingInfo.updownVxy = updownVxy;
            trackingInfo.dir = dir;
            data = trapezoidFindChase(trackingInfo, []);
        case 'be'
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
            data = trapezoidBehaviorClassifier(trackingInfo);
        case 'dcd'
            r = dcdRadius / mmPerPixel;
            cnr = dcdCnRadius / mmPerPixel;
            [means, data] = calcLocalDensityDcdAllFly(keep_data{1}, keep_data{2}, [], r, cnr); % empty roiMask
        case 'group'
            if isempty(grp)
                result = calcClusterNNAllFly(keep_data{1}, keep_data{2}, [], algorithm, height); % ignore roiMask
                [data, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            else
                data = grp.result;
            end
        case 'gcount'
            if isempty(grp)
                result = calcClusterNNAllFly(keep_data{1}, keep_data{2}, [], algorithm, height); % ignore roiMask
                [result, data, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            else
                data = grp.groupCount;
            end
        case 'gcalc'
            result = calcClusterNNAllFly(keep_data{1}, keep_data{2}, [], algorithm, height); % ignore roiMask
            [result, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            [areas, groupAreas, groupCenterX, groupCenterY, groupOrient, groupEcc] = calcGroupArea(keep_data{1}, keep_data{2}, result, roiMasks{1}, height); % dummy roiMask
            areas = areas * mmPerPixel * mmPerPixel;
            groupAreas = groupAreas * mmPerPixel * mmPerPixel;
            save([confPath 'multi/nn_groups.mat'], 'result', 'groupCount', 'biggestGroup', 'biggestGroupFlyNum', ...
                'areas', 'groupAreas', 'groupCenterX', 'groupCenterY', 'groupOrient', 'groupEcc');
        case 'garea'
            if ~isempty(grp)
                data = grp.areas;
            end
        otherwise
            disp(['unsupported data type : ' handles.analyseSrc]);
            continue;
        end
        
        if isempty(data)
            continue;
        end

        % set each ROI data
        if roiNum > 1
            roiData = {};
            for i=1:roiNum
                rd = processDataByRoi(keep_data, img_h, img_w, roiMask{i}, data);
                roiData = [roiData, rd];
            end
        else
            roiData = {data};
        end

        % set range
        startRow = 1;
        endRow = size(data,1);
        if ~isempty(handles.range)
            startRow = str2num(handles.range{1});
            if ~strcmp(handles.range{2},'end')
                endRow = str2num(handles.range{2});
            end
        end
        for i=1:roiNum
            roiData{i} = roiData{i}(startRow:endRow,:);
        end

        % process data each ROI
        if ~isempty(handles.procOps)
            for i=1:roiNum
                roiData{i} = processDataByCommand(handles.procOps, roiData{i}, fpsNum);
            end
        end

        % save data as text
        if isempty(handles.join)
            for i=1:roiNum
                % export file
                if isempty(handles.export)
                    outputPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
                    dataFileName = [outputPath name '_' filename '_' handles.analyseSrc];
                else
                    outputPath = [handles.export '/'];
                    dataFileName = [outputPath name '_' filename '_roi' num2str(i) '_' handles.analyseSrc];
                end
                disp(['exporting a file : ' dataFileName]);
                saveNxNmatText(dataFileName, [], roiData{i});
            end
        else
            disp(['joining a data : ' name]);
            joinHeader = [joinHeader, name];
            for i=1:roiNum
                if ~isempty(joinData)
                    if size(joinData,1) > size(roiData{i},1)
                        roiData{i}(size(joinData,1),1) = NaN;
                    elseif size(joinData,1) < size(roiData{i},1)
                        joinData(size(roiData{i},1),1) = NaN;
                    end
                end
                joinData = [joinData, roiData{i}];
            end
        end
    end

    % save joined data as text
    if ~isempty(handles.join) && ~isempty(handles.export)
        if handles.join == 0
            joinHeader = {};
        end
        outputPath = [handles.export '/'];
        dataFileName = [outputPath name '_' handles.analyseSrc '_joined'];
        saveNxNmatText(dataFileName, joinHeader, joinData);
    end

    time = toc;
    disp(['analysing data ... done : ' num2str(time) 's']);
end