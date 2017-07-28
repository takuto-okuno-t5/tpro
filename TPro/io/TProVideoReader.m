%% TPro Video file (or image folder) reader
function videoStructs = TProVideoReader(videoPath, fileName, frames)
    if isdir([videoPath fileName])
        if length(fileName) > 5 && strcmp(fileName(end-4:end),'_tpro')
            % check to exist movie file or image folder
            movieName = fileName(1:end-5);
            if exist([videoPath movieName], 'file') || isdir([videoPath movieName])
                videoStructs = TProVideoReader(videoPath, movieName, frames);
            end
        else
            videoStructs = struct;
            videoStructs.Name = fileName;
            videoStructs.name = fileName;
            videoStructs.FrameRate = 30; % not sure. just set 30
            listing = dir([videoPath fileName]);
            files = cell(size(listing,1)-2,1);
            for i = 1:(size(listing,1)-2) % not include '.' and '..'
                files{i} = listing(i+2).name;
            end
            files = sort(files);
            videoStructs.files = files;
            videoStructs.videoPath = videoPath;
            videoStructs.NumberOfFrames = size(files,1);
        end
    elseif exist([videoPath fileName], 'file')
        videoStructs = VideoReader([videoPath fileName]);
    else
        % blank screen mode
        videoStructs = struct;
        videoStructs.Name = fileName;
        videoStructs.name = fileName;
        videoStructs.FrameRate = 30; % not sure. just set 30
        videoStructs.videoPath = videoPath;
        videoStructs.NumberOfFrames = frames;
        videoStructs.blankWidth = 1024;
        videoStructs.blankHeight = 1024;
    end
end
