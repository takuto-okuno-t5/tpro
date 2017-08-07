function sideways = calcSideways(x, y, dir) 
    frame_num = size(dir, 1);
    fly_num = size(dir, 2);

    xx = diff(x);
    xx = [zeros(1,fly_num);xx];
    yy = diff(y);
    yy = [zeros(1,fly_num);yy];
    yy = -yy;

    deg = acos((xx ./ sqrt((xx.*xx + yy.*yy)))) * (180/pi);
    deg(isnan(yy)) = NaN;
    deg(yy<0) = -deg(yy<0);

    sideways = abs(sin((pi/180)*(deg - dir)));
end
