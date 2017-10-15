%%
function be_mat = beJumpFilter(lv, acc_lv, threshold, acc_threshold)
    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    be_mat = zeros(frame_num,fly_num);

    for fn = 1:fly_num
        lp = 1;
        for i = 1:(frame_num - 1)
            if acc_lv(i,fn) ~= 0
                l1 = lv(i,fn);
                l2 = lv(lp,fn);
                lvmax = max([l1, l2]);
                width = abs(i - lp);
                slope = abs((l2 - l1)/width);
                if(lvmax>=threshold || slope>=acc_threshold)
                    be_mat(lp:i,fn) = 1;
                end
                lp = i;
            end
        end
    end
end
