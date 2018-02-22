%%
function cmdCalcPIAndExportResult(handles)
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

    disp('start to export PI');
    tic;
    % calc PI
    for data_th = 1:size(records,1)
        if ~records{data_th, 1}
            continue;
        end
        name = records{data_th, 2};
        roiNum = records{data_th, 10};

        % get path of output folder
        confPath = [videoPath videoFiles{data_th} '_tpro/'];
        filename = [sprintf('%05d',records{data_th,4}) '_' sprintf('%05d',records{data_th,5})];

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
        load(strcat(confPath,'multi/detect_',filename,'.mat'));

        % calc and save PI result
        for i=1:size(handles.pi,1)
            roi1 = handles.pi(i,1);
            roi2 = handles.pi(i,2);
            % calc PI
            result = calcPI(X, Y, {roiMasks{roi1}, roiMasks{roi2}});
            % export file
            if isempty(handles.export)
                outputPath = [confPath 'detect_output/'];
            else
                outputPath = [handles.export '/'];
            end
            dataFileName = [outputPath name '_' filename '_pi_roi_' num2str(handles.pi(i,1)) '_vs_' num2str(handles.pi(i,2))];
            saveDetectionPIResultText(dataFileName, result);
        end
    end
    time = toc;
    disp(['exporting PI ... done : ' num2str(time) 's']);
end