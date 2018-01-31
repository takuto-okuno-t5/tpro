%%
function outConf = checkConfigCompatibility(inConf)
    outConf = inConf;
    if length(outConf) < 18
        outConf = [outConf, 'log', 4, 1, 0, 0];
    end
    if length(outConf) < 23 % tracking mode
        outConf = [outConf, 1, 1, 1, 0, 0, 0];
    end
    if length(outConf) < 29 % sharp and contrast
        outConf = [outConf, 0, 0, 0, 0];
    end
    if length(outConf) < 33 % template matching
        outConf = [outConf, 0, 0, 0, 0, 0];
    end
    if length(outConf) < 38 % wing detection
        outConf = [outConf, 0, 0, 0, 0, 0, 0];
    end
end