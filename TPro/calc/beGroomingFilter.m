%%
function be_mat = beGroomingFilter(rWingAngle, lWingAngle, rwav, lwav, lv, waTh, wavTh, lvTh)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    be_rmat = zeros(frame_num,fly_num);
    be_lmat = zeros(frame_num,fly_num);

    rwav = abs(rwav);
    lwav = abs(lwav);
    be_rmat(rWingAngle >= waTh & rwav >= wavTh & (isnan(lwav) | lwav < wavTh*2) & lv <= lvTh) = 1;
    be_lmat(lWingAngle >= waTh & lwav >= wavTh & (isnan(rwav) | rwav < wavTh*2) & lv <= lvTh) = 1;
    be_mat = be_rmat | be_lmat;
end
