%%
function [status, tebleItems] = openOrNewProject(videoPath, videoFiles, templateFile)
    status = true;
    tmpl = {};
    openFiles = {};
    tebleItems = {};
    if ~isempty(templateFile)
        if exist(templateFile, 'file')
            confTable = readtable(templateFile);
            tmpl = table2cell(confTable);
        end
    end

    % write config files if it is empty
    for i = 1:size(videoFiles, 1)
        fileName = videoFiles{i};
        matName = [];

        % check work dir or not
        if length(fileName) > 5 && strcmp(fileName(end-4:end),'_tpro')
            movieName = fileName(1:end-5);
            % file, dir, or blank name
            fileName = movieName;
        elseif length(fileName) > 4 && strcmp(fileName((end-3):end),'.mat')
            matName = fileName(1:(end-4));
            fileName = matName;
        end

        outPathName = [videoPath fileName '_tpro'];
        outputFileName = [outPathName '/input_video_control.csv'];

        % make control file if not exist
        if exist(outputFileName, 'file')
            openFiles = [openFiles; fileName];
            continue;
        end

        % check if imported file is ctrax mat
        if ~isempty(matName)
            [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted] = loadCtraxMat(videoPath, fileName, 1024);
            if ~isempty(X)
                [dlg, matName, path, bgPath, roiPathes, frames, fps, width, height, import] = newWorkDialog({matName, videoPath, num2str(length(X))});
                delete(dlg);
                pause(0.1);
            end
            if isempty(X) || isempty(matName)
                continue;
            end
        end

        % open video file
        try
            shuttleVideo = TProVideoReader(videoPath, fileName, 0);
        catch e
            disp(['failed to open : ' fileName]);
            errordlg('please select movie files or image folders.', 'Error');
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
            B{5} = str2num(frames);
            B{6} = str2num(frames);
            B{7} = str2num(fps);
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
            % save X, Y, keep_*
            startend = [sprintf('%05d',B{4}) '_' sprintf('%05d',B{5})];
            save([outPathName '/multi/detect_' startend '.mat'], 'X','Y', 'keep_direction_sorted', 'keep_ecc_sorted', 'keep_angle_sorted', 'keep_areas');
            % save keep_count
            save([outPathName '/multi/detect_' startend 'keep_count.mat'], 'keep_count');
        end
        if ~status
            break;
        end

        openFiles = [openFiles; fileName];
    end

    videoFiles = openFiles;
    save('etc/input_videos.mat', 'videoPath', 'videoFiles');
    for n = 1:length(videoFiles)
        row = {videoFiles{n}, videoPath};
        tebleItems = [tebleItems; row];
    end
end