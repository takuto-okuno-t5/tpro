%%
function hBlobAnls = getVisionBlobAnalysis()
    hBlobAnls = vision.BlobAnalysis;
    hBlobAnls.MaximumCount = 200;
    hBlobAnls.MajorAxisLengthOutputPort = 1;
    hBlobAnls.MinorAxisLengthOutputPort = 1;
    hBlobAnls.OrientationOutputPort = 1;
    hBlobAnls.EccentricityOutputPort = 1;
    hBlobAnls.ExtentOutputPort = 1; % just dummy for matlab 2015a runtime. if removing this, referense error happens.
end