%% create new ROI images
function [count, figureWindow] = createRoiImages(videoPath, shuttleVideo, frameImage, grayImage, roiNum)
    for i=1:16 % TODO: should not be limited
        % create new roi window if it does not exist
        if ~exist('figureWindow','var') || isempty(figureWindow) || ~ishandle(figureWindow)
            figureWindow = figure('name','selecting roi','NumberTitle','off');
        end
        count = i;

        % change title message
        set(figureWindow, 'name', ['select roi for ', shuttleVideo.name, ' (' num2str(i) ')']);

        if i==1 idx=''; else idx=num2str(i); end
        confRoiName = [videoPath shuttleVideo.name '_tpro/roi'];
        roiFileName = [confRoiName idx '.png'];
        roiMatName = [confRoiName idx '.mat'];
        if exist(roiFileName, 'file')
            roiImage = imread(roiFileName);
            roiImage = im2double(roiImage);
            img = double(grayImage).*(imcomplement(roiImage*0.5));
            img = uint8(img);
        else
            roiImage = [];
            img = frameImage;
        end
        % show previous multi roi images
        if i>1 && ~isempty(multiRoiImage)
            % to color
            if ismatrix(img)
                redImage = uint8(double(img).*(imcomplement(multiRoiImage*0.1)));
                img = cat(3,img,redImage,img);
            else
                redImage = img(:,:,2);
                redImage = uint8(double(redImage).*(imcomplement(multiRoiImage*0.1)));
                img(:,:,2) = redImage;
            end
        end

        % show polygon selection window
        [newRoiImage, roiX, roiY] = roipoly(img);

        % if canceled, do not show and save roi file
        if ~isempty(newRoiImage)
            img = double(grayImage).*imcomplement(newRoiImage*0.5);
            img = uint8(img);
            imshow(img)

            % write roi file
            disp(['imwrite : ' roiFileName]);
            imwrite(newRoiImage, roiFileName);
            save(roiMatName, 'roiX','roiY');
        elseif ~isempty(roiImage)
            newRoiImage = roiImage;
        else
            % no new roi image.
            return;
        end
        if i==1
            multiRoiImage = im2double(newRoiImage);
        else
            multiRoiImage = multiRoiImage | im2double(newRoiImage);
        end

        % confirm to set next ROI
        roiFileName = [confRoiName num2str(i+1) '.png'];
        if roiNum <= i || ~exist(roiFileName, 'file')
            selection = questdlg('Do you create one more ROI for same movie?',...
                                 'Confirmation',...
                                 'Yes','No','No');
            switch selection
            case 'Yes'
                % nothing to do; show next dialog
            case 'No'
                break;
            otherwise
                break;
            end
        end
    end
end
