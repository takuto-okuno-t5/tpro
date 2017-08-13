%% 
function countFliesEachROI(handles, X, Y, roiNum, roiMasks, roiMaskImage)
    img_h = size(roiMaskImage,1);
    img_w = size(roiMaskImage,2);
    xsize = size(X, 2);
    flyCounts = zeros(xsize,1);
    for i=1:roiNum
        roiCount = zeros(xsize,1);
        % count flies by each ROI
        for row_count = 1:xsize
            fx = X{row_count}(:);
            fy = Y{row_count}(:);
            flyNum = length(fx);
            flyCounts(row_count) = flyNum;
            roiCount(row_count) = countRoiFly(fy,fx,img_h,img_w,flyNum,roiMasks{i});
        end
        setappdata(handles.figure1,['count_' num2str(i)],roiCount); % set axes data
    end
    setappdata(handles.figure1,'count_0',flyCounts); % set axes data
end

