%% calc angular velocity for angle (not dir)
function av = calcAngularVelocity(angle)
    frame_num = size(angle, 1);
    fly_num = size(angle, 2);

    av = zeros(frame_num,fly_num);
    for fly_n=1:fly_num
        for j=1:(frame_num-1)
            a1 = angle(j,   fly_n);
            a2 = angle(j+1, fly_n);
            adf2 = abs(a2 - a1);
            if(adf2 > 135)
                if(a2 > 0)
                  av(j,fly_n) = (a2 - 180) - a1;
                else
                  av(j,fly_n) = (a2 + 180) - a1;
                end
            else
                av(j,fly_n) = a2 - a1;
            end
        end
    end        
end
