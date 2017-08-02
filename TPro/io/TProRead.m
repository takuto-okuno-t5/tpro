%%
function img = TProRead(videoStructs, frameNum)
    if isfield(videoStructs, 'files')
        try
            filename = [videoStructs.videoPath videoStructs.Name '/' char(videoStructs.files(frameNum))];
            img = imread(filename);
        catch e
            disp(['failed to read : ' filename]);
            errordlg(['failed to read image file : ' videoStructs.files(frameNum)], 'Error');
        end
    elseif isfield(videoStructs, 'blankWidth')
        filename = [videoStructs.videoPath videoStructs.Name '_tpro/background.png'];
        if exist(filename, 'file')
            img = imread(filename);
        else
            img = zeros(videoStructs.blankHeight, videoStructs.blankWidth);
            img(:,:) = 150;
        end
        if ismatrix(img)
            img = cat(3,img,img,img);
        end
    else
        img = read(videoStructs,frameNum);
    end
end
