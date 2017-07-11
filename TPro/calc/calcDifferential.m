
function xx = calcDifferential(x)
    fly_num = size(x, 2);
    xx = diff(x);
    xx = [zeros(1,fly_num);xx];
end
