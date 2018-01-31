%%
function [status, B] = createConfigFiles(name, frameNum, frameRate, tmpl, i, outputFileName)
    B = {1, name, '', 1, frameNum, frameNum, frameRate, 0.6, 0.1, 1, 200, 0, 12, 4, 50, 1, 0.4, 'log', 4, 1, 0, 0, ...
         0, 0, 0, 0, 0, 0, ... % tracking mode
         0, 0, 0, 0, ... % sharp and contrast
         0, 0, 0, 0, 0, ... % template matching
         0, 0, 0, 0, 0, 0 ... % wing detection
         };
    if ~isempty(tmpl)
        if size(tmpl,1) >= i
            row = i;
        else
            row = 1;
        end
        B{4} = tmpl{row,4};
        if tmpl{row,5} ~= tmpl{row,6} % when end != all_frame, then set end_frame
            B{5} = tmpl{row,5};
        end
        for j=8:length(B)
            if j <= length(tmpl)
                B{j} = tmpl{row,j};
            end
        end
    end
    status = saveInputControlFile(outputFileName, B);
end