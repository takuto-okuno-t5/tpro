%% load ctrax mat file
function [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_data, fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(path, fileName, img_h)
    X = {};
    Y = {};
    keep_angle_sorted = {};
    keep_direction_sorted = {};
    keep_areas = {};
    keep_ecc_sorted = {};
    keep_data = {};
	startframe = 1;
    endframe = 1;
    maxframe = 1;
    fps = 0;
    mmperpx = 0;

    try
        ctrax = load([path fileName]);
    catch e
        disp(['failed to open : ' path fileName]);
        errordlg('please select a mat file.', 'Error');
        return;
    end

    if ~isfield(ctrax, 'trx')
        disp(['seems not janeria tracking output : ' path fileName]);
        errordlg('please select a Ctrax output file.', 'Error');
        return;
    end

    % importing data
    fn = length(ctrax.trx);
    frames = length(ctrax.trx(1).x);
    fps = ctrax.trx(1).fps;
    mmperpx = 1 / ctrax.trx(1).pxpermm;
	startframe = ctrax.trx(1).firstframe;
    endframe = startframe + ctrax.trx(1).nframes - 1;
    maxframe = ctrax.trx(1).endframe;

    % init detection cells
    X = cell(1,frames);
    Y = cell(1,frames);
    keep_angle_sorted = cell(1,frames);
    keep_direction_sorted = cell(1,frames);
    keep_areas = cell(1,frames);
    keep_ecc_sorted = cell(1,frames);

    % init tracking cells
    keep_data = cell(1,8);
    for i = 1:8
        keep_data{i} = nan(frames, fn);
    end

    % janeria trax intermediate table
    jtx = zeros(fn,frames);
    jty = zeros(fn,frames);
    jtth = zeros(fn,frames);
    jta = zeros(fn,frames);
    jtb = zeros(fn,frames);
    for i=1:fn
        jtx(i,:) = ctrax.trx(i).x;
        jty(i,:) = ctrax.trx(i).y;
        jtth(i,:) = ctrax.trx(i).theta;
        jta(i,:) = ctrax.trx(i).a;
        jtb(i,:) = ctrax.trx(i).b;
    end
    % convert
    for i=1:frames
        % init
        X{i} = img_h - jty(:,i);
        Y{i} = jtx(:,i);
        keep_angle_sorted{i} = zeros(1,fn);
        keep_direction_sorted{i} = zeros(2,fn);
        keep_areas{i} = zeros(1,fn);
        keep_ecc_sorted{i} = zeros(1,fn);
        % convert detection
        angle = jtth(:,i);
        keep_direction_sorted{i}(2,:) = 10 .* cos(angle);
        keep_direction_sorted{i}(1,:) = 10 .* sin(angle);
        angle = angle .* (180 / pi);
        idx1 = find(angle > 90);
        idx2 = find(angle < -90);
        angle(idx1) = angle(idx1) - 180;
        angle(idx2) = angle(idx2) + 180;
        keep_angle_sorted{i} = angle';
        % convert tracking
        keep_data{1}(i,:) = X{i}(:,1)';
        keep_data{2}(i,:) = Y{i}(:,1)';
        if i > 1
            keep_data{3}(i,:) = X{i}(:,1)' - X{i-1}(:,1)';
            keep_data{4}(i,:) = Y{i}(:,1)' - Y{i-1}(:,1)';
        else
            keep_data{3}(i,:) = 0;
            keep_data{4}(i,:) = 0;
        end
        keep_data{5}(i,:) = keep_direction_sorted{i}(1,:);   % keep_data{5} and keep_data{6} are for direction
        keep_data{6}(i,:) = keep_direction_sorted{i}(2,:);
        keep_data{7}(i,:) = keep_ecc_sorted{i}(1,:);
        keep_data{8}(i,:) = keep_angle_sorted{i}(1,:);
    end
end
