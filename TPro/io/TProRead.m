%%
function img = TProRead(videoStructs, frameNum)
    if isfield(videoStructs, 'files')
        try
            filename = [videoStructs.videoPath videoStructs.Name '/' char(videoStructs.files(frameNum))];
            img = imread(filename);
        catch e
            errordlg(['failed to read image file : ' videoStructs.files(frameNum)], 'Error');
        end
    else
        img = read(videoStructs,frameNum);
    end
end
