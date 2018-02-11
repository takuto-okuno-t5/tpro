%% 
function [xlimit, ylimit] = getXYlimit(img_h, img_w, xlimitIn, ylimitIn, rate)
    xcenter = int32(mean(xlimitIn));
    ycenter = int32(mean(ylimitIn));
    xlimit = [int32(xcenter -img_w*0.5/rate +1), int32(xcenter +img_w*0.5/rate)];
    ylimit = [int32(ycenter -img_h*0.5/rate +1), int32(ycenter +img_h*0.5/rate)];
    if xlimit(1) < 1
        xlimit(1) = 1;
    end
    if ylimit(1) < 1
        ylimit(1) = 1;
    end
    if xlimit(2) > img_w
        xlimit(2) = img_w;
    end
    if ylimit(2) > img_h
        ylimit(2) = img_h;
    end
end
