%%
function be_mat = beSleepFilter(lv, updown, max_lv, min_lv, slope_th)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    be_mat = zeros(frame_num,fly_num);

    for fn = 1:fly_num
        lp = 1;
        for i = 1:(frame_num - 1)
            if updown(i,fn) ~= 0
                l1 = lv(i,fn);
                l2 = lv(lp,fn);
                if (max_lv>l1 && l1>=min_lv) || (max_lv>l2 && l2>=min_lv)
                    if l1<min_lv || l2<min_lv
                        width = abs(i - lp);
                        slope = abs((l2 - l1)/width);
                        if slope < slope_th || width > 5
                            be_mat(lp:i,fn) = 1;
                        end
                    elseif l1<max_lv && l2<max_lv
                        be_mat(lp:i,fn) = 1;
                    end
                end
                lp = i;
            end
        end
    end
end
