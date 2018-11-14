%% 
function outdata = convertColor(data, ints, cols)
    outdata = zeros(size(data,1),size(data,2),3);
    intlen = length(ints);
    % color convert
    for x=1:size(data,1)
        for y=1:size(data,2)
            intensity = data(x,y,1);
            if intensity >= ints(1)
                outdata(x,y,:) = cols(1,:);
            elseif intensity <= ints(intlen)
                outdata(x,y,:) = cols(intlen,:);
            else
                for i=1:intlen-1
                    if ints(i) >= intensity && intensity >= ints(i+1)
                        c = (intensity - ints(i+1)) / (ints(i) - ints(i+1));
                        outdata(x,y,1) = (cols(i,1) - cols(i+1,1)) * c + cols(i+1,1);
                        outdata(x,y,2) = (cols(i,2) - cols(i+1,2)) * c + cols(i+1,2);
                        outdata(x,y,3) = (cols(i,3) - cols(i+1,3)) * c + cols(i+1,3);
                    end
                end
            end
        end
    end
end

