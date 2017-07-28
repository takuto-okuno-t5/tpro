%%
function [status, videoFiles] = createConfigFiles(videoPath, videoFiles, templateFile)
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
        end

        outPathName = [videoPath fileName '_tpro'];
        outputFileName = [outPathName '/input_video_control.csv'];

        % make control file if not exist
        if exist(outputFileName, 'file')
            continue;
        end

        % open video file
        try
            shuttleVideo = TProVideoReader(videoPath, fileName, 0);
        catch e
            errordlg('please select movie files or image folders.', 'Error');
            status = false;
            return;
        end
        name = shuttleVideo.Name;
        frameNum = shuttleVideo.NumberOfFrames;
        frameRate = shuttleVideo.FrameRate;

        % make directory
        if ~exist(outPathName, 'dir')
            mkdir(outPathName);
        end

        B = {1, name, '', 1, frameNum, frameNum, frameRate, 0.6, 0.1, 1, 200, 0, 12, 4, 50, 1, 0.4, 'log', 4, 1, 0, 0};
        if ~isempty(tmpl)
            if size(tmpl,1) >= i
                row = i;
            else
                row = 1;
            end
            B{4} = tmpl{row,4};
            if tmpl{row,5} ~= tmpl{row,6} % when end != all_frame, then set end_frame
                B{5} = tmpl{row,5};
            end
            for j=8:length(B)
                B{j} = tmpl{row,j};
            end
        end
        status = saveInputControlFile(outputFileName, B);
        if ~status
            break;
        end
    end

    save('etc/input_videos.mat', 'videoPath', 'videoFiles');
end