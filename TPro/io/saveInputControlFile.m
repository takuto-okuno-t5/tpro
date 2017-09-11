%% save a input_video_control.csv
function status = saveInputControlFile(outputFileName, B)
    % config header
    header = {'Enable', 'Name', 'Dmy1', 'Start', 'End', 'All', 'fps', 'TH', 'mmPixel', 'ROI', 'rej_dist', 'isInvert', ...
        'G_Strength','G_Radius', 'AreaPixel', 'Step', 'BlobSeparate', ...
        'FilterType', 'MaxSeparate', 'isSeparate', 'MaxBlobs', 'DelRectOverlap', ...
        'rRate', 'gRate', 'bRate', 'keepNear', 'fixedTrackNum', 'fixedTrackDir'};
    % check old compatibility
    B = checkConfigCompatibility(B);
    try
        T = cell2table(B);
        T.Properties.VariableNames = header;
        disp(['writetable : ' outputFileName]);
        writetable(T,outputFileName);
        status = true;
    catch e
        disp(['failed to writetable : ' outputFileName]);
        errordlg(['failed to save configuration file : ' outputFileName], 'Error');
        status = false;
    end
end
