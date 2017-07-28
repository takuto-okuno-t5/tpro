%%
function freq = getCountHistgram(data, split)
    rmin = min(data);
    rmax = max(data);
    steps = rmin:((rmax - rmin) / split):rmax;
    freq = zeros(1,length(steps)-1);
    for i=1:(length(steps)-1)
        freq(i) = sum(data >= steps(i) & data < steps(i+1));
    end
end
