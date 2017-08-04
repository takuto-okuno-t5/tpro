%%
function [status, videoFiles] = openOrNewProject(videoPath, videoFiles, templateFile)
    status = true;
    tmpl = {};
    if ~isempty(templateFile)
        if exist(templateFile, 'file')
            confTable = readtable(templateFile);
            tmpl = table2cell(confTable);
        end
    end

    % write config files if it is empty
    for i = 1:size(videoFiles, 1)
        fileName = videoFiles{i};

        % check work dir or not
        if length(fileName) > 5 && strcmp(fileName(end-4:end),'_tpro')
            movieName = fileName(1:end-5);
            % file, dir, or blank name
            fileName = movieName;
            videoFiles{i} = fileName;
        elseif length(fileName) > 4 && strcmp(fileName((end-3):end),'.mat')
            projName = fileName(1:(end-4));
            fileName = movieName;
            videoFiles{i} = fileName;
        end

        outPathName = [videoPath fileName '_tpro'];
        outputFileName = [outPathName '/input_video_control.csv'];

        % make control file if not exist
        if exist(outputFileName, 'file')
            continue;
        end

        % check if imported file is ctrax mat
        projName = [];
        if length(fileName) > 4 && strcmp(fileName((end-3):end),'.mat')
            [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted] = loadCtraxMat(videoPath, fileName, 1024);
            if ~isempty(X)
                [dlg, projName, path, bgPath, roiPathes, frames, fps, width, height, import] = newWorkDialog({projName, videoPath, num2str(length(X))});
                delete(dlg);
                pause(0.1);
            end
        end

        % open video file
        try
            shuttleVideo = TProVideoReader(videoPath, fileName, 0);
        catch e
            disp(['failed to open : ' fileName]);
            errordlg('please select movie files or image folders.', 'Error');
            status = false;
            return;
        end

        % make directory
        if ~exist(outPathName, 'dir')
            disp(['mkdir : ' outPathName]);
            mkdir(outPathName);
        end

        status = createConfigFiles(shuttleVideo.Name, shuttleVideo.NumberOfFrames, shuttleVideo.FrameRate, tmpl, i, outputFileName);
        if ~status
            break;
        end
    end

    save('etc/input_videos.mat', 'videoPath', 'videoFiles');
end