%%
function [ keep_direction, keep_angle ] = PD_direction(grayImage, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient)
% hidden parameters
search_radius = 4;
disk_size = 6;

% init
blobBoxes = double(blobBoxes);
areaNumber = size(blobAreas, 1);
keep_direction = zeros(2, areaNumber); % allocate memory
keep_angle = zeros(1, areaNumber); % allocate memory;

for i = 1:areaNumber
    % calculate angle
    angle = -blobOrient(i)*180 / pi;
    lineLength = blobMajorAxis(i) / 2;
    x(1) = blobCenterPoints(i,1) - blobBoxes(i,1)+1 + disk_size;
    y(1) = blobCenterPoints(i,2) - blobBoxes(i,2)+1 + disk_size;
    x(2) = x(1) + lineLength * cosd(angle);
    y(2) = y(1) + lineLength * sind(angle);

    % search at the end of major axis
    v1 = [x(2)-x(1);y(2)-y(1)];

    % wing ditection TODO: change this later?
    a_point = [x(1);y(1)]+v1;   % in v1 direction
    b_point = [x(1);y(1)]-v1;

    % trim image
    rect = [blobBoxes(i,1)-disk_size blobBoxes(i,2)-disk_size blobBoxes(i,3)+disk_size*2 blobBoxes(i,4)+disk_size*2];
    trimmedImage = imcrop(grayImage, rect);

    count = [0 0];
    range = 0.3:0.05:0.6;  % for Video_14.avi TODO: change this later?

    for j = 1:size(range,2)
        keep2 = im2double(trimmedImage);
        range_begin = range(j);
        ind = find(keep2>(range_begin+0.05));  % find brighter pixel
        ind2 = find(keep2<range_begin); % find darker pixel
        keep2(ind) = NaN;
        keep2(ind2) = NaN;
        keep2(find(~isnan(keep2))) = 1;
        keep2(find(isnan(keep2))) = 0;

        [row_hasvalue, col_hasvalue] = find(keep2==1);
        a_score = sum(((a_point(2)-row_hasvalue).^2+(a_point(1)-col_hasvalue).^2)<(search_radius^2));
        b_score = sum(((b_point(2)-row_hasvalue).^2+(b_point(1)-col_hasvalue).^2)<(search_radius^2));
        envi_score = (sum(((a_point(2)-row_hasvalue).^2+(a_point(1)-col_hasvalue).^2)>(search_radius^2)) + sum(((b_point(2)-row_hasvalue).^2+(b_point(1)-col_hasvalue).^2)<(search_radius^2)) - a_score - b_score ) / 2;

        % calculate direction
        if (a_score > b_score ) && (envi_score < 40) % correct direction
            %                 count(1) = count(1) + 1;
            count(1) = count(1) + a_score - b_score;
            %                 if ((a_score - b_score) > sure_score)
            %                     direction_flag = 1;
            %                     sure_score = a_score - b_score;
            %                 end
        elseif (a_score < b_score ) && (envi_score < 40) % inverse direction
            %                 count(2) = count(2) + 1;
            count(2) = count(2) + b_score - a_score;
            %                 if ((b_score - a_score) > sure_score)
            %                     direction_flag = 0;
            %                     sure_score = b_score - a_score;
            %                 end
        end
    end

    if ((count(1)~=0)||(count(2)~=0)) && (count(1) > count(2))
        direction_vector = -v1;
        %             if direction_flag == 2  % if noone is sure
        %                 direction_flag = 1;
        %             end
    elseif ((count(1)~=0)||(count(2)~=0)) && (count(2) > count(1))
        direction_vector = v1;
        %             if direction_flag == 2  % if noone is sure
        %                 direction_flag = 0;
        %             end
    else
        direction_vector = 0 * v1;    % zero vector
    end

    keep_direction(:,i) = direction_vector;
    keep_angle(:,i) = angle;
end
