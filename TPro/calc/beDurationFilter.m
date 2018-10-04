%%
function be_mat = beDurationFilter(mat, threshold)
    frame_num = size(mat, 1);
    fly_num = size(mat, 2);
    
    if threshold > 10 % put GAP filter last 10 frames
        mat((frame_num-9):frame_num,:) = 1;
    end
    for fn = 1:fly_num
        cnt = 0;
        for i = 1:frame_num
            if mat(i,fn) > 0
                cnt = cnt + 1;
            elseif cnt > 0
                if cnt < threshold
                    mat((i-cnt):i,fn) = 0;
                end
                cnt = 0;
            end
        end
    end
    if threshold > 10 % clear GAP filter last 10 frames
        for fn = 1:fly_num
            if mat(frame_num-10,fn) == 0
                mat((frame_num-9):frame_num,fn) = 0;
            end
        end
    end
    be_mat = mat;
end
