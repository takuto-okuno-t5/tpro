function xx = calcDifferential2(x)
    fly_num = size(x, 2);
    xx = diff(x);
    xx = [xx;zeros(1,fly_num)];
end

