function map = calcLocalDensityPxScanFrame(fx, fy, rr, cc, r, img_h, img_w)
    map = zeros(img_h,img_w);
    for fn=1:length(fx)
        cx1=fx(fn);
        cy1=fy(fn);
        C = ((rr-cx1).^2 + (cc-cy1).^2) <= r^2;
        map = map + C;
    end
end
