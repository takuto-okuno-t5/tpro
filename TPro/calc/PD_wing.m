function [ keep_direction, XY_update_to_keep_direction, keep_ecc ] = PD_wing( H, img, img_gray, blob_img_logical, X_update2, Y_update2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

search_radius = 4;

disk_size = 6;
%     SE = strel('disk',disk_size,0);

linearInd = sub2ind(size(blob_img_logical), round(X_update2), round(Y_update2));

[AREA,CENTROID,BBOX,MAJORAXIS,MINORAXIS,ORIENTATION,ECCENTRICITY] = step(H,blob_img_logical);

BBOX = double(BBOX);
labeledImage = bwlabel(blob_img_logical);   % label the image

XY_update_to_keep_direction = labeledImage(linearInd);
keep_direction = [];
keep_ecc = [];

% test
% i_index = 14;   %26
% i_index = 26;

%%% test ok
figure
fig_num = 7;
for test_count = 1 : size(AREA,1)
    % for test_count = 1 : 1
    clf
    i_index = test_count;   %26, 14
    index = i_index;
    %     keep = img_gray(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
    keep = img(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
    keep3 = blob_img_logical(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
    x(1) = CENTROID(index,1)-BBOX(index,1)+1 + disk_size;
    y(1) = CENTROID(index,2)-BBOX(index,2)+1 + disk_size;
    
    imgN = double(keep-min(keep(:)))/double(max(keep(:)-min(keep(:))));
    %[1] Otsu, N., "A Threshold Selection Method from Gray-Level Histograms," IEEE Transactions on Systems, Man, and Cybernetics, Vol. 9, No. 1, 1979, pp. 62-66.
    th1 = graythresh(imgN);
    th2 = graythresh(imgN(imgN>th1));
    cellMsk = imgN>th1;
    nucMsk = imgN>th2;
    filtered = (cellMsk+nucMsk)./2;
    Kaverage = filter2(fspecial('average',3),filtered);
    Kmedian = medfilt2(filtered);
    subplot(1, fig_num, 1);
    imshow(keep)
    subplot(1, fig_num, 2);
    imshow(filtered)
    subplot(1, fig_num, 3);
    imshow(Kaverage)
    subplot(1, fig_num, 4);
    imshow(Kmedian)
    subplot(1, fig_num, 5);
    imshow(keep3)
    BW_filtered = im2bw(Kmedian, 0.8);
    inv_BW_filtered = ~BW_filtered;
    subplot(1, fig_num, 6);
    imshow(~BW_filtered)
    skel = bwmorph(inv_BW_filtered,'thin',inf);
    subplot(1, fig_num, 7);
    imshow(skel)
    
    filename2 = [sprintf('%03d',test_count) '.png'];
    saveas(gcf,strcat('./output/','test_graythresh','/',filename2))
    pause(0.001)
    
    
    [y_skel, x_skel]=find(skel==1);
    pts_skel = [x_skel, y_skel];
    r = hypot(pts_skel(:,1)-x(1),pts_skel(:,2)-y(1));
    pts_skel_circle = [pts_skel(r<=6,1),pts_skel(r<=6,2)];
    %     plot(pts_skel(r<=6,1),pts_skel(r<=6,2),'go')
    
    inlr_th = 8;
    iterNum = size(pts_skel_circle,1);
    [ theta, rho, inlrNum, direction ] = ransac_circle( [x(1) y(1)]', pts_skel_circle', iterNum, 2, 0.5 , 0);    % mode 0 is not random
    theta_chosen = theta(inlrNum > inlr_th);
    %     tbl = tabulate(theta_chosen)
    a = unique(theta_chosen);
    out = [a,histc(theta_chosen(:),a)];
    
    if ~isempty(out)
        
        
        
        if size(out,1)>3
            k = 3;
        else
            k = size(out,1);
        end
        
        opts = statset('Display','final');
        [idx,C] = kmeans(out(:,1),k,'Distance','cityblock','Replicates',1,'Options',opts);
        
        [y_pts, x_pts] = find(inv_BW_filtered ==1);
        pts = [x_pts, y_pts]';
        ptNum = size(pts,2);
        thDist = 3;
        inlr_th2 = 100;
        keep_theta = [];
        
        for C_count = 1:size(C,1)
            x(2) = x(1) + 1 * cos(-C(C_count));
            y(2) = y(1) + 1 * sin(-C(C_count));
            ptSample = [x(1) x(2); y(1) y(2)];
            d = ptSample(:,2) - ptSample(:,1);
            d = d/norm(d); % direction vector of the line
            %         plot(x(2),y(2),'r.')
            n = [-d(2),d(1)]; % unit normal vector of the line
            dist1 = n*(pts-repmat(ptSample(:,1),1,ptNum));
            inlier1 = find(abs(dist1) < thDist);
            inlr_Num = length(inlier1);
            if inlr_Num > inlr_th2
                keep_theta = [keep_theta; -C(C_count)];  % x(2) = x(1) + 1 * cos(keep_theta);   y(2) = y(1) + 1 * sin(keep_theta);
            end
        end
        
        group_theta_th = 5; % degree
        threshold = group_theta_th/180*pi;
        sortedArray = sort(keep_theta');
        nPerGroup = diff(find([1 (diff(sortedArray) > threshold) 1]));
        groupArray = mat2cell(sortedArray,1,nPerGroup);
        keep_theta_2 = [];
        for keep_theta_count = 1:size(groupArray,2)
            keep_theta_2(keep_theta_count) = mean(groupArray{keep_theta_count});
        end
        clf
        imshow(keep)
        hold
        plot(x(1),y(1),'rx','markers',12,'LineWidth',2)
        x_2 = x(1) + 8 * cos(keep_theta_2);
        y_2 = y(1) + 8 * sin(keep_theta_2);
        for plot_count = 1:size(x_2,2)
            plot([x(1) x_2(plot_count)],[y(1) y_2(plot_count)],'b','LineWidth',2);
        end
        
        filename2 = [sprintf('%03d',test_count) '.png'];
        saveas(gcf,strcat('./output/','test_wing','/',filename2))
        pause(0.001)
        %     branch_point = bwmorph(skel,'branchpoints');
        
    end
    
end

keyboard

for i_index = 1:size(AREA,1)    %26
    
    % wing detection
    index = i_index;
    
    angle = -ORIENTATION(index)*180/pi;
    lineLength = MAJORAXIS(index)/2;
    x(1) = CENTROID(index,1)-BBOX(index,1)+1 + disk_size;
    y(1) = CENTROID(index,2)-BBOX(index,2)+1 + disk_size;
    x(2) = x(1) + lineLength * cosd(angle);
    y(2) = y(1) + lineLength * sind(angle);
    
    %%% add new
    %         blob_img_logical2 = blob_img_logical.*(labeledImage==index);
    %         blob_img_logical2 = imdilate(blob_img_logical2,SE); % time consumtion
    
    %%%
    
    %         blob = blob_img_logical2(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
    
    keep = img_gray(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
    keep3 = blob_img_logical(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
    
    %         range = 0.3:(0.55-0.3)/(6-1):0.55;  % for Video_14.avi
    range = 0.3:0.05:0.6;  % for Video_14.avi
    %         range = 0.05:0.05:0.3;  % for 1-1.avi
    
    direction_flag = 2;
    count = [0 0];
    %         sure_score = 200;
    
    for i = 1:size(range,2)
        
        keep2 = im2double(keep);
        keep4 = im2double(~keep3);
        
        
        %         range_begin = range(i);
        range_begin = 0.55
        ind = find(keep2>(range_begin+0.05));  % find brighter pixel
        ind2 = find(keep2<range_begin); % find darker pixel
        keep2(ind) = NaN;
        keep2(ind2) = NaN;
        keep2(find(~isnan(keep2))) = 1;
        keep2(find(isnan(keep2))) = 0;
        
        keep2 = keep2.*keep4;
        
        figure
        imshow(keep2)
        
        %%
        figure
        imshow(img)
        figure
        imshow(img_gray)
        figure
        imhist(img)
        figure;
        imshowpair(img,img_gray,'montage')
        figure;
        imshowpair(img(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size),img_gray(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size),'montage')
        figure
        imhist(img(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size))
        figure
        imshow(labeledImage)
        
        % test gmm
        figure
        for test_count = 1 : size(AREA,1)
            clf
            i_index = test_count;   %26, 14
            index = i_index;
            keep = img_gray(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
            %     keep = img(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
            
            [counts,binLocations] = imhist(keep);
            
            
            subplot(3,2,[1 3 5]);
            imshow(keep)
            
            subplot(3, 2, 2);
            stem(binLocations, counts, 'MarkerSize', 1 );
            
            X = keep(:);
            options = statset('MaxIter', 300); % default value is 100. Sometimes too few to converge
            
            gm = gmdistribution.fit(double(X),3, 'Options', options);
            
            subplot(3, 2, 4);
            plot(binLocations, pdf(gm,binLocations));
            
            subplot(3, 2, 6);
            for j=1:3
                line(binLocations,gm.PComponents(j)*normpdf(binLocations,gm.mu(j),sqrt(gm.Sigma(j))),'color','r');
            end
            
            %     f=getframe;
            filename2 = [sprintf('%03d',test_count) '.png'];
            %     imwrite(f.cdata,strcat('./output/','test_gmm','/',filename2));
            saveas(gcf,strcat('./output/','test_gmm','/',filename2))
            pause(0.001)
            
        end
        
        
        
        %%%
        
        imgN = double(keep-min(keep(:)))/double(max(keep(:)-min(keep(:))));
        %[1] Otsu, N., "A Threshold Selection Method from Gray-Level Histograms," IEEE Transactions on Systems, Man, and Cybernetics, Vol. 9, No. 1, 1979, pp. 62-66.
        th1 = graythresh(imgN); %82/255  0.4784
        th2 = graythresh(imgN(imgN>th1)); %151/255   0.6902
        % th1 = 82/255;
        % th2 = 151/255;
        
        cellMsk = imgN>th1;
        nucMsk = imgN>th2;
        filtered = (cellMsk+nucMsk)./2;
        % figure,imshow(filtered)
        Kmedian = medfilt2(filtered);
        figure, imshowpair(filtered,Kmedian,'montage')
        
        
        figure,imshow(nucMsk,[])
        figure,imshow(cellMsk+nucMsk,[])
        figure,imhist(imgN)
        
        
        [Gmag, Gdir] = imgradient(keep,'prewitt');
        
        figure; imshowpair(Gmag, Gdir, 'montage');
        title('Gradient Magnitude, Gmag (left), and Gradient Direction, Gdir (right), using Prewitt method')
        axis off;
        
        BW1 = edge(Gmag,'sobel');
        BW2 = edge(Gmag,'canny');
        figure;
        imshowpair(BW1,BW2,'montage')
        
        BW1 = edge(filtered,'sobel');
        BW2 = edge(filtered,'canny');
        figure;
        imshowpair(BW1,BW2,'montage')
        
        Kaverage = filter2(fspecial('average',3),filtered)/255;
        Kmedian = medfilt2(filtered);
        figure, imshowpair(Kaverage,Kmedian,'montage')
        
        L = watershed(imcomplement(keep));
        rgb = label2rgb(L,'jet',[.5 .5 .5]);
        figure
        imshow(rgb,'InitialMagnification','fit')
        title('Watershed transform of D')
        
        %%
        
        i_index = 14;   %26, 14
        index = i_index;
        keep = img_gray(BBOX(index,2)-disk_size:BBOX(index,2)+BBOX(index,4)-1+disk_size ,BBOX(index,1)-disk_size:BBOX(index,1)+BBOX(index,3)-1+disk_size);
        figure
        imshow(keep)
        figure
        
        [counts,binLocations] = imhist(keep);
        
        subplot(3,2,[1 3 5]);
        imshow(keep)
        
        subplot(3, 2, 2);
        stem(binLocations, counts, 'MarkerSize', 1 );
        % xlim([50 200]);
        
        X = keep(:);
        options = statset('MaxIter', 300); % default value is 100. Sometimes too few to converge
        
        gm = gmdistribution.fit(double(X),3, 'Options', options);
        
        subplot(3, 2, 4);
        plot(binLocations, pdf(gm,binLocations));
        [ymax,imax,ymin,imin] = extrema(pdf(gm,binLocations));
        hold on
        plot(binLocations(imax),ymax,'r*',binLocations(imin),ymin,'g*')
        % xlim([50 200]);
        
        subplot(3, 2, 6);
        for j=1:3
            line(binLocations,gm.PComponents(j)*normpdf(binLocations,gm.mu(j),sqrt(gm.Sigma(j))),'color','r');
        end
        % xlim([50 200]);
        
        figure, plot(binLocations(1:end-1),diff(pdf(gm,binLocations)))
        first_diff = diff(pdf(gm,binLocations));
        
        [ymax,imax,ymin,imin] = extrema(pdf(gm,binLocations));
        hold on
        plot(binLocations(imax),ymax,'r*',binLocations(imin),ymin,'g*')
        
        %%
        
        prepare = keep2.*im2double(keep);
        data = find(prepare~=0);
        [I,J] = ind2sub(size(prepare),data);
        data2 = [J I prepare(data)];
        % figure
        % plot(data2(:,1),data2(:,2),'*')
        
        opts = statset('Display','final');
        [idx,C] = kmeans(data2,2,'Distance','cityblock','Replicates',5,'Options',opts);
        
        figure;
        plot(data2(idx==1,1),data2(idx==1,2),'r.','MarkerSize',12)
        hold on
        plot(data2(idx==2,1),data2(idx==2,2),'b.','MarkerSize',12)
        plot(C(:,1),C(:,2),'kx',...
            'MarkerSize',15,'LineWidth',3)
        legend('Cluster 1','Cluster 2','Centroids',...
            'Location','NW')
        title 'Cluster Assignments and Centroids'
        hold off
        
        
        [row,col] = find(keep2==1);
        % search at the end of major axis
        v1 = [x(2)-x(1);y(2)-y(1)];
        a_point = [x(1);y(1)]+v1;   % in v1 direction
        b_point = [x(1);y(1)]-v1;
        %             a_score = 0;
        %             b_score = 0;
        
        [row_hasvalue, col_hasvalue] = find(keep2==1);
        a_score = sum(((a_point(2)-row_hasvalue).^2+(a_point(1)-col_hasvalue).^2)<(search_radius^2));
        b_score = sum(((b_point(2)-row_hasvalue).^2+(b_point(1)-col_hasvalue).^2)<(search_radius^2));
        envi_score = (sum(((a_point(2)-row_hasvalue).^2+(a_point(1)-col_hasvalue).^2)>(search_radius^2)) + sum(((b_point(2)-row_hasvalue).^2+(b_point(1)-col_hasvalue).^2)<(search_radius^2)) - a_score - b_score ) / 2;
        
        [columnsInImage rowsInImage] = meshgrid(1:size(keep2,2), 1:size(keep2,1));
        circlePixels = (rowsInImage - a_point(2)).^2 + (columnsInImage - a_point(1)).^2 <= search_radius.^2;
        figure
        imshow(keep2.*~circlePixels)
        prepare2 = keep2.*~circlePixels;
        
        figure
        imshow(~circlePixels)
        
        data = find(prepare2~=0);
        [I,J] = ind2sub(size(prepare2),data);
        data2 = [J I prepare2(data)];
        surf(data2)
        figure
        plot(data2(:,1),data2(:,2),'*')
        
        opts = statset('Display','final');
        [idx,C] = kmeans(data2,2,'Distance','cityblock','Replicates',10,'Options',opts);
        
        % check variance
        for C_count = 1 : size(C,1)
            circlePixels = (rowsInImage - C(C_count,2)).^2 + (columnsInImage - C(C_count,1)).^2 <= search_radius.^2;
            V = var(data2(idx==1))
            var(data2(idx==2))
        end
        
        
        
        figure;
        plot(data2(idx==1,1),data2(idx==1,2),'r.','MarkerSize',12)
        hold on
        plot(data2(idx==2,1),data2(idx==2,2),'b.','MarkerSize',12)
        plot(C(:,1),C(:,2),'kx',...
            'MarkerSize',15,'LineWidth',3)
        legend('Cluster 1','Cluster 2','Centroids',...
            'Location','NW')
        title 'Cluster Assignments and Centroids'
        hold off
        
        
        
        %% calculate direction
        
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
        direction_flag = 1;
        %             if direction_flag == 2  % if noone is sure
        %                 direction_flag = 1;
        %             end
    elseif ((count(1)~=0)||(count(2)~=0)) && (count(2) > count(1))
        direction_flag = 0;
        %             if direction_flag == 2  % if noone is sure
        %                 direction_flag = 0;
        %             end
    end
    
    
    if direction_flag == 1  % a wins so direction has to be toward b
        direction_vector = -v1;
    elseif direction_flag == 0
        direction_vector = v1;
    else
        direction_vector = 0*v1;    % zero vector
    end
    
    keep_direction = [keep_direction direction_vector];
    
    
end

zero_element = find(XY_update_to_keep_direction==0);
a = [1:size(XY_update_to_keep_direction,1)];
b = a(~ismember(a,XY_update_to_keep_direction));
if ~isempty(zero_element)
    for i_count = 1:size(zero_element,1)
        XY_update_to_keep_direction(zero_element(i_count,1),1) = b(i_count);
    end
    
end
