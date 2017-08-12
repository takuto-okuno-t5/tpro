%%
function [X, Y] = calcRandomDots(roiMask, startFrame, endFrame, dotNum)
    img_h = size(roiMask,1);
    img_w = size(roiMask,2);
    xsize = endFrame - startFrame + 1;
    X = cell(1,xsize);
    Y = cell(1,xsize);
    rng('shuffle');

    for i = 1:xsize
        fx = rand(dotNum,1) * img_h;
        fy = rand(dotNum,1) * img_w;
        j = 1;
        while j <= dotNum
            x = round(fx(j));
            y = round(fy(j));
            if (y <= img_h) && (x <= img_w) && x >= 1 && y >= 1 && roiMask(x,y) > 0
                j = j + 1;
            else
                fx(j) = rand() * img_h;
                fy(j) = rand() * img_w;
            end
        end
        X{i} = fx;
        Y{i} = fy;
    end
end
