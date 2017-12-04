%%
function [nearNum, nearAREA, nearCENTROID, nearBBOX, nearMAJORAXIS, nearMINORAXIS, nearORIENTATION, nearECCENTRICITY] = ...
    blobSeparationByTemplateMatch(blob_img_trimmed, expect_num, tmplImage, tmplSepTh, overlapTh, areaSize, hFindMax, hConv2D)
    %% 
    % Create a System object to perform 2-D inverse FFT after performing
    % correlation (equivalent to multiplication) in the frequency domain. 
    hFFT2D1 = vision.FFT;
    hFFT2D2 = vision.FFT;

    hIFFFT2D = vision.IFFT;

    %%
    % Here you implement the following sequence of operations.
%Img_org = blob_img_trimmed;
    Img = 255 - blob_img_trimmed; % invert image
    Img = single(Img);
    %Img = step(hGaussPymd2, Img);
    [ri, ci]= size(Img);

    % make square to smoothing empty area size for each rotation
    [rt, ct]= size(tmplImage);
    w = max(rt,ct);
    tg_square_image = single(zeros(w,w));
    if w==rt
        tg_square_image(:,int32((w-ct)/2):int32((w-ct)/2+ct-1)) = tmplImage;
    else
        tg_square_image(int32((w-rt)/2):int32((w-rt)/2+rt-1),:) = tmplImage;
    end
    [rt, ct]= size(tg_square_image);

    target_images = {};
    target_energies = [];
    target_ffts = {};
    for i=1:16
        img = imrotate(tg_square_image, (i-1)*22.5, 'nearest','crop');
    %    img(img==0) = 255;
    %    img(img==0) = 1; % this is mask
        target_images = [target_images, img];
        target_energy = sqrt(sum(img(:).^2));
        target_energies = [target_energies, target_energy];

        r_mod = 2^nextpow2(rt + ri);
        c_mod = 2^nextpow2(ct + ci);
        target_image_p = [img zeros(rt, c_mod-ct)];
        target_image_p = [target_image_p; zeros(r_mod-rt, c_mod)];
    %    target_image_p(target_image_p==0) = 255;

        % Compute the 2-D FFT of the target image
        target_fft = step(hFFT2D1, target_image_p);
        target_ffts = [target_ffts, target_fft];
%    imshow(uint8(target_images{i}));
    end

    % set a System object to calculate the local maximum value for the normalized cross correlation.
    release(hFindMax); 
    set(hFindMax, 'NeighborhoodSize', floor([rt, ct]/2)*2 - 1);
    set(hFindMax, 'MaximumNumLocalMaxima', expect_num);

    Im_del = zeros(ri, ci, 'single');
    inloop_target = [];

    for i=1:16
        target_size = repmat([rt, ct], [expect_num, 1]);
        r_mod = 2^nextpow2(rt + ri);
        c_mod = 2^nextpow2(ct + ci);
        Im_p = zeros(r_mod, c_mod, 'single'); % Used for zero padding
    %    Im_p(:,:) = 255;
        C_ones = ones(rt, ct, 'single');      % Used to calculate mean using conv

        % Frequency domain convolution.
        Img = Img - Im_del;
        Img(Img < 0) = 0;
%figure; imshow(uint8(Img));
        Im_p(1:ri, 1:ci) = Img;    % Zero-pad
        img_fft = step(hFFT2D2, Im_p);
        corr_freq = img_fft .* target_ffts{i};
        corrOutput_f = step(hIFFFT2D, corr_freq);
        corrOutput_f = corrOutput_f(rt:ri, ct:ci);

        % Calculate image energies and block run tiles that are size of
        % target template.
        IUT_energy = (Img).^2;
        IUT = step(hConv2D, IUT_energy, C_ones);
        IUT = sqrt(IUT);

        % Calculate normalized cross correlation.
        norm_Corr_f = (corrOutput_f) ./ (IUT * target_energies(i));
        norm_Corr_f(isinf(norm_Corr_f)) = NaN;
        norm_Corr_f(isnan(norm_Corr_f)) = 0;
        xyLocation = step(hFindMax, norm_Corr_f);
%figure; imshow(norm_Corr_f);

        % Calculate linear indices.
        linear_index = sub2ind([ri-rt, ci-ct]+1, xyLocation(:,2), xyLocation(:,1));

        norm_Corr_f_linear = norm_Corr_f(:);
        norm_Corr_value = norm_Corr_f_linear(linear_index);
        detect = (norm_Corr_value >= tmplSepTh);
        target_roi = zeros(length(detect), 4);
        ul_corner = xyLocation(detect, :);
        target_roi(detect, :) = [ul_corner, fliplr(target_size(detect, :))];
        if size(ul_corner,1) > 0
            res = [target_roi(detect,:), norm_Corr_value(detect)];
            res(:,6) = i;
            inloop_target = [inloop_target; res];
        end
% Draw bounding box.   
%Imf = insertShape(Imf, 'Rectangle', target_roi, 'Color', 'green');
%figure(detectFig); imshow(uint8(Imf));
    end
%figure; imshow(uint8(Img));

    [Y,I] = sort(inloop_target(:,5),'descend');
    inloop_target = inloop_target(I,:);

    % removing overlap point
    delIdx = [];
    Im_del = zeros(ri, ci, 'single');
    highestColer = max(max(target_images{1}));
    for k=1:size(inloop_target,1)
        y = inloop_target(k,2);
        x = inloop_target(k,1);
        tgImg = target_images{inloop_target(k,6)};
        tgImg = tgImg + Im_del(y:(y+rt-1), x:(x+ct-1));
        overlapIdx = find(tgImg > highestColer);
        overlapRate = length(overlapIdx)/(rt*ct);
        if overlapRate > overlapTh
            delIdx = [delIdx, k];
        else
            Im_del(y:(y+rt-1), x:(x+ct-1)) = tgImg;
        end
        if (k-length(delIdx)) >= expect_num
            break;
        end
    end
%figure; imshow(uint8(Im_del));

    inloop_target(delIdx,:) = [];
    if size(inloop_target,1) >= expect_num
        result_target = inloop_target(1:expect_num,:);
    else
        result_target = inloop_target;
    end

    % set result
    nearNum = 0;
    nearAREA = [];
    nearCENTROID = [];
    nearBBOX = [];
    nearMAJORAXIS = [];
    nearMINORAXIS = [];
    nearORIENTATION = [];
    nearECCENTRICITY = [];

    if size(result_target,1) > 0
        [Y,I] = sort(result_target(:,5),'descend');
        result_target = result_target(I,:);
        if expect_num > size(result_target,1)
            nearNum = size(result_target,1);
        else
            nearNum = expect_num;
        end
        result_roi = result_target(1:nearNum,1:4);

%Imf = insertShape(Img_org, 'Rectangle', result_roi, 'Color', 'green');
%figure; imshow(uint8(Imf));

        nearAREA = repmat(areaSize/nearNum, nearNum, 1);
        nearCENTROID = [result_roi(:,1)+result_roi(:,3)./2, result_roi(:,2)+result_roi(:,4)./2];
        nearBBOX = int32(result_roi);
        nearMAJORAXIS = repmat(w, nearNum, 1);
        nearMINORAXIS = repmat(w/2, nearNum, 1);
        nearORIENTATION = (result_target(1:nearNum, 6) - 1) .* (22.5 / 180 * pi) - (pi / 2);
        nearECCENTRICITY = repmat(0.93, nearNum, 1);
    end
end
