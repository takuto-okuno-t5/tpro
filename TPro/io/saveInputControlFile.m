%% save a input_video_control.csv
function status = saveInputControlFile(outputFileName, B)
    % config header
    header = {'Enable', 'Name', 'Dmy1', 'Start', 'End', 'All', 'fps', 'TH', 'mmPixel', 'ROI', 'rej_dist', 'isInvert', ...
        'G_Strength','G_Radius', 'AreaPixel', 'Step', 'BlobSeparate', 'FilterType', 'MaxSeparate', 'isSeparate', 'MaxBlobs', 'DelRectOverlap'};
    % check old compatibility
    if length(B) < 18
        B = [B, 'log', 4, 1, 0, 0];
    end
    try
        T = cell2table(B);
        T.Properties.VariableNames = header;
        writetable(T,outputFileName);
        status = true;
    catch e
        errordlg(['failed to save configuration file : ' outputFileName], 'Error');
        status = false;
    end
end
