%%
function cmdJaneriaTraxDataResult(handles)
    % read tpro configuration
    dcdRadius = readTproConfig('dcdRadius', 7.5);
    dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);

    procName = 'dcd';

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

    % process registered_trx.mat files
    data = cell(gmax, 8);
    dsize = length(gids);
    count = 1;
    for i=1:gmax
        idx = find(gids==i);
        means = [];
        for j=1:length(idx)
            k = idx(j);

            % load registered_trx.mat file
            rate = count/dsize * 100;
            disp(['processing(' num2str(count) ') : G(' num2str(i) ') ' fnames{k,1} ' (' num2str(rate) '%)']);
            [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat([handles.janeriaTrxPath '/' fnames{k,1} '/'], 'registered_trx.mat', 1024);

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
    % save data as text
    if ~isempty(handles.export)
        outputPath = [handles.export '/'];
        dataFileName = [outputPath data{1,1} '_' procName];
        saveNxNcellText(dataFileName, [], data);
    end

    time = toc;
    disp(['process janeria trax data ... done : ' num2str(time) 's']);
end
