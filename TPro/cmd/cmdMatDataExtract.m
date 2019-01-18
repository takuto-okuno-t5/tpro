%%
function cmdMatDataExtract(handles)
    [videoPaths, videoFiles, tebleItems] = getInputList();
    if isempty(videoPaths)
        errordlg('please select movies before operation.', 'Error');
        return;
    end

    % read tpro configuration
    meanBlobMajor = readTproConfig('meanBlobMajor', 3.56);

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

    disp('start to extract mat (tracking) data');
    tic;
    % init output data
    tidx = handles.extMatData;
    keep_data_out = {};
    assignCost_out = [];
    keep_count_out = [];
    keep_mean_blobmajor = [];
    keep_mean_blobminor = [];
    X_out = {};
    Y_out = {};
    keep_direction_sorted_out = {};
    keep_ecc_sorted_out = {};
    keep_angle_sorted_out = {};
    keep_areas_out = {};
    keep_major_axis_out = {};
    keep_minor_axis_out = {};
    keep_wings_sorted_out = {};
    % merging process
    for data_th = 1:size(records,1)
        if ~records{data_th, 1}
            continue;
        end
        name = records{data_th, 2};
        fpsNum = records{data_th, 7};
        roiNum = records{data_th, 10};
        mmPerPixel = records{data_th, 9};
        mean_blobmajor = meanBlobMajor / mmPerPixel;

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

        % load detection result
        matFile = [confPath 'multi/detect_' filename,'.mat'];
        if ~exist(matFile,'file')
            continue;
        end
        load(matFile);
        matFile = [confPath 'multi/detect_' filename,'keep_count.mat'];
        if ~exist(matFile,'file')
            continue;
        end
        load(matFile);
        % load tracking result
        matFile = [confPath 'multi/track_' filename,'.mat'];
        if exist(matFile,'file')
            load(matFile);
        end

        % merge data 
        % detect_#####_######.mat
        for i=1:length(X)
            if i>length(X_out)
                X_out{i} = X{i};
                Y_out{i} = Y{i};
                keep_direction_sorted_out{i} = keep_direction_sorted{i};
                keep_ecc_sorted_out{i} = keep_ecc_sorted{i};
                keep_angle_sorted_out{i} = keep_angle_sorted{i};
                keep_areas_out{i} = keep_areas{i};
                keep_major_axis_out{i} = keep_major_axis{i};
                keep_minor_axis_out{i} = keep_minor_axis{i};
                keep_wings_sorted_out{i} = keep_wings_sorted{i};
            else
                X_out{i} = [X_out{i};X{i}];
                Y_out{i} = [Y_out{i};Y{i}];
                keep_direction_sorted_out{i} = [keep_direction_sorted_out{i},keep_direction_sorted{i}];
                keep_ecc_sorted_out{i} = [keep_ecc_sorted_out{i},keep_ecc_sorted{i}];
                keep_angle_sorted_out{i} = [keep_angle_sorted_out{i},keep_angle_sorted{i}];
                keep_areas_out{i} = [keep_areas_out{i},keep_areas{i}];
                keep_major_axis_out{i} = [keep_major_axis_out{i},keep_major_axis{i}];
                keep_minor_axis_out{i} = [keep_minor_axis_out{i},keep_minor_axis{i}];
                keep_wings_sorted_out{i} = [keep_wings_sorted_out{i},keep_wings_sorted{i}];
            end
        end
        % detect_#####_#####keep_count.mat
        for i=1:length(keep_count)
            if i>length(keep_count_out)
                keep_count_out(i) = keep_count(i);
                keep_mean_blobmajor_out(i) = keep_mean_blobmajor(i);
                keep_mean_blobminor_out(i) = keep_mean_blobminor(i);
            else
                keep_count_out(i) = keep_count_out(i) + keep_count(i);
                keep_mean_blobmajor_out(i) = (keep_mean_blobmajor_out(i) + keep_mean_blobmajor(i)) / 2;
                keep_mean_blobminor_out(i) = (keep_mean_blobminor_out(i) + keep_mean_blobminor(i)) / 2;
            end
        end
        % track_#####_#####.mat
        for i=1:10
            kd = keep_data{i}(:,tidx);
            if i>length(keep_data_out)
                keep_data_out{i} = kd;
            else
                outsize = size(keep_data_out{i},1);
                if outsize > size(kd,1)
                    tmp = nan(outsize,size(kd,2));
                    tmp(1:size(kd,1),:) = kd;
                    keep_data_out{i} = [keep_data_out{i}, tmp];
                elseif outsize < size(kd,1)
                    tmp = nan(size(kd,1),size(keep_data_out{i},2));
                    tmp(1:outsize,:) = keep_data_out{i};
                    keep_data_out{i} = [tmp,kd];
                else
                    keep_data_out{i} = [keep_data_out{i}, kd];
                end
            end
        end
        if isempty(assignCost_out)
            assignCost_out = assignCost;
        else
            outsize = size(assignCost_out,1);
            if outsize > size(assignCost,1)
                tmp = nan(outsize,1);
                tmp(1:size(assignCost,1),:) = assignCost;
                assignCost_out = assignCost_out + tmp;
            elseif outsize < size(assignCost,1)
                tmp = nan(size(assignCost,1),1);
                tmp(1:outsize,:) = assignCost_out;
                assignCost_out = tmp + assignCost;
            else
                assignCost_out = assignCost_out + assignCost; % dummy
            end
        end
    end
    % save mat data
    if ~isempty(handles.export)
        outputPath = [handles.export '/'];
        start_frame = 1;
        end_frame = size(keep_data_out{1},1);
        filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
        % detecting result
        X = X_out;
        Y = Y_out;
        keep_direction_sorted = keep_direction_sorted_out;
        keep_ecc_sorted = keep_ecc_sorted_out;
        keep_angle_sorted = keep_angle_sorted_out;
        keep_areas = keep_areas_out;
        keep_major_axis = keep_major_axis_out;
        keep_minor_axis = keep_minor_axis_out;
        keep_wings_sorted = keep_wings_sorted_out;
        save([outputPath 'detect_' filename '.mat'],  'X','Y', 'keep_direction_sorted', 'keep_ecc_sorted', 'keep_angle_sorted', 'keep_areas', 'keep_major_axis', 'keep_minor_axis', 'keep_wings_sorted');
        keep_count = keep_count_out;
        keep_mean_blobmajor = keep_mean_blobmajor_out;
        keep_mean_blobminor = keep_mean_blobminor_out;
        save([outputPath 'detect_' filename 'keep_count.mat'], 'keep_count', 'keep_mean_blobmajor', 'keep_mean_blobminor');
        % tracking result
        keep_data = keep_data_out;
        assignCost = assignCost_out;
        trackHistory = {};
        save([outputPath 'track_' filename '.mat'], 'keep_data', 'assignCost', 'trackHistory', '-v7.3');
    end

    time = toc;
    disp(['merge mat data ... done : ' num2str(time) 's']);
end

