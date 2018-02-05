%%
function be_mat = beGroomingFilter(rWingAngle, lWingAngle, lv, groomingTh, lv_th)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    be_mat = zeros(frame_num,fly_num);

    be_mat((rWingAngle >= groomingTh | lWingAngle >= groomingTh) & lv <= lv_th) = 1;
end
