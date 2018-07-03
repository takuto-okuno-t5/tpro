%%
function cmdJaneriaTraxDataResult(handles)
    % read tpro configuration
    dcdRadius = readTproConfig('dcdRadius', 7.5);
    dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);

    disp('start to process janeria trax data');
    tic;

    procName = 'dcd';
    d = dir(handles.janeriaTrxPath);
    dsize = length(d);
    data = cell(dsize, 2);
    j = 1;
    for i=1:dsize
        if d(i).isdir && ~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..')
            fname = [d(i).folder '/' d(i).name '/registered_trx.mat'];
            if exist(fname, 'file')
                % load registered_trx.mat file
                disp(['processing : ' d(i).name]);
                [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_data, keep_mean_blobmajor, keep_mean_blobminor, ...
                    fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat([d(i).folder '/' d(i).name '/'], 'registered_trx.mat', 1024);
                data{j,1} = d(i).name;

                r = dcdRadius / mmperpx;
                cnr = dcdCnRadius / mmperpx;

                % calc DCD
                means = calcLocalDensityDcd(X, Y, [], r, cnr); % empty roiMask
                data{j,2} = nanmean(means);
                j = j + 1;
            end
        end
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
