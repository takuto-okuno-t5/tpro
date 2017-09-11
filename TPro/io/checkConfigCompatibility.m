%%
function outConf = checkConfigCompatibility(inConf)
    outConf = inConf;
    if length(outConf) < 18
        outConf = [outConf, 'log', 4, 1, 0, 0];
    end
    if length(outConf) < 23
        outConf = [outConf, 1, 1, 1, 0, 0, 0];
    end
end