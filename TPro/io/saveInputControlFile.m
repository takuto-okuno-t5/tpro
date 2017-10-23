%% save a input_video_control.csv
function status = saveInputControlFile(outputFileName, B)
    % check old compatibility
    B = checkConfigCompatibility(B);
    try
        T = cell2table(B);
        T.Properties.VariableNames = getVideoConfigHeader();
        disp(['writetable : ' outputFileName]);
        writetable(T,outputFileName);
        status = true;
    catch e
        disp(['failed to writetable : ' outputFileName]);
        errordlg(['failed to save configuration file : ' outputFileName], 'Error');
        status = false;
    end
end
