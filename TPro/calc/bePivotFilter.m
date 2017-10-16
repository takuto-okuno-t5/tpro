%%
function be_mat = bePivotFilter(av, lv, threshold, lv_max)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    abs_av = abs(av);  % get absolute value of angler velocity

    be_mat = zeros(frame_num,fly_num);
    be_mat(abs_av >= threshold & lv <= lv_max) = 1;
end
