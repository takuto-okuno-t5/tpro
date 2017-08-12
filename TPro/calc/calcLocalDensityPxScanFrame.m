function [map, counts] = calcLocalDensityPxScanFrame(fx, fy, rr, cc, r, img_h, img_w)
    flyNum = length(fx);
    map = zeros(img_h,img_w);
    for fn=1:flyNum
        cx1=fx(fn);
        cy1=fy(fn);
        C = ((rr-cx1).^2 + (cc-cy1).^2) <= r^2;
        map = map + C;
    end
    % TODO: comment out later
    counts = zeros(1,flyNum+1);
    for i=1:(flyNum+1)
        counts(i) = sum(sum(map==(i-1)));
    end
end
