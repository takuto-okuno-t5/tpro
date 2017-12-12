%% load ctrax mat file
function [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_data] = loadCtraxMat(path, fileName, img_h)
    X = {};
    Y = {};
    keep_angle_sorted = {};
    keep_direction_sorted = {};
    keep_areas = {};
    keep_ecc_sorted = {};
    keep_data = {};

    try
        ctrax = load([path fileName]);
    catch e
        disp(['failed to open : ' path fileName]);
        errordlg('please select a mat file.', 'Error');
        return;
    end

    if ~isfield(ctrax, 'ntargets') || ~isfield(ctrax, 'identity') || ~isfield(ctrax, 'x_pos') || ~isfield(ctrax, 'y_pos')
        disp(['seems not Ctrax output : ' path fileName]);
        errordlg('please select a Ctrax output file.', 'Error');
        return;
    end

    % import data
    X = cell(1,length(ctrax.ntargets));
    Y = cell(1,length(ctrax.ntargets));
    keep_angle_sorted = cell(1,length(ctrax.ntargets));
    keep_direction_sorted = cell(1,length(ctrax.ntargets));
    keep_areas = cell(1,length(ctrax.ntargets));
    keep_ecc_sorted = cell(1,length(ctrax.ntargets));
    k = 0;
    for i=1:length(ctrax.ntargets)
        fn = ctrax.ntargets(i);
        s = k + 1;
        k = k + fn;
        % init
        X{i} = zeros(fn,1);
        Y{i} = zeros(fn,1);
        keep_angle_sorted{i} = zeros(1,fn);
        keep_direction_sorted{i} = zeros(2,fn);
        keep_areas{i} = zeros(1,fn);
        keep_ecc_sorted{i} = zeros(1,fn);
        % convert data
        X{i}(:) = img_h - ctrax.y_pos(s:k, 1);
        Y{i}(:) = ctrax.x_pos(s:k, 1);
        angle = ctrax.angle(s:k, 1) + pi/2;
        keep_direction_sorted{i}(2,:) = 10 .* cos(angle);
        keep_direction_sorted{i}(1,:) = 10 .* sin(angle);
        angle = angle .* (180 / pi);
        idx1 = find(angle > 90);
        idx2 = find(angle < -90);
        angle(idx1) = angle(idx1) - 180;
        angle(idx2) = angle(idx2) + 180;
        keep_angle_sorted{i} = angle';
    end
end
