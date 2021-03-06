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
    interactAngle = readTproConfig('interactAngle', 75);
    meanBlobMajor = readTproConfig('meanBlobMajor', 3.56);
    eccTh = readTproConfig('beClimb', 0.88);
    pcR = readTproConfig('polarChartRadius', 7.5); % polar chart radius

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
        % load head interaction
        matFile = [confPath 'multi/head_interaction.mat'];
        if exist(matFile, 'file')
            hInt = load(matFile);
        else
            hInt = [];
        end
        % load head polar chart
        matFile = [confPath 'multi/head_pc.mat'];
        if exist(matFile, 'file')
            hPc = load(matFile);
        else
            hPc = [];
        end
        % load patch point result
        matFile = [confPath 'multi/distance_from_point_result_tracking.mat'];
        if exist(matFile,'file')
            patchDist = load(matFile);
        else
            patchDist = [];
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
        case 'vx'
            data = keep_data{4};
        case 'vy'
            data = keep_data{3};
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
            trackingInfo.mmPerPixel = mmPerPixel;
            trackingInfo.x = keep_data{2}(:,:);
            trackingInfo.y = keep_data{1}(:,:);
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
        case 'bebybe'
            if ~isempty(be)
                tmp = be.annotation;
                for j=1:length(handles.srcOps)
                    op = str2num(handles.srcOps{j});
                    idx = find(be.annotation == op);
                    tmp(idx) = 1000;
                end
                data = be.annotation;
                idx = find(tmp < 1000);
                data(idx) = NaN;
            end
        case 'bebydcd'
            if ~isempty(dcd) && ~isempty(be)
                tmp = be.annotation;
                for j=1:length(handles.srcOps)
                    op = str2num(handles.srcOps{j});
                    idx = find(be.annotation == op);
                    tmp(idx) = 1000;
                end
                data = be.annotation;
                idx = find(tmp < 1000);
                data(idx) = NaN;
                dcdlow = str2num(handles.srcOps{1});
                dcdhigh = str2num(handles.srcOps{2});
                idx = find(dcd.result < dcdlow | dcd.result > dcdhigh);
                data(idx) = NaN;
            end
        case 'dcdcalc'
            X = keep_data{2} * mmPerPixel;
            Y = keep_data{1} * mmPerPixel;
            [means, result] = calcLocalDensityDcdAllFly(X, Y, [], dcdRadius, dcdCnRadius); % empty roiMask
            save([confPath 'multi/aggr_dcd_result_tracking.mat'], 'result');
            disp(['calc DCD : ' name]);
        case 'dcd'
            if ~isempty(dcd)
                data = dcd.result;
            end
        case 'dcdbybe'
            if ~isempty(dcd) && ~isempty(be)
                tmp = dcd.result;
                for j=1:length(handles.srcOps)
                    op = str2num(handles.srcOps{j});
                    idx = find(be.annotation == op);
                    tmp(idx) = 1;
                end
                data = dcd.result;
                idx = find(tmp < 1);
                data(idx) = NaN;
            end
        case 'dcdhistbybe'
            if ~isempty(dcd) && ~isempty(be)
                tmp = dcd.result;
                for j=1:length(handles.srcOps)
                    op = str2num(handles.srcOps{j});
                    idx = find(be.annotation == op);
                    tmp(idx) = 1;
                end
                tmp2 = dcd.result;
                idx = find(tmp < 1);
                tmp2(idx) = NaN;
                data = zeros(16,1);
                base = 0.002;
                step = 0.0005;
                for j=1:length(data)
                    low = base + (j-1)*step;
                    high = low + step;
                    idx = find(tmp2 >= low & tmp2 < high);
                    data(j) = length(idx);
                end
            end
        case 'patchdistcalc'
            patchFileName = [confPath 'patch_points.csv'];
            if ~exist(patchFileName, 'file')
                continue;
            end
            patchTable = readtable(patchFileName);
            patch_pt = table2array(patchTable);
            [means, result] = calcDistanceFromPointAllFly(keep_data{2}, keep_data{1}, patch_pt(1,1), patch_pt(1,2));
            result = result * mmPerPixel;
            save([confPath 'multi/distance_from_point_result_tracking.mat'], 'result');
            disp(['calc patch distance : ' name]);
        case 'patchdist'
            if ~isempty(patchDist)
                data = patchDist.result;
            end
        case 'group'
            if isempty(grp)
                [result, wgCount] = calcClusterNNAllFly(keep_data{2}, keep_data{1}, [], algorithm, height); % ignore roiMask
                [data, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            else
                data = grp.result;
            end
        case 'gcount'
            if isempty(grp)
                [result, wgCount] = calcClusterNNAllFly(keep_data{2}, keep_data{1}, [], algorithm, height); % ignore roiMask
                [result, data, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            else
                data = grp.groupCount;
            end
        case 'wgcount'
            if ~isempty(grp)
                data = grp.weightedGroupCount;
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
        case 'gsize'
            if ~isempty(grp)
                data = nansum(grp.groupFlyNum,2) ./ grp.groupCount;
            end
        case 'garea'
            if ~isempty(grp)
                data = grp.areas;
            end
        case 'gdensity'
            if ~isempty(grp)
                data = nansum(grp.groupFlyNum,2) ./ grp.areas;
            end
        case 'gperimeter'
            if ~isempty(grp)
                data = nansum(grp.groupPerimeter,2);
            end
        case 'gmarea'
            if ~isempty(grp)
                data = grp.areas ./ grp.groupCount;
            end
        case 'gmperimeter'
            if ~isempty(grp)
                data = nansum(grp.groupPerimeter,2) ./ grp.groupCount;
            end
        case 'gmecc'
            if ~isempty(grp)
                data = nanmean(grp.groupEcc,2);
            end
        case 'gmeccwo2'
            if ~isempty(grp)
                idx = find(grp.groupFlyNum==2);
                grp.groupEcc(idx) = NaN;
                data = nanmean(grp.groupEcc,2);
            end
        case 'gareabygs' % group area by group size
            for i=2:20
                idx = find(grp.groupFlyNum==i);
                vals = grp.groupAreas(idx);
                data = mergeColumns(data,vals);
            end
        case 'gperimeterbygs' % group perimeter by group size
            for i=2:20
                idx = find(grp.groupFlyNum==i);
                vals = grp.groupPerimeter(idx);
                data = mergeColumns(data,vals);
            end
        case 'geccbygs' % group ecc by group size
            for i=2:20
                idx = find(grp.groupFlyNum==i);
                vals = grp.groupEcc(idx);
                data = mergeColumns(data,vals);
            end
        case 'gdensitybygs' % group density by group size
            for i=2:20
                idx = find(grp.groupFlyNum==i);
                vals = i ./ grp.groupAreas(idx);
                data = mergeColumns(data,vals);
            end
        case 'gareatmbygs' % group area time course by group size
            frame = size(grp.groupFlyNum,1);
            data = nan(frame,19);
            for j=1:frame
                groupFlyNum2 = grp.groupFlyNum(j,:);
                for i=2:20
                    idx = find(groupFlyNum2==i);
                    vals = grp.groupAreas(j,idx);
                    data(j,i-1) = nanmean(vals);
                end
            end
        case 'gperimetertmbygs' % group perimeter time course by group size
            frame = size(grp.groupFlyNum,1);
            data = nan(frame,19);
            for j=1:frame
                groupFlyNum2 = grp.groupFlyNum(j,:);
                for i=2:20
                    idx = find(groupFlyNum2==i);
                    vals = grp.groupPerimeter(j,idx);
                    data(j,i-1) = nanmean(vals);
                end
            end
        case 'gecctmbygs' % group perimeter time course by group size
            frame = size(grp.groupFlyNum,1);
            data = nan(frame,19);
            for j=1:frame
                groupFlyNum2 = grp.groupFlyNum(j,:);
                for i=2:20
                    idx = find(groupFlyNum2==i);
                    vals = grp.groupEcc(j,idx);
                    data(j,i-1) = nanmean(vals);
                end
            end
        case 'gdcdtmbygs' % group DCD time course by group size
            frame = size(grp.groupFlyNum,1);
            data = nan(frame,19);
            for j=1:frame
                groupFlyNum2 = grp.groupFlyNum(j,:);
                groupFly = grp.result(j,:);
                for i=2:20
                    idx = find(groupFlyNum2==i);
                    idx2 = [];
                    for k=1:length(idx)
                        idx2 = [idx2, find(groupFly==idx(k))];
                    end
                    vals = dcd.result(j,idx2);
                    data(j,i-1) = nanmean(vals);
                end
            end
        case 'gdcdvartmbygs' % group DCD var time course by group size
            frame = size(grp.groupFlyNum,1);
            data = nan(frame,19);
            for j=1:frame
                groupFlyNum2 = grp.groupFlyNum(j,:);
                groupFly = grp.result(j,:);
                for i=2:20
                    idx = find(groupFlyNum2==i);
                    idx2 = [];
                    for k=1:length(idx)
                        idx2 = [idx2, find(groupFly==idx(k))];
                    end
                    vals = dcd.result(j,idx2);
                    data(j,i-1) = nanvar(vals);
                end
            end
        case 'ganglehist'
            data = nan(1,36);
            for j=1:36
                bg = (j-1)*10;
                ed = j*10;
                idx = find(grp.groupFlyDir>=bg & grp.groupFlyDir<ed);
                data(j) = length(idx);
            end
        case 'ganglehistbygs'
            frame = size(grp.groupFlyNum,1);
            data = zeros(19,36);
            for j=1:frame
                groupFlyNum2 = grp.groupFlyNum(j,:);
                groupFly = grp.result(j,:);
                for i=2:20
                    idx = find(groupFlyNum2==i);
                    idx2 = [];
                    for k=1:length(idx)
                        idx2 = [idx2, find(groupFly==idx(k))];
                    end
                    groupFlyDir2 = grp.groupFlyDir(j,idx2);
                    for k=1:36
                        bg = (k-1)*10;
                        ed = k*10;
                        idx3 = find(groupFlyDir2>=bg & groupFlyDir2<ed);
                        data(i-1,k) = data(i-1,k) + length(idx3);
                    end
                end
                if mod(j,200)==0
                    rate = j/frame * 100;
                    disp(['ganglehistbygs : ' num2str(j) '(' num2str(rate) '%)']);
                end
            end
        case 'ganglehistbyecc' % group angle histgram by group ecc
            frame = size(grp.groupFlyNum,1);
            data = zeros(10,36);
            for j=1:frame
                groupEcc2 = grp.groupEcc(j,:);
                groupFly = grp.result(j,:);
                for i=1:10
                    idx = find(groupEcc2>=(i-1)*0.1 & groupEcc2<i*0.1);
                    idx2 = [];
                    for k=1:length(idx)
                        idx2 = [idx2, find(groupFly==idx(k))];
                    end
                    groupFlyDir2 = grp.groupFlyDir(j,idx2);
                    for k=1:36
                        bg = (k-1)*10;
                        ed = k*10;
                        idx3 = find(groupFlyDir2>=bg & groupFlyDir2<ed);
                        data(i,k) = data(i,k) + length(idx3);
                    end
                end
                if mod(j,200)==0
                    rate = j/frame * 100;
                    disp(['ganglehistbyecc : ' num2str(j) '(' num2str(rate) '%)']);
                end
            end
        case 'ganglehistbyeccgs' % group angle histgram by group ecc / group size
            frame = size(grp.groupFlyNum,1);
            data = zeros(10*10,36);
            for j=1:frame
                groupFlyNum2 = grp.groupFlyNum(j,:);
                groupEcc2 = grp.groupEcc(j,:);
                groupFly = grp.result(j,:);
                for i=2:11
                    for n=1:10
                        idx = find(groupFlyNum2==i & groupEcc2>=(n-1)*0.1 & groupEcc2<n*0.1);
                        idx2 = [];
                        for k=1:length(idx)
                            idx2 = [idx2, find(groupFly==idx(k))];
                        end
                        groupFlyDir2 = grp.groupFlyDir(j,idx2);
                        for k=1:36
                            bg = (k-1)*10;
                            ed = k*10;
                            idx3 = find(groupFlyDir2>=bg & groupFlyDir2<ed);
                            data((i-2)*10+n,k) = data((i-2)*10+n,k) + length(idx3);
                        end
                    end
                end
                if mod(j,200)==0
                    rate = j/frame * 100;
                    disp(['ganglehistbyeccgs : ' num2str(j) '(' num2str(rate) '%)']);
                end
            end
        case 'gcalc'
            [result, weightedGroupCount] = calcClusterNNAllFly(keep_data{2}, keep_data{1}, [], algorithm, height); % ignore roiMask
            [result, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            [areas, groupAreas, groupCenterX, groupCenterY, groupOrient, groupPerimeter, groupEcc, groupFlyNum, groupFlyDir] = calcGroupArea(keep_data{2}, keep_data{1}, dir, result, mmPerPixel); % dummy roiMask
            save([confPath 'multi/nn_groups.mat'], 'result', 'groupCount', 'weightedGroupCount', 'biggestGroup', 'biggestGroupFlyNum', ...
                'areas', 'groupAreas', 'groupCenterX', 'groupCenterY', 'groupOrient', 'groupPerimeter', 'groupEcc', 'groupFlyNum', 'groupFlyDir');
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
        case 'tgduration'
            gmax = max(max(grptrk.groups));
            data = nan(gmax,2);
            rasterData = cell(gmax,1);
            for i=1:gmax
                idx = find(~isnan(grptrk.group_keep_data{1}(:,i)));
                maxfr = max(idx);
                if handles.maxFrame > 0 && handles.maxFrame < maxfr
                    maxfr = handles.maxFrame;
                end
                data(i,1) = min(idx);
                data(i,2) = maxfr - data(i,1);
                rasterData{i} = min(idx);
            end

            %
            %if isempty(f)
                f = figure;
            %end

            hold on;
            LineFormat.LineWidth = 2.5;
            LineFormat.Color = 'b';
            plotSpikeRaster(rasterData, 'SpikeDuration', data(:,2), 'LineFormat',LineFormat,'XLimForCell',[1 90000]); % 

            % fuse & separate
            frameNum = size(grptrk.group_keep_data{1},1);
            groupNum = size(grptrk.group_keep_data{1},2);
            tgdata = getTgData(frameNum, groupNum, grp.groupFlyNum, grptrk.detect2groupIds);
            tgdiff = diff(tgdata);
            datadiff = [nan(1,groupNum); tgdiff];
            fuseData = cell(gmax,1);
            sepaData = cell(gmax,1);
            for i=1:gmax
                idx = find(datadiff(:,i)<-1);
                fuseData{i} = idx';
                idx = find(datadiff(:,i)>1);
                sepaData{i} = idx';
            end

            % show fuse & separate
            LineFormat.Color = 'r';
            plotSpikeRaster(fuseData, 'SpikeDuration', 200, 'LineFormat',LineFormat,'XLimForCell',[1 90000]); % 
            LineFormat.Color = 'g';
            plotSpikeRaster(sepaData, 'SpikeDuration', 200, 'LineFormat',LineFormat,'XLimForCell',[1 90000]); % 
            xlabel('Time (s)'); % 
            hold off;
        case 'tgmtduration'
            gmax = max(max(grptrk.groups));
            data = nan(gmax,2);
            for i=1:gmax
                idx = find(~isnan(grptrk.group_keep_data{1}(:,i)));
                maxfr = max(idx);
                if handles.maxFrame > 0 && handles.maxFrame < maxfr
                    maxfr = handles.maxFrame;
                end
                data(i,2) = maxfr - min(idx);
                data(i,1) = min(idx) + data(i,2) / 2;
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
        case 'hintcalc' % head interaction calc
            br = mean_blobmajor*0.4; % head-body, body-ass radius
            ir = mean_blobmajor*0.5; % interaction radius
            interaction_data = calcInteractionAllFly(keep_data{2}, keep_data{1}, dir, ecc, br, ir, interactAngle, eccTh);
            save([confPath 'multi/head_interaction.mat'], 'interaction_data');
            disp(['calc head interaction : ' name]);
        case 'hintcount' % head interaction count frame x 1
            data = hInt.interaction_data{1};
        case 'hhint' % head to head interaction frame x fly
            data = hInt.interaction_data{2};
        case 'haint'
            data = hInt.interaction_data{3};
        case 'hbint'
            data = hInt.interaction_data{4};
        case 'hpccalc' % head polar chart calc
            br = mean_blobmajor*0.4; % head-body, body-ass radius
            pc_data = calcPolarChartAllFly(keep_data{2}, keep_data{1}, dir, ecc, br, pcR / mmPerPixel, eccTh);
            save([confPath 'multi/head_pc.mat'], 'pc_data');
            disp(['calc head polar chart : ' name]);
        case 'hhpc' % head to head polar chart
            data = hPc.pc_data{1};
        case 'hapc' % head to ass polar chart
            data = hPc.pc_data{2};
        case 'hcpc' % head to centroid polar chart
            data = hPc.pc_data{9};
        case 'hh-hapc' % head2head minus head2ass polar chart
            d1 = hPc.pc_data{1};
            d2 = hPc.pc_data{2};
            data = d1 - d2;
        case 'ha-hhpc' % head2ass minus head2head polar chart
            d1 = hPc.pc_data{1};
            d2 = hPc.pc_data{2};
            data = d2 - d1;
        case 'hhpchist' % head to head polar chart histgram
            data = hPc.pc_data{3};
        case 'hapchist' % head to ass polar chart histgram
            data = hPc.pc_data{4};
        case 'hcpchist' % head to centroid polar chart histgram
            data = hPc.pc_data{10};
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
        if isempty(handles.join) && isempty(handles.joinr) && isempty(handles.merge)
            for i=1:roiNum
                % export file
                if isempty(handles.export)
                    outputPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
                    dataFileName = [outputPath name '_' filename '_' handles.analyseSrc];
                else
                    outputPath = [handles.export '/'];
                    dataFileName = [outputPath name '_' filename '_roi' num2str(i) '_' handles.analyseSrc];
                end
                if ~isempty(handles.procOps)
                    for j=1:length(handles.procOps)
                        op = handles.procOps{j};
                        op = strrep(op,'==','_');
                        op = strrep(op,'>','_');
                        op = strrep(op,'<','_');
                        dataFileName = [dataFileName '_' op];
                    end
                end
                disp(['exporting a file : ' dataFileName]);
                saveNxNmatText(dataFileName, [], roiData{i});
            end
        elseif isempty(handles.merge)
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
        else
            disp(['merging a data : ' name]);
            for i=1:roiNum
                if i==1 && data_th == 1
                    joinData = roiData{i};
                    continue;
                end
                sj = size(joinData,1);
                sr = size(roiData{i},1);
                if sj > sr
                    roiData{i}((sr+1):sj,1:end) = NaN;
                elseif sj < sr
                    joinData((sj+1):sr,1:end) = NaN;
                end
                joinData3 = [];
                switch handles.merge
                case 'mean'
                    joinData3(:,:,1) = joinData .* (data_th - 1);
                    joinData3(:,:,2) = roiData{i};
                    joinData = nansum(joinData3,3) ./ data_th;
                case 'sum'
                    joinData3(:,:,1) = joinData;
                    joinData3(:,:,2) = roiData{i};
                    joinData = nansum(joinData3,3);
                end
            end
        end
    end
    % percentile for box whisker plot
    if ~isempty(handles.percentile)
        jsize = size(joinData,2);
        psize = length(handles.percentile);
        pdata = nan(psize, jsize);
        for i=1:size(joinData,2)
            pdata2 = nan(psize, 1);
            for j=1:psize
                pdata2(j) = prctile(joinData(:,i), handles.percentile(j));
            end
            pdata(:,i) = pdata2;
        end
        joinData = pdata;
    end
    % save joined data as text
    if (~isempty(handles.join) || ~isempty(handles.joinr) || ~isempty(handles.merge)) && ~isempty(handles.export)
        postText = '_joined';
        if ~isempty(handles.merge)
            joinHeader = {};
            postText = '_merged';
        elseif handles.join == 0
            joinHeader = {};
        elseif ~isempty(handles.joinr)
            if handles.joinr == 1
                joinData = [joinHeader, joinData];
            end
            joinHeader = {};
        end
        outputPath = [handles.export '/'];
        dataFileName = [outputPath name '_' rangeName handles.analyseSrc];
        if ~isempty(handles.srcOps)
            for j=1:length(handles.srcOps)
                op = handles.srcOps{j};
                dataFileName = [dataFileName op];
            end
        end
        if ~isempty(handles.procOps)
            for j=1:length(handles.procOps)
                op = handles.procOps{j};
                op = strrep(op,'==','_');
                op = strrep(op,'>','_');
                op = strrep(op,'<','_');
                dataFileName = [dataFileName '_' op];
            end
        end
        dataFileName = [dataFileName postText];
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
