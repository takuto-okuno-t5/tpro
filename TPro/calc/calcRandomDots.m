%%
function [Y, X] = calcRandomDots(roiMask, startFrame, endFrame, dotNum)
    img_h = size(roiMask,1);
    img_w = size(roiMask,2);
    xsize = endFrame - startFrame + 1;
    X = cell(1,xsize);
    Y = cell(1,xsize);
    rng('shuffle');

    for i = 1:xsize
        fy = rand(dotNum,1) * img_h;
        fx = rand(dotNum,1) * img_w;
        j = 1;
        while j <= dotNum
            y = round(fy(j));
            x = round(fx(j));
            if (y <= img_h) && (x <= img_w) && x >= 1 && y >= 1 && roiMask(y,x) > 0
                j = j + 1;
            else
                fy(j) = rand() * img_h;
                fx(j) = rand() * img_w;
            end
        end
        Y{i} = fy;
        X{i} = fx;
    end
end
