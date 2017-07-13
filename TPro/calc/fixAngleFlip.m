%%
function t_angle = fixAngleFlip(t_angle, start_frame, end_frame)
    for fly_n=1:size(t_angle,2)
        for j=(start_frame+1):(end_frame-3)
            a0 = t_angle(j-1, fly_n);
            a1 = t_angle(j,   fly_n);
            a2 = t_angle(j+1, fly_n);
            a3 = t_angle(j+2, fly_n);
            a4 = t_angle(j+3, fly_n);
            adf1 = abs(a1 - a0);
            adf2 = abs(a2 - a1);
            adf3 = abs(a3 - a2);
            adf4 = abs(a4 - a3);
            if(adf1 < 240 && adf1 > 120 && adf2 < 240 && adf2 > 120)
                if(a1 > 0)
                    t_angle(j, fly_n) = a1 - 180;
                else
                    t_angle(j, fly_n) = a1 + 180;
                end
            elseif(adf1 < 240 && adf1 > 120 && adf2 < 45 && adf3 < 240 && adf3 > 120)
                if(a1 > 0)
                    t_angle(j, fly_n) = a1 - 180;
                    t_angle(j+1, fly_n) = a2 - 180;
                else
                    t_angle(j, fly_n) = a1 + 180;
                    t_angle(j+1, fly_n) = a2 + 180;
                end
            elseif(adf1 < 240 && adf1 > 120 && adf2 < 45 && adf3 < 45 && adf4 < 240 && adf4 > 120)
                if(a1 > 0)
                    t_angle(j, fly_n) = a1 - 180;
                    t_angle(j+1, fly_n) = a2 - 180;
                    t_angle(j+2, fly_n) = a3 - 180;
                else
                    t_angle(j, fly_n) = a1 + 180;
                    t_angle(j+1, fly_n) = a2 + 180;
                    t_angle(j+2, fly_n) = a3 + 180;
                end
            end
        end
    end
end
