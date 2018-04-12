%%
function [status, tebleItems, videoPaths, videoFiles] = openOrNewProject(videoPaths, videoFiles, templateFile, batches, isAdd)
    status = true;
    tmpl = {};
    openFiles = {};
    openPaths = {};
    tebleItems = {};
    if ~isempty(templateFile)
        if exist(templateFile, 'file')
            confTable = readtable(templateFile);
            tmpl = table2cell(confTable);
        end
    end

    % write config files if it is empty
    for i = 1:size(videoFiles, 1)
        videoPath = videoPaths{i};
        fileName = videoFiles{i};
        matName = [];
        fps = 30;

        if ~isempty(batches)
            tmpl = batches(i,:);
            if batches{i,1} == 0
                continue;
            end
        end
        % check work dir or not
        if length(fileName) > 5 && strcmp(fileName(end-4:end),'_tpro')
            movieName = fileName(1:end-5);
            % file, dir, or blank name
            fileName = movieName;
        elseif length(fileName) > 4 && strcmp(fileName((end-3):end),'.mat')
            matName = fileName(1:(end-4));
            fileName = matName;
        end

        outPathName = [videoPath '/' fileName '_tpro'];
        outputFileName = [outPathName '/input_video_control.csv'];

        % open current input_video_control.csv if exist (except batch mode)
        if exist(outputFileName, 'file') && isempty(batches)
            openFiles = [openFiles; fileName];
            openPaths = [openPaths; videoPath];
            continue;
        end

        % check if imported file is ctrax mat
        if ~isempty(matName)
            iniHeight = 1024;
            type = checkMatFileType(videoPath, fileName);
            switch(type)
            case 'ctrax'
                [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_data] = loadCtraxMat(videoPath, fileName, iniHeight);
                fps = 30; mmperpx = 0.1; startframe = 1; endframe = length(X); maxframe = length(X);
            case 'jntrx'
                [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_data, ...
                    fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(videoPath, fileName, iniHeight);
            otherwise
                X = [];
            end
            if ~isempty(X)
                [dlg, matName, path, bgPath, roiPathes, frames, fps, width, height, import] = newWorkDialog({matName, videoPath, num2str(maxframe), num2str(fps)});
                maxframe = str2num(frames);
                fps = str2num(fps);
                delete(dlg);
                pause(0.1);

                % recalculate by fixed height
                diff = str2num(height) - iniHeight;
                if diff ~= 0
                    for j=1:length(X)
                        X{j} = X{j}(:,1) + diff;
                    end
                end
            end
            if isempty(X) || isempty(matName)
                continue;
            end
        end

        % open video file
        try
            shuttleVideo = TProVideoReader(videoPath, fileName, 0, fps);
        catch e
            msg = sprintf('failed to open : %s%s\nplease select movie files or image folders.', videoPath, fileName);
            disp(msg);
            errordlg(msg, 'Error');
            status = false;
            break;
        end

        % make directory
        if ~exist(outPathName, 'dir')
            disp(['mkdir : ' outPathName]);
            mkdir(outPathName);
        end

        [status, B] = createConfigFiles(shuttleVideo.Name, shuttleVideo.NumberOfFrames, shuttleVideo.FrameRate, tmpl, i, outputFileName);

        % set imported data information
        if ~isempty(matName)
            if ~isempty(bgPath)
                copyfile(bgPath, [outPathName '/background.png']);
                img = imread(bgPath);
                height = size(img,1);
            end
            if ~isempty(roiPathes)
                C = strsplit(roiPathes,';');
                for j=1:length(C)
                    num = '';
                    if j>1, num = num2str(j); end
                    copyfile(C{j}, [outPathName '/roi' num '.png']);
                    img = imread(C{j});
                    height = size(img,1);
                end
            else
                C = {};
            end
            % set config info
            B{4} = startframe;
            B{5} = endframe;
            B{6} = maxframe;
            B{7} = fps;
            B{9} = mmperpx;
            B{10} = length(C);
            status = saveInputControlFile(outputFileName, B);
            % make multi dir
            if ~exist([outPathName '/multi'], 'dir')
                mkdir([outPathName '/multi']);
            end
            keep_count = zeros(1,length(X));
            for j=1:length(X)
                X{j} = X{j}(:) - 1024 + height;
                keep_count(j) = length(X{j}(:));
            end
            % save detection X, Y, keep_*
            startend = [sprintf('%05d',B{4}) '_' sprintf('%05d',B{5})];
            save([outPathName '/multi/detect_' startend '.mat'], 'X','Y', 'keep_direction_sorted', 'keep_ecc_sorted', 'keep_angle_sorted', 'keep_areas');
            % save keep_count
            save([outPathName '/multi/detect_' startend 'keep_count.mat'], 'keep_count');
            % save tracking keep_data
            if ~isempty(keep_data)
                save([outPathName '/multi/track_' startend '.mat'], 'keep_data');
            end
        end
        if ~status
            break;
        end

        openFiles = [openFiles; fileName];
        openPaths = [openPaths; videoPath];
    end
    % save video list file
    videoFiles = openFiles;
    videoPaths = openPaths;
    inputListFile = getInputListFile();
    if isAdd && exist(inputListFile, 'file')
        vl = load(inputListFile);
        videoPaths = [vl.videoPaths; videoPaths];
        videoFiles = [vl.videoFiles; videoFiles];
    end
    save(inputListFile, 'videoPaths', 'videoFiles');
    for n = 1:length(videoFiles)
        row = {videoFiles{n}, videoPaths{n}};
        tebleItems = [tebleItems; row];
    end
    % set to global value
    global gVideoPaths;
    global gVideoFiles;
    global gTebleItems;
    gVideoPaths = videoPaths;
    gVideoFiles = videoFiles;
    gTebleItems = tebleItems;
end