%%
function be_mat = beClimbFilter(ecc, lv, threshold, lv_max)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);

    be_mat = zeros(frame_num,fly_num);
    be_mat(ecc <= threshold & lv <= lv_max) = 1;
end
