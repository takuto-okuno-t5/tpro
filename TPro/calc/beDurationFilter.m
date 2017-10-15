%%
function be_mat = beDurationFilter(mat, threshold)
    frame_num = size(mat, 1);
    fly_num = size(mat, 2);
    
    mat(frame_num+1,:) = 0;
    for fn = 1:fly_num
        cnt = 0;
        for i = 1:(frame_num + 1)
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
    mat(frame_num+1,:) = [];
    be_mat = mat;
end
