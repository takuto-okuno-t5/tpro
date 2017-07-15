%% TPro Video file (or image folder) reader
function videoStructs = TProVideoReader(videoPath, fileName)
    if isdir([videoPath fileName])
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
    else
        videoStructs = VideoReader([videoPath fileName]);
    end
end
