%%
function ret = expandColor(colors, num)
    ret = zeros(num,3);
    clen = length(colors);
    clen2 = floor(num / (clen-1));
    for i = 1:(clen-1)
        col1 = colors{i};
        col2 = colors{i+1};
        for j = 1:(clen2-1)
            ret(j + clen2*(i-1),:) = (col1 .* (clen2-j-1) + col2 .* (j-1)) ./ (clen2-1);
        end
        ret(clen2 + clen2*(i-1),:) = col2;
    end
    ret(num,:) = colors{i+1};
end
