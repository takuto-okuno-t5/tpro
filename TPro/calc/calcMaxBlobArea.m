% calculate maximum blob area
function result = calcMaxBlobArea(shuttleVideo, dlen, startFrame, endFrame, frameSteps, roiImage, blobThreshold)
    hBlobAnls = getVisionBlobAnalysis();
    result = nan(dlen,1);

    tic;
    % calc pixel intensity
    for i=1:dlen
        frameNum = (i-1) * frameSteps + startFrame;
        if frameNum > endFrame
            frameNum = endFrame;
        end

        img = TProRead(shuttleVideo, frameNum);
        if size(img,3) > 1
            img = rgb2gray(img);
        end
        img = imcomplement(img);
        if ~isempty(roiImage)
            img = double(img) .* roiImage;
        end
        img = im2bw(uint8(img), blobThreshold);
        img = bwareaopen(img, 25); % delete pixels less than 25
        % blob analysis
        [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(hBlobAnls, img);
        if isempty(AREA)
            result(i) = 0;
        else
            result(i) = nanmax(AREA);
        end
        if mod(i,200)==0
            rate = i/dlen * 100;
            disp(['calcPixelIntensity : ' num2str(i) '(' num2str(rate) '%)']);
        end
    end
    time = toc;
    disp(['calcPixelIntensity ... done : ' num2str(time) 's']);
end
