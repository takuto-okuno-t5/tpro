%%
function cmdCalcPIAndExportResult(handles)
    [videoPaths, videoFiles, tebleItems] = getInputList();
    if isempty(videoPaths)
        errordlg('please select movies before operation.', 'Error');
        return;
    end

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

    disp('start to export PI');
    tic;
    % calc PI
    for data_th = 1:size(records,1)
        if ~records{data_th, 1}
            continue;
        end
        name = records{data_th, 2};
        fpsNum = records{data_th, 7};
        roiNum = records{data_th, 10};
        mmPerPixel = records{data_th, 9};

        % get path of output folder
        confPath = [videoPaths{data_th} videoFiles{data_th} '_tpro/'];
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
        for j=1:size(handles.pi,1)
            roi1 = handles.pi(j,1);
            roi2 = handles.pi(j,2);
            % calc PI
            data = calcPI(X, Y, {roiMasks{roi1}, roiMasks{roi2}});

            % set range
            startRow = 1;
            endRow = size(data,1);
            rangeName = '';
            if ~isempty(handles.range)
                startRow = str2num(handles.range{1});
                if ~strcmp(handles.range{2},'end')
                    endRow = str2num(handles.range{2});
                    if endRow > size(data,1)
                        endRow = size(data,1);
                    end
                end
                rangeName = [num2str(startRow) '-' num2str(endRow) '_'];
            end
            data = data(startRow:endRow,:);

            % process data each ROI
            if ~isempty(handles.procOps)
                data = processDataByCommand(handles.procOps, data, fpsNum);
            end
            
            % export file
            if isempty(handles.export)
                outputPath = [confPath 'detect_output/'];
            else
                outputPath = [handles.export '/'];
            end
            dataFileName = [outputPath name '_' filename '_pi_roi_' num2str(handles.pi(j,1)) '_vs_' num2str(handles.pi(j,2))];
            saveNx1matText(dataFileName, data);
        end
    end
    time = toc;
    disp(['exporting PI ... done : ' num2str(time) 's']);
end