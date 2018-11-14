%%
function cmdJaneriaTraxDataResult(handles)
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

    img_h = 1024;
    img_w = 1024;

    disp('start to process janeria trax data');
    tic;

    % find gal4 line names
    d = dir(handles.janeriaTrxPath);
    dsize = length(d);
    fnames = cell(dsize, 2);
    j = 1;
    for i=1:dsize
        if d(i).isdir && ~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..')
            fname = [handles.janeriaTrxPath '/' d(i).name '/registered_trx.mat'];
            if exist(fname, 'file')
                fnames{j,1} = d(i).name;
                C = strsplit(d(i).name, '_');
                fnames{j,2} = C{2};
                j = j + 1;
            end
        end
    end
    fn2 = fnames(:,2);
    fn2(j:dsize) = [];
    gids = nan(j-1,1);
    names = {};
    count = 1;
    % find groups
    for i=1:(j-1)
        name = fn2{i};
        idxC = strfind(names, name);
        idx = find(not(cellfun('isempty', idxC)));
        if isempty(idx) || isempty(idx(:))
            names = [names, name];
            gids(i) = count;
            count = count + 1;
        else
            gids(i) = idx(1);
        end
    end
%    gids = findgroups(fn2); % just for R2017
    gmax = max(gids);

    % read control data
    if strcmp(handles.analyseSrc, 'gal4dcdpval')
        fname = 'TrpA_dcd_mean.csv';
        dcdControlData = csvread(fname);
        if isempty(dcdControlData)
            disp(['control value file not found : ' fname]);
            return;
        end
        meanDcdControlData = mean(dcdControlData);
    end

    % process registered_trx.mat files
    switch(handles.analyseSrc)
    case 'dcd'
        dsize = length(fn2);
        data = cell(dsize, 8);
        count = 1;
        for i=1:dsize
            % load registered_trx.mat file
            rate = count/dsize * 100;
            disp(['processing(' num2str(count) ') : G(' num2str(i) ') ' fnames{i,1} ' (' num2str(rate) '%)']);
            [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat([handles.janeriaTrxPath '/' fnames{i,1} '/'], 'registered_trx.mat', img_h);

            r = dcdRadius / mmperpx;
            cnr = dcdCnRadius / mmperpx;

            % calc DCD
            means = calcLocalDensityDcd(X, Y, [], r, cnr); % empty roiMask
            count = count + 1;

            data{i,1} = fnames{i,2};
            data{i,2} = fnames{i,1};
            data{i,3} = nanmean(means);
            data{i,4} = prctile(means,100);
            data{i,5} = prctile(means,75);
            data{i,6} = prctile(means,50);
            data{i,7} = prctile(means,25);
            data{i,8} = prctile(means,0);
        end
    case 'gal4dcd'
        data = cell(gmax, 8);
        dsize = length(gids);
        count = 1;
        for i=1:gmax
            idx = find(gids==i);
            means = [];
            for j=1:length(idx)
                k = idx(j);

                % load registered_trx.mat file
                jtrxPath = [handles.janeriaTrxPath '/' fnames{k,1} '/'];
                rate = count/dsize * 100;
                disp(['processing(' num2str(count) ') : G(' num2str(i) ') ' fnames{k,1} ' (' num2str(rate) '%)']);
                [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                    fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(jtrxPath, 'registered_trx.mat', img_h);

                r = dcdRadius / mmperpx;
                cnr = dcdCnRadius / mmperpx;

                % calc DCD
                means1 = calcLocalDensityDcd(X, Y, [], r, cnr); % empty roiMask
                means = [means; means1];
                count = count + 1;
            end
            data{i,1} = fnames{idx(1),2};
            data{i,2} = length(idx);
            data{i,3} = nanmean(means);
            data{i,4} = prctile(means,100);
            data{i,5} = prctile(means,75);
            data{i,6} = prctile(means,50);
            data{i,7} = prctile(means,25);
            data{i,8} = prctile(means,0);
        end
    case 'gal4dcdpval'
        data = cell(gmax, 5);
        dsize = length(gids);
        count = 1;
        for i=1:gmax
            idx = find(gids==i);
            groupNum = length(idx);
            means = [];
            for j=1:groupNum
                k = idx(j);

                % load registered_trx.mat file
                jtrxPath = [handles.janeriaTrxPath '/' fnames{k,1} '/'];
                rate = count/dsize * 100;
                disp(['processing(' num2str(count) ') : G(' num2str(i) ') ' fnames{k,1} ' (' num2str(rate) '%)']);
                [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                    fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(jtrxPath, 'registered_trx.mat', img_h);

                r = dcdRadius / mmperpx;
                cnr = dcdCnRadius / mmperpx;

                % calc DCD
                means1 = calcLocalDensityDcd(X, Y, [], r, cnr); % empty roiMask
                means1m = mean(means1);
                means = [means; means1m];
                count = count + 1;
            end
            sampleNum = groupNum;
            if sampleNum < 6
                sampleNum = 6;
            end
            s1 = randsample(dcdControlData, sampleNum);
            [bootstat,bootsam] = bootstrp(10000,@mean,s1);
            pv = nan(groupNum,1);
            for j=1:groupNum
                pvIdx = find(bootstat>=means(j));
                pv(j) = (1+length(pvIdx))/(length(bootstat)+1);
            end
            data{i,1} = fnames{idx(1),2};
            data{i,2} = groupNum;
            [maxpv, midx] = max(pv);
            data{i,3} = maxpv;
            data{i,4} = means(midx);
            if means(midx) > meanDcdControlData
                data{i,5} = 1;
            else
                data{i,5} = 2;
            end
        end
    case 'gcalc'
        data = cell(1,1); % dummy
        dsize = length(fn2);
        count = 1;
        for i=1:dsize
            % load registered_trx.mat file
            jtrxPath = [handles.janeriaTrxPath '/' fnames{i,1} '/'];
            rate = count/dsize * 100;
            count = count + 1;
            disp(['processing(' num2str(count) ') : G(' num2str(i) ') ' fnames{i,1} ' (' num2str(rate) '%)']);
%            fname = [jtrxPath 'registered_trx_tpro.mat'];
%            if exist(fname, 'file')
%                load(fname);
%            else
                [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                    fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(jtrxPath, 'registered_trx.mat', img_h);
%                save(fname, 'X', 'Y', 'keep_angle_sorted', 'keep_direction_sorted', 'keep_areas', 'keep_ecc_sorted', 'keep_wings_sorted', 'keep_gender', ...
%                    'keep_data', 'keep_mean_blobmajor', 'keep_mean_blobminor', 'fps', 'mmperpx', 'startframe', 'endframe', 'maxframe');
%            end
            [vxy, accVxy, updownVxy, fdir, sideways, sidewaysVelocity, av, ecc, rWingAngle, lWingAngle, rWingAngleV, lWingAngleV] = calcVelocityDirEtc(keep_data, fps, mmperpx);

            height = nnHeight / mmperpx;
            algorithm = nnAlgorithm; 
            [result, weightedGroupCount] = calcClusterNNAllFly(keep_data{2}, keep_data{1}, [], algorithm, height); % ignore roiMask
            [result, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
            [areas, groupAreas, groupCenterX, groupCenterY, groupOrient, groupPerimeter, groupEcc, groupFlyNum, groupFlyDir] = calcGroupArea(keep_data{2}, keep_data{1}, fdir, result, mmperpx); % dummy roiMask
            save([jtrxPath 'nn_groups.mat'], 'result', 'groupCount', 'weightedGroupCount', 'biggestGroup', 'biggestGroupFlyNum', ...
                'areas', 'groupAreas', 'groupCenterX', 'groupCenterY', 'groupOrient', 'groupPerimeter', 'groupEcc', 'groupFlyNum', 'groupFlyDir');
        end
    case 'gtrack'
        data = cell(1,1); % dummy
        dsize = length(fn2);
        count = 1;
        for i=1:dsize
            % load registered_trx.mat file
            jtrxPath = [handles.janeriaTrxPath '/' fnames{i,1} '/'];
            rate = count/dsize * 100;
            count = count + 1;
            fname = [jtrxPath 'nn_groups_tracking.mat'];
            if exist(fname, 'file')
                disp(['skip(' num2str(count) ') : G(' num2str(i) ') ' fnames{i,1} ' (' num2str(rate) '%)']);
                continue
            else
                disp(['processing(' num2str(count) ') : G(' num2str(i) ') ' fnames{i,1} ' (' num2str(rate) '%)']);
            end
%            fname = [jtrxPath 'registered_trx_tpro.mat'];
%            if exist(fname, 'file')
%                load(fname);
%            else
            [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(jtrxPath, 'registered_trx.mat', img_h);
%                save(fname, 'X', 'Y', 'keep_angle_sorted', 'keep_direction_sorted', 'keep_areas', 'keep_ecc_sorted', 'keep_wings_sorted', 'keep_gender', ...
%                    'keep_data', 'keep_mean_blobmajor', 'keep_mean_blobminor', 'fps', 'mmperpx', 'startframe', 'endframe', 'maxframe');
%            end

            % load group analysing result
            grp = load([jtrxPath 'nn_groups.mat']);

            rejectDist = groupRejectDist / mmperpx / fps;
            duration = groupDuration * fps;
            [group_keep_data, detect2groupIds] = trackingPoints(grp.groupCenterX, grp.groupCenterY, rejectDist, duration, img_h, img_w);
            groups = matchingGroupAndFly(grp.result, group_keep_data, grp.groupCenterX, grp.groupCenterY);
            save([jtrxPath 'nn_groups_tracking.mat'], 'group_keep_data', 'groups', 'detect2groupIds', '-v7.3');
        end
    case 'gcount'
        data = cell(gmax, 8);
        dsize = length(gids);
        count = 1;
        for i=1:gmax
            idx = find(gids==i);
            means = [];
            for j=1:length(idx)
                k = idx(j);

                % load registered_trx.mat file
                jtrxPath = [handles.janeriaTrxPath '/' fnames{k,1} '/'];
                rate = count/dsize * 100;
                disp(['processing(' num2str(count) ') : G(' num2str(i) ') ' fnames{k,1} ' (' num2str(rate) '%)']);
                [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                    fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(jtrxPath, 'registered_trx.mat', img_h);

                % load group analysing result
                grp = load([jtrxPath 'nn_groups.mat']);

                % calc DCD
                means1 = grp.groupCount;
                means = [means; means1];
                count = count + 1;
            end
            data{i,1} = fnames{idx(1),2};
            data{i,2} = length(idx);
            data{i,3} = nanmean(means);
            data{i,4} = prctile(means,100);
            data{i,5} = prctile(means,75);
            data{i,6} = prctile(means,50);
            data{i,7} = prctile(means,25);
            data{i,8} = prctile(means,0);
        end
    case 'hpccalc' % head polar chart calc
        data = cell(1,1); % dummy
        dsize = length(fn2);
        count = 1;
        for i=1:dsize
            % load registered_trx.mat file
            jtrxPath = [handles.janeriaTrxPath '/' fnames{i,1} '/'];
            rate = count/dsize * 100;
            count = count + 1;
            disp(['processing(' num2str(count) ') : G(' num2str(i) ') ' fnames{i,1} ' (' num2str(rate) '%)']);
            [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(jtrxPath, 'registered_trx.mat', img_h);

            [vxy, accVxy, updownVxy, fdir, sideways, sidewaysVelocity, av, ecc, rWingAngle, lWingAngle, rWingAngleV, lWingAngleV] = calcVelocityDirEtc(keep_data, fps, mmperpx);

            br = mean(keep_mean_blobmajor)*0.4; % head-body, body-ass radius
            pc_data = calcPolarChartAllFly(keep_data{2}, keep_data{1}, fdir, ecc, br, pcR / mmperpx, eccTh);
            save([jtrxPath 'head_pc.mat'], 'pc_data');
        end
    case 'gal4hhpc' % head to head polar chart
        for i=1:gmax
            idx = find(gids==i);
            data = zeros(240,240,3); % TODO: not good ...
            for j=1:length(idx)
                % load head_pc.mat file
                jtrxPath = [handles.janeriaTrxPath '/' fnames{idx(j),1} '/'];
                hPc = load([jtrxPath 'head_pc.mat']);
                data = data + hPc.pc_data{1};
            end
            figure; title(fnames{idx(1),2});
            imshow(data ./ (length(idx)*100)); % normalized intensity
        end
    case 'gal4hapc' % head to ass polar chart
        for i=1:gmax
            idx = find(gids==i);
            data = zeros(240,240,3); % TODO: not good ...
            for j=1:length(idx)
                % load head_pc.mat file
                jtrxPath = [handles.janeriaTrxPath '/' fnames{idx(j),1} '/'];
                hPc = load([jtrxPath 'head_pc.mat']);
                data = data + hPc.pc_data{2};
            end
            figure; title(fnames{idx(1),2});
            imshow(data ./ (length(idx)*100)); % normalized intensity
        end
    case 'gal4hcpc' % head to centroid polar chart
        for i=1:gmax
            idx = find(gids==i);
            data = zeros(240,240,3); % TODO: not good ...
            for j=1:length(idx)
                % load head_pc.mat file
                jtrxPath = [handles.janeriaTrxPath '/' fnames{idx(j),1} '/'];
                hPc = load([jtrxPath 'head_pc.mat']);
                data = data + hPc.pc_data{9};
            end
            data = data ./ (length(idx)*100);
            data(data>1) = 1;
            data = convertColor(data,[1,0.9,0.6,0.1,0],[1,1,1; 1,1,0; 1,0,0; 0,0,1; 0,0,0.1]);
            figure; title(fnames{idx(1),2});
            imshow(data); % normalized intensity
            % color bar
            colbar = zeros(240,10,3);
            for j=1:240
                colbar(j,:,1) = (240-j+1)/240;
            end
            colbar = convertColor(colbar,[1,0.9,0.6,0.1,0],[1,1,1; 1,1,0; 1,0,0; 0,0,1; 0,0,0.1]);
            figure;imshow(colbar);
        end
    otherwise
        disp(['unsupported data type : ' handles.analyseSrc]);
        return;
    end
    % save data as text
    if ~isempty(handles.export) && iscell(data)
        outputPath = [handles.export '/'];
        dataFileName = [outputPath data{1,1} '_' handles.analyseSrc];
        saveNxNcellText(dataFileName, [], data);
    end

    time = toc;
    disp(['process janeria trax data ... done : ' num2str(time) 's']);
end
