% calculate pixel intensity
function result = calcPixelIntensity(shuttleVideo, dlen, startFrame, endFrame, frameSteps, roiImage)
    tic;
    % calc pixel intensity
    if ~isempty(roiImage)
        roiImage = double(roiImage);
        roiImage(roiImage==0) = NaN;
    end
    result = nan(dlen,1);
    for i=1:dlen
        frameNum = (i-1) * frameSteps + startFrame;
        if frameNum > endFrame
            frameNum = endFrame;
        end
        img = TProRead(shuttleVideo, frameNum);
        if size(img,3) > 1
            img = rgb2gray(img);
        end
        if ~isempty(roiImage)
            img = double(img) .* roiImage;
        end
        result(i) = nanmean(nanmean(img));

        if mod(i,200)==0
            rate = i/dlen * 100;
            disp(['calcPixelIntensity : ' num2str(i) '(' num2str(rate) '%)']);
        end
    end
    time = toc;
    disp(['calcPixelIntensity ... done : ' num2str(time) 's']);
end
