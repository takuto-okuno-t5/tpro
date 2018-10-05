%%
function be_mat = beRightingFilter(side, updown, lv, max_side, min_side, min_lv)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    be_mat = zeros(frame_num,fly_num);

    for fn = 1:fly_num
        lp = 1;
        for i = 1:(frame_num - 1)
            if updown(i,fn) ~= 0
                s1 = side(i,fn);
                s2 = side(lp,fn);
                if (max_side>s1 && s1>=min_side) || (max_side>s2 && s2>=min_side)
                    be_mat(lp:i,fn) = 1;
                end
                lp = i;
            end
            if isnan(lv(i,fn))
                lp = i;
            end
        end
    end
    be_mat(lv<min_lv) = 0;
end
