% calculate pixel intensity
function result = calcPixelIntensity(shuttleVideo, dlen, startFrame, endFrame, frameSteps)
    tic;
    % calc pixel intensity
    result = nan(dlen,1);
    for i=1:dlen
        frameNum = (i-1) * frameSteps + startFrame;
        if frameNum > endFrame
            frameNum = endFrame;
        end
        img = TProRead(shuttleVideo, frameNum);
        if size(img,3) > 1
            result(i) = mean(mean(mean(img)));
        else
            result(i) = mean(mean(img));
        end
        if mod(i,200)==0
            rate = i/dlen * 100;
            disp(['calcPixelIntensity : ' num2str(i) '(' num2str(rate) '%)']);
        end
    end
    time = toc;
    disp(['calcPixelIntensity ... done : ' num2str(time) 's']);
end
