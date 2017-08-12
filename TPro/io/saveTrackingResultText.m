%% save tracking result files
function saveTrackingResultText(dataFileName, keep_data, end_row, flyNum, img_h, img_w, roiMask)
    write_file_x = fopen([dataFileName '_x.txt'],'wt');
    write_file_y = fopen([dataFileName '_y.txt'],'wt');
    write_file_vx = fopen([dataFileName '_vx.txt'],'wt');
    write_file_vy = fopen([dataFileName '_vy.txt'],'wt');
    write_file_vxy = fopen([dataFileName '_vxy.txt'],'wt');
    write_file_dir = fopen([dataFileName '_dir.txt'],'wt');    % direction 2016-11-10
%    write_file_dd = fopen([dataFileName '_dd.txt'],'wt');    % direction 2016-11-10
%    write_file_dd2 = fopen([dataFileName '_dd2.txt'],'wt');    % direction 2016-11-11
    write_file_ecc = fopen([dataFileName '_ecc.txt'],'wt');    % direction 2016-11-29
    write_file_angle = fopen([dataFileName '_angle.txt'],'wt');    % bodyline 2017-03-17
%    write_file_dis = fopen([dataFileName '_dis.txt'],'wt');
%    write_file_svxy = fopen([dataFileName '_svxy.txt'],'wt');

    % cook raw data before saving
    for row_count = 1:end_row
        fx = keep_data{2}(row_count, :);
        fy = keep_data{1}(row_count, :);
        vx = keep_data{4}(row_count, :);
        vy = keep_data{3}(row_count, :);
        ddx = keep_data{6}(row_count, :);
        ddy = keep_data{5}(row_count, :);
        ecc = keep_data{7}(row_count, :);
        angle = keep_data{8}(row_count, :);
%        if row_count > 1
%            distance_travel = sqrt((fx - keep_data{2}(row_count-1, :)).^2 + (fy - keep_data{1}(row_count-1, :)).^2);
%        end
        Y = round(fy);
        X = round(fx);
        nanIdxY = find((Y > img_h) | (Y < 1));
        nanIdxX = find((X > img_w) | (X < 1));
        roiIdx = (X-1).*img_h + Y;
        roiIdx(isnan(roiIdx)) = 1; % TOOD: set dummy. this might be bad with empty ROI.
        roiIdx2 = find(roiMask(roiIdx) <= 0);
        nanIdx = unique([nanIdxY, nanIdxX, roiIdx2]);
        if ~isempty(nanIdx)
            fx(nanIdx) = NaN; fy(nanIdx) = NaN;
            vx(nanIdx) = NaN; vy(nanIdx) = NaN;
            ddx(nanIdx) = NaN; ddy(nanIdx) = NaN;
            ecc(nanIdx) = NaN;
            angle(nanIdx) = NaN;
        end
        % make save string
        roiFlyNum = length(fx);
        fmtString = generatePrintFormatString(roiFlyNum);

        fprintf(write_file_x, fmtString, fx);
        fprintf(write_file_y, fmtString, img_h - fy);
%        if row_count > 1
%            fprintf(write_file_dis, fmtString, distance_travel);
%        end
        fprintf(write_file_vy, fmtString, (-1).*vy);
        fprintf(write_file_vx, fmtString, vx);
        vxy = sqrt( vy.^2 +  vx.^2 );
        fprintf(write_file_vxy, fmtString, vxy);

        if row_count > 1
            v0 = v1;    % v2 contains the previous v1
        else
            v0 = [ddy; (-1).*ddx];
        end
        v1 = [ddy; (-1).*ddx];
        check_v1 = sum(v1.*v1);
        v1(:,check_v1==0) = NaN;
        angle_v1 = atan2d(v1(2,:),v1(1,:));

        %{
        if row_count == 1
            fprintf(write_file_dd, fmtString, (0).*ddy );
            fprintf(write_file_dd2, fmtString, (0).*ddy );
        else
            angle_v0 = atan2d(v0(2,:),v0(1,:));
            angle_v1_v0 = angle_v1 - angle_v0;  % in degree
            for i_angle_mo = 1:size(angle_v1_v0,2)
                if angle_v1_v0(i_angle_mo) > 180
                    angle_v1_v0(i_angle_mo) = angle_v1_v0(i_angle_mo)-360;
                elseif angle_v1_v0(i_angle_mo) < -180
                    angle_v1_v0(i_angle_mo) = angle_v1_v0(i_angle_mo)+360;
                end
            end
            angle_v1_v0_2 = angle_v1_v0;
            for i_angle_mo = 1:size(angle_v1_v0_2,2)
                if angle_v1_v0_2(i_angle_mo) > 90
                    angle_v1_v0_2(i_angle_mo) = 180 - angle_v1_v0_2(i_angle_mo);
                elseif angle_v1_v0_2(i_angle_mo) < -90
                    angle_v1_v0_2(i_angle_mo) = 180 + angle_v1_v0_2(i_angle_mo);
                end
                angle_v1_v0_2(i_angle_mo) = abs(angle_v1_v0_2(i_angle_mo));
            end
            fprintf(write_file_dd, fmtString, angle_v1_v0 );
            fprintf(write_file_dd2, fmtString, angle_v1_v0_2 );
        end
        %}
        fprintf(write_file_dir, fmtString, angle_v1 );
        fprintf(write_file_ecc, fmtString, ecc);
        fprintf(write_file_angle, fmtString, angle);

        % calculate sideway velocity
        %{
        bodyline_y = v1(2,:);
        bodyline_x = v1(1,:);
        % fill nan with data from angle
        nan_index = isnan(bodyline_y);
        bodyline_y(nan_index) = sind(angle(nan_index));
        bodyline_x(nan_index) = cosd(angle(nan_index));
        vy = (-1).*vy;
        setA = [bodyline_x' bodyline_y' zeros(size(bodyline_x,2),1)];
        setB = [vx' vy' zeros(size(vx,2),1)];
        corss_pro = cross(setA,setB);
        norm_setA = sqrt(sum(abs(setA).^2,2));
        svxy = corss_pro(:,3)./norm_setA;
        fprintf(write_file_svxy, fmtString, svxy');   % sideway velocity
        %}
%                 dir_vxy = atan2d(vy,vx);
%                 angle_for_svxy = dir_vxy-angle_v1;
%                 fprintf(write_file_svxy, fmtString, vxy.*sind(angle_for_svxy));
    end

    fclose(write_file_x);
    fclose(write_file_y);
    fclose(write_file_vx);
    fclose(write_file_vy);
    fclose(write_file_vxy);
    fclose(write_file_dir);
%    fclose(write_file_dd);
%    fclose(write_file_dd2);
    fclose(write_file_ecc);
    fclose(write_file_angle);
%    fclose(write_file_dis);
%    fclose(write_file_svxy);
end
