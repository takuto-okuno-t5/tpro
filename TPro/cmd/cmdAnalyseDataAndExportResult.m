%%
function cmdAnalyseDataAndExportResult(handles)
    [videoPaths, videoFiles, tebleItems] = getInputList();
    if isempty(videoPaths)
        errordlg('please select movies before operation.', 'Error');
        return;
    end

    % read tpro configuration
    dcdRadius = readTproConfig('dcdRadius', 7.5);
    dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);
    nnHeight = readTproConfig('nnHeight', 5);
    nnAlgorithm = readTproConfig('nnAlgorithm', 'single');
    groupRejectDist = readTproConfig('groupRejectDist', 700);
    groupDuration = readTproConfig('groupDuration', 1);

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
        % load group analysing result
        matFile = [confPath 'multi/nn_groups.mat'];
        if exist(matFile,'file')
            grp = load(matFile);
        else
            grp = [];
        end
        % load group tracking result
        matFile = [confPath 'multi/nn_groups_tracking.mat'];
        if exist(matFile,'file')
            grptrk = load(matFile);
        else
            grptrk = [];
        end
        % load dcd result
        matFile = [confPath 'multi/aggr_dcd_result_tracking.mat'];
        if exist(matFile,'file')
            dcd = load(matFile);
        else
            dcd = [];
        end
        % load be result
        annoFileName = [confPath 'multi/annotation_' filename '.mat'];
        if exist(annoFileName, 'file')
            be = load(annoFileName);
        else
            be = [];
        end

        % calc velocity etc
        if exist('keep_data', 'var')
            [vxy, accVxy, updownVxy, dir, sideways, sidewaysVelocity, av, ecc, rWingAngle, lWingAngle, rWingAngleV, lWingAngleV] = calcVelocityDirEtc(keep_data, fpsNum, mmPerPixel);
        end
        data = [];

        % get data
        switch(handles.analyseSrc)
        case 'count'
            data = keep_count';
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
        case 'becalc'
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
            annotation = trapezoidBehaviorClassifier(trackingInfo);
            save(annoFileName, 'annotation');
            disp(['calc behavior : ' name]);
        case 'be'
            if ~isempty(be)
                data = be.annotation;
            end
        case 'dcdcalc'
            r = dcdRadius / mmPerPixel;
            cnr = dcdCnRadius / mmPerPixel;
            [means, result] = calcLocalDensityDcdAllFly(keep_data{1}, keep_data{2}, [], r, cnr); % empty roiMask
            save([confPath 'multi/aggr_dcd_result_tracking.mat'], 'result');
            disp(['calc DCD : ' name]);
        case 'dcd'
            if ~isempty(dcd)
                data = dcd.result;
            end
        case 'group'
            if isempty(grp)
                [result, wgCount] = calcClusterNNAllFly(keep_data{1}, keep_data{2}, [], algorithm, height); % ignore roiMask
                [data, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            else
                data = grp.result;
            end
        case 'gcount'
            if isempty(grp)
                [result, wgCount] = calcClusterNNAllFly(keep_data{1}, keep_data{2}, [], algorithm, height); % ignore roiMask
                [result, data, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            else
                data = grp.groupCount;
            end
        case 'wgcount'
            if ~isempty(grp)
                data = grp.weightedGroupCount;
            end
        case 'garea'
            if ~isempty(grp)
                data = grp.areas;
            end
        case 'gsolo'
            if ~isempty(grp)
                gfly = nansum(grp.groupFlyNum, 2);
                data = keep_count' - gfly(1:length(keep_count),1);
            end
        case 'gfly'
            if ~isempty(grp)
                data = grp.groupFlyNum;
            end
        case 'gcalc'
            [result, weightedGroupCount] = calcClusterNNAllFly(keep_data{1}, keep_data{2}, [], algorithm, height); % ignore roiMask
            [result, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            [areas, groupAreas, groupCenterX, groupCenterY, groupOrient, groupPerimeter, groupFlyNum] = calcGroupArea(keep_data{1}, keep_data{2}, result, mmPerPixel); % dummy roiMask
            save([confPath 'multi/nn_groups.mat'], 'result', 'groupCount', 'weightedGroupCount', 'biggestGroup', 'biggestGroupFlyNum', ...
                'areas', 'groupAreas', 'groupCenterX', 'groupCenterY', 'groupOrient', 'groupPerimeter', 'groupFlyNum');
            disp(['calc group : ' name]);
        case 'gtrack'
            if ~isempty(grp)
                rejectDist = groupRejectDist / mmPerPixel / fpsNum;
                duration = groupDuration * fpsNum;
                [group_keep_data, detect2groupIds] = trackingPoints(grp.groupCenterX, grp.groupCenterY, rejectDist, duration, img_h, img_w);
                groups = matchingGroupAndFly(grp.result, group_keep_data, grp.groupCenterX, grp.groupCenterY);
                save([confPath 'multi/nn_groups_tracking.mat'], 'group_keep_data', 'groups', 'detect2groupIds', '-v7.3');
                disp(['tracking group : ' name]);
            end
        case 'flygid' % frame x fly matrix (group id)
            data = grptrk.groups;
        case {'flygv', 'flygdir', 'flygav', 'flygdcd'}  % frame x fly matrix (velocity, dcd, angle, av)
            gmax = max(max(grptrk.groups));
            data = nan(size(grptrk.groups,1),size(grptrk.groups,2));
            switch(handles.analyseSrc)
            case 'flygv'
                src = vxy;
            case 'flygdir'
                src = dir;
            case 'flygav'
                src = av;
            case 'flygdcd'
                src = dcd.result;
            end
            for i=1:gmax
                idx = find(grptrk.groups==i);
                data(idx) = src(idx);
            end
        case 'tgcx' % frame x tracked-group matrix (centroid x)
            data = grptrk.group_keep_data{2};
        case 'tgcy' % frame x tracked-group matrix (centroid y)
            data = grptrk.group_keep_data{1};
        case 'tgcv' % frame x tracked-group matrix (centroid v)
            data = calcVxy(grptrk.group_keep_data{3}, grptrk.group_keep_data{4}) * fpsNum * mmPerPixel;
        case 'tgmeancv' % 1 x tracked-group matrix (mean centroid v)
            data = calcVxy(grptrk.group_keep_data{3}, grptrk.group_keep_data{4}) * fpsNum * mmPerPixel;
            data = nanmean(data);
        case {'tgmeanv', 'tgmeandir', 'tgmeanav', 'tgmeandcd'} % 1 x tracked-group matrix (mean frames)
            gmax = max(max(grptrk.groups));
            data = nan(1,gmax);
            switch(handles.analyseSrc)
            case 'tgmeanv'
                src = vxy;
            case 'tgmeandir'
                src = dir;
            case 'tgmeanav'
                src = av;
            case 'tgmeandcd'
                src = dcd.result;
            end
            for i=1:gmax
                idx = find(grptrk.groups==i);
                data(i) = nanmean(src(idx));
            end
        case {'tgarea', 'tgori', 'tgperi', 'tgflynum'} % frame x tracked-group matrix 
            frameNum = size(grptrk.group_keep_data{1},1);
            groupNum = size(grptrk.group_keep_data{1},2);
            switch(handles.analyseSrc)
            case 'tgarea'
                data = getTgData(frameNum, groupNum, grp.groupAreas, grptrk.detect2groupIds);
            case 'tgori'
                data = getTgData(frameNum, groupNum, grp.groupOrient, grptrk.detect2groupIds);
            case 'tgperi'
                data = getTgData(frameNum, groupNum, grp.groupPerimeter, grptrk.detect2groupIds);
            case 'tgflynum'
                data = getTgData(frameNum, groupNum, grp.groupFlyNum, grptrk.detect2groupIds);
            end
        case {'tgmeanarea', 'tgmeanori', 'tgmeanperi', 'tgmeanflynum'} % 1 x tracked-group matrix (mean frames)
            frameNum = size(grptrk.group_keep_data{1},1);
            groupNum = size(grptrk.group_keep_data{1},2);
            switch(handles.analyseSrc)
            case 'tgmeanarea'
                tgdata = getTgData(frameNum, groupNum, grp.groupAreas, grptrk.detect2groupIds);
            case 'tgmeanori'
                tgdata = getTgData(frameNum, groupNum, grp.groupOrient, grptrk.detect2groupIds);
            case 'tgmeanperi'
                tgdata = getTgData(frameNum, groupNum, grp.groupPerimeter, grptrk.detect2groupIds);
            case 'tgmeanflynum'
                tgdata = getTgData(frameNum, groupNum, grp.groupFlyNum, grptrk.detect2groupIds);
            end
            gmax = max(max(grptrk.groups));
            data = nan(1,gmax);
            for i=1:gmax
                idx = find(~isnan(tgdata(:,i)));
                data(i) = nanmean(tgdata(idx,i));
            end
        case {'tgflydiff', 'tgfuse', 'tgsepa'}
            frameNum = size(grptrk.group_keep_data{1},1);
            groupNum = size(grptrk.group_keep_data{1},2);
            tgdata = getTgData(frameNum, groupNum, grp.groupFlyNum, grptrk.detect2groupIds);
            tgdiff = diff(tgdata);
            data = [nan(1,groupNum); tgdiff];
            switch(handles.analyseSrc)
            case 'tgfuse'
                data(data<=1) = NaN;
                data(data>1) = 1;
                data = nansum(data);
            case 'tgsepa'
                data(data>=-1) = NaN;
                data(data<-1) = 1;
                data = nansum(data);
            end
        case 'gszfreq'
            cntgrp = grptrk.group_keep_data{2};
            cntgrp(:,:) = NaN;
            for i=1:size(cntgrp,1)
                ids = unique(grptrk.groups(i,:));
                ids(isnan(ids)) = [];
                for j=1:length(ids)
                    count = length(find(grptrk.groups(i,:)==ids(j)));
                    cntgrp(i,ids(j)) = count;
                end
            end
            fmax = max(max(cntgrp));
            data = nan(1,fmax);
            for i=2:fmax
                data(i) = length(find(cntgrp==i));
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
                switch(handles.analyseSrc)
                case 'count'
                    rd = processCountByRoi(X, Y, roiMasks{i});
                otherwise
                    rd = processDataByRoi(keep_data, img_h, img_w, roiMasks{i}, data);
                end
                roiData = [roiData, rd];
            end
        else
            roiData = {data};
        end

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
        if isempty(handles.join) && isempty(handles.joinr)
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
            for i=1:roiNum
                if ~isempty(handles.join)
                    if ~isempty(joinData)
                        sj = size(joinData,1);
                        sr = size(roiData{i},1);
                        if sj > sr
                            roiData{i}((sr+1):sj,1) = NaN;
                        elseif sj < sr
                            joinData((sj+1):sr,1:end) = NaN;
                        end
                    end
                    joinData = [joinData, roiData{i}];
                    joinHeader = [joinHeader, name];
                elseif ~isempty(handles.joinr)
                    if ~isempty(joinData)
                        sj = size(joinData,2);
                        sr = size(roiData{i},2);
                        if sj > sr
                            roiData{i}(1,(sr+1):sj) = NaN;
                        elseif sj < sr
                            joinData(1:end,(sj+1):sr) = NaN;
                        end
                    end
                    joinData = [joinData; roiData{i}];
                    joinHeader = [joinHeader; name];
                end
            end
        end
    end

    % save joined data as text
    if (~isempty(handles.join) || ~isempty(handles.joinr)) && ~isempty(handles.export)
        if handles.join == 0
            joinHeader = {};
        elseif ~isempty(handles.joinr)
            if handles.joinr == 1
                joinData = [joinHeader, joinData];
            end
            joinHeader = {};
        end
        outputPath = [handles.export '/'];
        dataFileName = [outputPath name '_' rangeName handles.analyseSrc '_joined'];
        saveNxNmatText(dataFileName, joinHeader, joinData);
    end

    time = toc;
    disp(['analysing data ... done : ' num2str(time) 's']);
end

function gtdata = getTgData(frameNum, groupNum, src, detect2groupIds)
    gtdata = nan(frameNum, groupNum);
    for t=1:size(detect2groupIds,1)
        idx = find(detect2groupIds(t,:)>0);
        for j=1:length(idx)
            id = detect2groupIds(t,idx(j));
            gtdata(t,id) = src(t,idx(j));
        end
    end
end
