%%
function [Y, X] = calcRandomMove(roiMask, startFrame, endFrame, dotNum, maxVelocity)
    img_h = size(roiMask,1);
    img_w = size(roiMask,2);
    xsize = endFrame - startFrame + 1;
    X = cell(1,xsize);
    Y = cell(1,xsize);
    rng('shuffle');

    % initialize
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
    Y{1} = fy;
    X{1} = fx;

    % random move
    for i = 2:xsize
        dir = rand(dotNum,1) * 2 * pi; 
        v = rand(dotNum,1) * maxVelocity;
        fy = cos(dir) .* v;
        fx = sin(dir) .* v;
        ly = Y{i-1};
        lx = X{i-1};
        j = 1;
        while j <= dotNum
            y = round(ly(j) + fy(j));
            x = round(lx(j) + fx(j));
            if (y <= img_h) && (x <= img_w) && x >= 1 && y >= 1 && roiMask(y,x) > 0
                fy(j) = y;
                fx(j) = x;
                j = j + 1;
            else
                fy(j) = ly(j);
                fx(j) = lx(j);
                j = j + 1;
            end
        end
        Y{i} = fy;
        X{i} = fx;
    end
end
