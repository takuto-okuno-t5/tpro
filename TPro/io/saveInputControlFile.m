%% save a input_video_control.csv
function status = saveInputControlFile(outputFileName, B)
    % config header
    header = {'Enable', 'Name', 'Dmy1', 'Start', 'End', 'All', 'fps', 'TH', 'mmPixel', 'ROI', 'rej_dist', 'Dmy3', 'G_Strength','G_Radius', 'AreaPixel', 'Step', 'BlobSeparate'};
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
