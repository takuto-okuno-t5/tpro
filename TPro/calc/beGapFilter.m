%%
function be_mat = beGapFilter(mat, gap_len)
    frame_num = size(mat, 1);
    fly_num = size(mat, 2);

    % gap completion
    for fn = 1:fly_num
        i = 1;
        while i <= (frame_num - gap_len)
            if((mat(i,fn) == 1) && mat(i+1,fn) == 0)
                active = find(mat((i+1):(i+gap_len),fn) > 0);
                cnt1 = length(active);
                if(cnt1 > 0)
                    mat((i+1):(i+active(1)),fn) = 1;
                    i = i+active(1)-1;
                else
                    i = i+gap_len-1;
                end
            end
            i = i + 1;
        end
    end
    be_mat = mat;
end
