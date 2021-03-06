%% load ctrax mat file
function [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted, keep_wings_sorted, keep_gender, keep_data, keep_mean_blobmajor, keep_mean_blobminor, fps, mmperpx, startframe, endframe, maxframe] = loadJaneriaTraxMat(path, fileName, img_h)
    X = {};
    Y = {};
    keep_angle_sorted = {};
    keep_direction_sorted = {};
    keep_areas = {};
    keep_ecc_sorted = {};
    keep_wings_sorted = {};
    keep_gender = {};
    keep_data = {};
    keep_mean_blobmajor = [];
    keep_mean_blobminor = [];
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
    keep_wings_sorted = cell(1,frames);
    keep_gender = cell(1,1);
    keep_mean_blobmajor = nan(1,frames);
    keep_mean_blobminor = nan(1,frames);

    % init tracking cells
    keep_data = cell(1,11);
    for i = 1:10
        keep_data{i} = nan(frames, fn);
    end
    keep_data{11} = nan(1, fn);

    % janeria trax intermediate table
    jtx = nan(fn,frames);
    jty = nan(fn,frames);
    jtth = nan(fn,frames);
    jta = nan(fn,frames);
    jtb = nan(fn,frames);
    jwl = nan(fn,frames);
    jwr = nan(fn,frames);
    jgen = nan(fn,1);
    firstframe = ctrax.trx(1).firstframe;
    for i=1:fn
        st = ctrax.trx(i).firstframe - firstframe + 1;
        ed = st + size(ctrax.trx(i).x, 2) - 1;
        jtx(i,st:ed)  = ctrax.trx(i).x;
        jty(i,st:ed)  = ctrax.trx(i).y;
        jtth(i,st:ed) = ctrax.trx(i).theta;
        jta(i,st:ed)  = ctrax.trx(i).a;
        jtb(i,st:ed)  = ctrax.trx(i).b;
        jwl(i,st:ed)  = ctrax.trx(i).wing_anglel;
        jwr(i,st:ed)  = ctrax.trx(i).wing_angler;
        genstr = ctrax.trx(i).sex{1};
        if strcmp(genstr,'M')
            jgen(i,1) = 1; % male
        elseif strcmp(genstr,'F')
            jgen(i,1) = 2; % female
        end
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
        keep_wings_sorted{i} = zeros(2,fn);
        % convert detection
        angle = jtth(:,i) + pi / 2;
        bsize = jta(:,i) ./ 3 ./ mmperpx;
        keep_direction_sorted{i}(2,:) = bsize .* cos(angle);
        keep_direction_sorted{i}(1,:) = bsize .* sin(angle);
        angle = angle .* (180 / pi);
        idx1 = find(angle > 90);
        idx2 = find(angle < -90);
        angle(idx1) = angle(idx1) - 180;
        angle(idx2) = angle(idx2) + 180;
        keep_angle_sorted{i} = angle';
        % convert ecc
        keep_mean_blobmajor(i) = nanmean(jta(:,i)') / mmperpx;
        keep_mean_blobminor(i) = nanmean(jtb(:,i)') / mmperpx;
        keep_ecc_sorted{i} = sqrt(1 - (jtb(:,i)'.* jtb(:,i)') ./ (jta(:,i)' .* jta(:,i)'));
        % convert wings
        wrAngle = (pi - jwr(:,i) - jtth(:,i)) .* (180 / pi); % fly's right wing angle;
        wlAngle = (pi - jwl(:,i) - jtth(:,i)) .* (180 / pi); % fly's left wing angle
        keep_wings_sorted{i}(1,:) = wrAngle';
        keep_wings_sorted{i}(2,:) = wlAngle';
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
        keep_data{9}(i,:) = keep_wings_sorted{i}(1,:);
        keep_data{10}(i,:) = keep_wings_sorted{i}(2,:);
    end
    keep_gender{1} = jgen;
    keep_data{11} = jgen;
end
