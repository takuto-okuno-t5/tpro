%% TPro Video file (or image folder) reader
function videoStructs = TProVideoReader(videoPath, fileName, frames, fps)
    if isdir([videoPath fileName])
        if length(fileName) > 5 && strcmp(fileName(end-4:end),'_tpro')
            % check to exist movie file or image folder
            movieName = fileName(1:end-5);
            if exist([videoPath movieName], 'file') || isdir([videoPath movieName])
                videoStructs = TProVideoReader(videoPath, movieName, frames, fps);
            end
        else
            videoStructs = struct;
            videoStructs.Name = fileName;
            videoStructs.name = fileName;
            videoStructs.FrameRate = fps;
            listing = dir([videoPath fileName]);
            files = cell(size(listing,1)-2,1);
            namelens = nan(size(listing,1)-2,1);
            for i = 1:(size(listing,1)-2) % not include '.' and '..'
                files{i} = listing(i+2).name;
                namelens(i) = length(files{i});
            end
            if isempty(files)
                %me = MException('TProVideoReader:noImageFiles',['folder (' videoPath fileName ') does not contain any image file.']);
                %throw(me);
                disp(['folder (' videoPath fileName ') does not contain any image file.']);
                return;
            end
            files = sort(files);
            % check flyCapture numbering bug.
            if contains(files{1}, 'fc2_save_', 'IgnoreCase',true) && contains(files{1}, '-0000.', 'IgnoreCase',true)
                % find longer name files.
                strlen = length(files{1});
                idx = find(namelens == strlen+1);
                if ~isempty(idx)
                    longerfiles = files(idx);
                    files(idx) = [];
                    longerfiles = sort(longerfiles);
                    files = [files; longerfiles];
                end
            end
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
        videoStructs.FrameRate = fps;
        videoStructs.videoPath = videoPath;
        videoStructs.NumberOfFrames = frames;
        videoStructs.blankWidth = 1024;
        videoStructs.blankHeight = 1024;
    end
end
