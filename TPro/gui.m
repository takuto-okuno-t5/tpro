% TPro1.4 2017-04-22
% add total distance output
% add create movie button
% standard file name is now '%05d'

function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 17-Mar-2017 07:57:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_OpeningFcn, ...
    'gui_OutputFcn',  @gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% set window title
versionNumber = '1.4';
set(gcf, 'name', ['TPro version ', versionNumber]);

% set initialized message
set(handles.edit1, 'String','Welcome! Please click the buttons on the left to run')

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% prepare--- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.text9,'String','Running','BackgroundColor','red');

addpath(genpath('input'));
addpath(genpath('multi'));
addpath(genpath('../input_share'));

[fileNames, pathName, filterIndex] = uigetfile( {  ...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', ...
    'MultiSelect', 'on', '../input_share');

if ~filterIndex
    set(handles.text9,'String', 'Canceled', 'BackgroundColor', 'red');
    return;
end

% show starting message
set(handles.edit1, 'String', 'creating configuration file (xlsx) ...');
tic
    
outputFileName = './input/input_video_control.xlsx';
A = {'Enable', 'Name', '', 'Start', 'End', 'All', 'fps', 'TH', '', 'ROI', 'rej_dist', '', 'G_Strength','G_Radius', 'AreaPixel', 'Step', 'BlobSeparate'};
if ischar(fileNames)
    fileCount = 1;
else
    fileCount = size(fileNames,2);
end

% process all selected files
for i = 1:fileCount
    if fileCount > 1
        fileName = fileNames{i};
    else
        fileName = fileNames;
    end
    shuttleVideo = VideoReader(fileName);
    name = shuttleVideo.Name;
    frameNum = shuttleVideo.NumberOfFrames;
    frameRate = shuttleVideo.FrameRate;

    B = {'1', name, '', '1', frameNum, frameNum, frameRate, '0.6', '0', '1', '200', '0', '12', '4', '50', '1', '0.5'};
    A = vertcat(A,B);
end

% remove file first and output excel file
delete(outputFileName);
status = xlswrite(outputFileName,A,1,'A1');
time = toc;

% show result message
if status 
    set(handles.edit1, 'String',strcat('creating configuration file (xlsx) ... done!     t =',num2str(time),'s'));
    set(handles.text9,'String','Ready','BackgroundColor','green');
else
    set(handles.edit1, 'String',strcat('can not output configuration file (xlsx)'));
    set(handles.text9,'String','Failed','BackgroundColor','red');
end

% bg--- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath(genpath('function'));
addpath(genpath('input'));
addpath(genpath('parameter'));
addpath(genpath('multi'));
addpath(genpath('detect_output'));
addpath(genpath('../input_share'));

file_list2 =  dir('../input_share/*avi');
if isempty(file_list2)
    file_list2 = dir('../input_share/*mov');
end

if ~isempty(file_list2)
    %     file_list = [];
    file_list3 = dir('./input/input_video_control.xlsx');
    if ~isempty(file_list3)
        [num,txt,raw] = xlsread('./input/input_video_control.xlsx');
    else
        disp('please put input xlsx files into the folder');
        return;
    end
else
    disp('please put input video files into the folder');
    return;
end

tic % start timer

% how many images to consider
str = get(handles.edit3, 'String');
calcFramesNumber = str2num(str);

% show start text
set(handles.edit1, 'String','detecting background ...')
set(handles.text9, 'String','Running','BackgroundColor','red');

% background detection for active movie
for data_th = 1:(size(raw,1)-1)
    % check active flag
    if ~num(data_th,1)
        continue;
    end
    
    shuttleVideo = VideoReader(strcat('../input_share/',char(txt(data_th+1,2))));

    % show detecting message
    set(handles.edit1, 'String', ['detecting background for ', shuttleVideo.name])

    % make output folder
    pathName = strcat('./bg_output/',shuttleVideo.name);
    backgroundFileName = strcat(pathName,'/',shuttleVideo.name,'bg.png');
    if ~exist(pathName, 'dir')
        mkdir(pathName);
    end

    range = num(data_th, 6);
    r = randperm(range);
    r = r(1:calcFramesNumber);

    % initialize output matrix 
    frameImage = read(shuttleVideo,1);
    [m,n,l] = size(frameImage);
    grayImages = uint8(zeros(m,n,calcFramesNumber));

    % find appropriate background pixels
    for i = 1 : calcFramesNumber
        set(handles.text9, 'String',[num2str(100*i/calcFramesNumber) ' %']);
        pause(0.001);
        frameImage = read(shuttleVideo,r(i));
        grayImage = rgb2gray(frameImage);
        grayImages(:,:,i) = grayImage;
    end
    bgImage = mode(grayImages,3);
     
    % sometimes fly stays same position. and mode does not work well.
    % check its mean color and difference each pixels.
    bgMeanImage = mean(grayImages,3);
    maxImage = max(grayImages,[],3); % get most blight image

    diffImage = abs(double(bgImage) - bgMeanImage);
    diffImage2 = maxImage - bgImage;
    for x = 1 : n
        for y = 1 : m
            if diffImage(y,x) > 50 || diffImage2(y,x) > 100
                bgImage(y,x) = maxImage(y,x);
            end
        end
    end
    
    % create new background window if it does not exist
    if ~exist('figureWindow','var') || isempty(figureWindow) || ~ishandle(figureWindow)
        figureWindow = figure('name','detecting ','NumberTitle','off');
    end

    % show background image
    figure(figureWindow);
    clf
    imshow(bgImage);
    set(figureWindow, 'name', ['background for ', shuttleVideo.name]);

    % output png file
    imwrite(bgImage, backgroundFileName);
    disp(num2str(data_th));
    clear img
end

% close background image window
if exist('figureWindow','var') && ~isempty(figureWindow) && ishandle(figureWindow)
    pause(2);
    close(figureWindow);
end

% show end text
time = toc;
set(handles.edit1, 'String',strcat('detecting background ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');


% check_threshold--- Executes on button press in pushbutton3
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.edit1, 'String','check_threshold.m done!')

addpath(genpath('function'));
addpath(genpath('input'));
addpath(genpath('parameter'));
addpath(genpath('multi'));
addpath(genpath('detect_output'));
addpath(genpath('../input_share'));

file_list2 =  dir('../input_share/*avi');
if isempty(file_list2)
    file_list2 = dir('../input_share/*mov');
end

if ~isempty(file_list2)
    file_list3 = dir('./input/input_video_control.xlsx');
    if ~isempty(file_list3)
        [num,txt,raw] = xlsread('./input/input_video_control.xlsx');
    else
        disp('please put input xlsx files into the folder');
        return;
    end
else
    disp('please put input video files into the folder');
    return;
end

% show start text
set(handles.edit1, 'String','checking detection threashold ...')
set(handles.text9, 'String','Running','BackgroundColor','red');

% loop for every movies
for i = 1 : size(num)
    % set env value and run script
    setenv('TPRO_RUNOPTM', '1');
    setenv('TPRO_ROWNUM', num2str(i));
    run('detectoptimizer.m');

    % wait for closing detectoptimizer
    while true
        if ~strcmp(getenv('TPRO_RUNOPTM'),'1')
            break; % process next movie
        end
        pause(0.5);
    end
end

set(handles.edit1, 'String',strcat('checking detection threashold ... done!'))
set(handles.text9, 'String','Ready','BackgroundColor','green');


% detection--- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath(genpath('function'));
addpath(genpath('input'));
addpath(genpath('parameter'));
addpath(genpath('multi'));
addpath(genpath('detect_output'));
addpath(genpath('../input_share'));

file_list2 =  dir('../input_share/*avi');
if isempty(file_list2)
    file_list2 = dir('../input_share/*mov');
end

if ~isempty(file_list2)
    %     file_list = [];
    file_list3 = dir('./input/input_video_control.xlsx');
    if ~isempty(file_list3)
        [num,txt,raw] = xlsread('./input/input_video_control.xlsx');
    else
        disp('please put input xlsx files into the folder');
        return;
    end
else
    disp('please put input video files into the folder');
    return;
end

% show start text
set(handles.edit1, 'String','detection ...')
set(handles.text9, 'String','Running','BackgroundColor','red');

%% parameters setting
tic % start timer

% near point average
npa_radius = 12; % set 0 to skip

% for checking in check_blob_threshold.m
frame_num = 10;

% reject distance
reject_dist = 200;
% reject_dist = 200;

% for strike track
strike_track_threshold = 6;

% assignment for no assignment
assign_for_noassign = 1;

% output figure enable
detect_fig_enable = get(handles.radiobutton1,'Value'); % in detection.m
figure_enable = 1;  % in tracker_savefig_op.m
line_length = 19;


% velocity threshold enable
velocity_thres_enable = 0;

% velocity threshold
velocity_thres = 50;

% velocity graph enable (0)
velocity_graph_enable = 0;

% blob analysis enable (detection) (1)
ba_enable = 1;  % inside extrema

% minimum distance threshold
min_dist_threshold = 50;

% output number eneable
num_text_enable = 1;

% blob center detection (1)
blob_center_enable = 1;

% extrema detection (0)
extrema_enable = 0;

% the closest neighbour approach
cna_enable = 1;

% check direction
check_direction_enable = 1;

% Kalman only
kalman_only_enable = 0;

% shift the intensity
intensity_shift = 0;

% choose animal type
animal_type = get(handles.popupmenu1,'Value');

%%
H = vision.BlobAnalysis;
H.MaximumCount = 100;
H.MajorAxisLengthOutputPort = 1;
H.MinorAxisLengthOutputPort = 1;
H.OrientationOutputPort = 1;
H.EccentricityOutputPort = 1;

keep_i = [];
keep_count = [];

% added on 2016-07-28
for data_th = 1:(size(raw,1)-1)
    % check active flag
    if ~num(data_th,1)
        continue;
    end
    
    blob_threshold = num(data_th, 8);
    start_frame = num(data_th, 4);
    end_frame = num(data_th, 5);
    frame_steps = num(data_th, 16);
    h = num(data_th, 13);
    sigma = num(data_th, 14);
    area_pixel = num(data_th, 15);
    blobSeparateRate = num(data_th, 17);

    shuttleVideo = VideoReader(strcat('../input_share/',char(txt(data_th+1,2))));

    % ROI
    videoName = shuttleVideo.name;
    roiFileName = strcat('./roi/',videoName,'/',videoName,'_roi.png');
    if exist(roiFileName, 'file')
        img = imread(roiFileName);
        roi_mask = im2double(img);
    else
        roi_mask = [];
    end

    bgImageFile = strcat('./bg_output/',videoName,'/',videoName,'bg.png');
    if exist(bgImageFile, 'file')
        bgImage = imread(bgImageFile);
        if size(size(bgImage),2) == 2 % one plane background
            bgImage(:,:,2) = bgImage(:,:,1);
            bgImage(:,:,3) = bgImage(:,:,1);
        end
        bgImage = rgb2gray(bgImage);
        bg_img_double = double(bgImage);
        bg_img_mean = mean(mean(bgImage));
    else
        bg_img_double = [];
        bg_img_mean = [];
    end

    % make output folder
    filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
    mkdir(strcat('./detect_output/',shuttleVideo.name,'_',filename));

    X = cell(1,length(end_frame-start_frame+1));
    Y = cell(1,length(end_frame-start_frame+1));
    detection_num = nan(2,end_frame-start_frame+1);
    blobAvgSize = 0;

%load(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'.mat'));
%load(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'keep_count.mat'));
%X_update2 = X;
%Y_update2 = Y;
%if size(X,2) <= 1
    i = 1;
    for i_count = start_frame : frame_steps : end_frame
        img_real = read(shuttleVideo, i_count);
        grayImg = rgb2gray(img_real);
        if ~isempty(bg_img_mean)
            grayImg = grayImg + (bg_img_mean - mean(mean(grayImg)));
            grayImageDouble = double(grayImg);
            img = bg_img_double - grayImageDouble;
            img = uint8(img);
            img = imcomplement(img);
        else
            img = grayImg;
        end

        %do the blob filter
        blob_img = PD_blobfilter(img, h, sigma);

        % ROI
        if ~isempty(roi_mask)
            blob_img = blob_img .* roi_mask;
        end

        % imshow(blob_img)
%                blob_img_1st = blob_img;

        %                 if animal_type == 2     % rodent set blob_threshold_peak to be the maximum of blob_img_1st
        %                     blob_th_test = blob_threshold;
        %                     blob_img_test = blob_img;
        %                     for th_i = 1:10
        %                         blob_img_test2 = blob_img_test;
        %                         idx_test = find(blob_img_test < blob_th_test);
        %                         blob_img_test2(idx_test) = nan;
        %                         if sum(sum(~isnan(blob_img_test2))) > 100
        %                             break;
        %                         else
        %                             blob_th_test = blob_th_test - 0.05;
        %                         end
        %                     end
        %                     blob_threshold = blob_th_test;
        %                 end
%                idx = find(blob_img < blob_threshold);
%                blob_img(idx) = nan ;

        %                 %%% find the number of detection
        %                 blob_img_logical = blob_img_1st;
        %                 blob_img_logical(~idx) = 1;
        %                 blob_img_logical(idx) = 0;
        %                 blob_img_logical = logical(blob_img_logical);
        %                 abc = bwareaopen(blob_img_logical, 50);
        %                 [AREA,CENTROID,BBOX] = step(H,abc);
        %                 dnum = dnum + size(AREA,1)

        %                     %% for output cut_Video_14.avi blob specific and normal thresholding
        %                     figure(1)
        %                     imshow(blob_img(228:255,329:369))
        %                     set(gca,'Units','Normalized','position',[0.1,0.1,0.8,0.8]);
        %
        %                     figure(2)
        %                     img2 = uint8(img);
        %                     idx_img2 = find(img2 > 160);
        %                     idx2_img2 = find(img2 <= 160);
        %                     img2(idx_img2) = nan ;
        %                     img2(idx2_img2) = 255 ;
        %                     imshow(img2(228:255,329:369))
        %                     set(gca,'Units','Normalized','position',[0.1,0.1,0.8,0.8]);
        % %                     f=getframe;
        % %                     imwrite(f.cdata,strcat('./for_resource/','blob_after_thresholding','.png'));
        %                     keyboard

        %%% for output cut_Video_14.aviblob_after_thresholding
        %                     imshow(blob_img)
        %                     f=getframe;
        %                     imwrite(f.cdata,strcat('./for_resource/','blob_after_thresholding','.png'));
        %                     keyboard

        %%% for output cut_Video_14.aviblob_splitting
        %                     imshow(blob_img(60:130,320:390))
        %                     f=getframe;
        %                     imwrite(f.cdata,strcat('./for_resource/','blob_splitting','.png'));
        %                     keyboard

        %                 %% for output 3d splitting
        %
        %                                 blob_temp = blob_img(60:130,320:390);
        %                                 blob_temp(1:end,:) = blob_img(130:-1:60,320:390);
        %                                 surf(blob_temp);
        %                                 colormap(parula);
        %                                 axis([20 60 20 50 0.8 2.4])
        %                                 view(-15,29)
        %                                 xlabel('x','FontSize',18)
        %                                 ylabel('y','FontSize',18)
        %                                 zlabel('z','FontSize',18)
        %                                 set(gca,'fontsize',18)
        %                                 f=getframe;
        %                                 imwrite(f.cdata,strcat('./for_resource/','3dblob_splitting','.png'));
        %                                 keyboard

        img = imbinarize(blob_img, blob_threshold);
        blob_img_logical2 = bwareaopen(img, area_pixel);   % delete blob that has area less than 50

        % get blobs from step function
        if blob_center_enable
            [ X_update2{i}, Y_update2{i}, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( blob_img, blob_img_logical2, H, blob_threshold, blobSeparateRate, i, blobAvgSize);
        end

        %%% for output cut_Video_14.aviblob_splitting_after
        %                     imshow(blob_img_logical2(60:130,320:390))
        %                     f=getframe;
        %                     imwrite(f.cdata,strcat('./for_resource/','blob_splitting_after','.png'));
        %                     keyboard

        %                 %% for output 3d splitting
        %                                 blob_img_temp = blob_img.*blob_img_logical2;
        %                                 blob_temp = blob_img_temp(60:130,320:390);
        %                                 blob_temp(1:end,:) = blob_img_temp(130:-1:60,320:390);
        %                                 surf(blob_temp);
        %                                 colormap(parula);
        %                                 axis([20 60 20 50 0.8 2.4])
        %                                 view(-15,29)
        %                                 xlabel('x','FontSize',18)
        %                                 ylabel('y','FontSize',18)
        %                                 zlabel('z','FontSize',18)
        %                                 set(gca,'fontsize',18)
        %                                 f=getframe;
        %                                 imwrite(f.cdata,strcat('./for_resource/','3dblob_splitting_after','.png'));
        %                                 keyboard

        if extrema_enable

            [zmax,imax,zmin,imin] = extrema2(blob_img);

            [X{i},Y{i}] = ind2sub(size(blob_img),imax);

            % near point average
            [ X_update{i}, Y_update{i} ] = PD_npa(X{i}, Y{i}, npa_radius);

            % blob analysis
            if ba_enable
                % blob_img_logical is logical version of blob image after thresholding
                blob_img_logical = blob_img_1st;
                blob_img_logical(~idx) = 1;
                blob_img_logical(idx) = 0;
                blob_img_logical = logical(blob_img_logical);
                [ X_update2{i}, Y_update2{i} ] = PD_blob_analysis( H, blob_img_logical, X_update{i}, Y_update{i} );
                blob_img_logical2 = blob_img_logical;   % just copy blob_img_logical
            end


        end

        %% working 20170315
        %                 [ keep_direction, XY_update_to_keep_direction, keep_ecc] = PD_wing( H, img, img_gray, blob_img_logical2, X_update2{i}, Y_update2{i} );



        %%
        [ keep_direction, keep_angle ] = PD_direction( grayImg, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient);
        %[ keep_direction, keep_angle ] = PD_direction2( grayImg, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient);
        % ith of the XY_update is the XY_update_to_keep_direction th of the keep direction
        % sort based on X_update2 and Y_update2
        keep_direction_sorted{i} = keep_direction;
        keep_ecc_sorted{i} = blobEcc';
        keep_angle_sorted{i} = keep_angle;
        keep_areas{i} = blobAreas';

        %     clf
        %     imshow(img_real);
        %     hold on;
        %     plot(Y_update2{i}(:),X_update2{i}(:),'or'); % the updated actual tracking
        %     title('updated2 detection')
        %     quiver(Y_update2{i}(:),X_update2{i}(:),keep_direction_sorted{i}(1,:)',keep_direction_sorted{i}(2,:)', 'r', 'MaxHeadSize',1, 'LineWidth',1)  %arrow
        %     % save figure
        %     f=getframe;
        %     imwrite(f.cdata,strcat('./output/direct_img',file_list(i).name));

        %     disp(strcat(num2str(100*i/length(file_list)),'%','   detection : ', num2str(size(imax,1))));

        if extrema_enable
            if size(imax,1) == size(X_update{i},1)
                disp(strcat(num2str(data_th), 'th     >', num2str(100*(i_count-start_frame)/(end_frame-start_frame+1)), '%', '     detect : ', num2str(size(imax,1))));
            elseif ba_enable
                disp(strcat(num2str(data_th), 'th     >', num2str(100*(i_count-start_frame)/(end_frame-start_frame+1)), '%', '     detect : ', num2str(size(imax,1)), '   detect_npa : ', num2str(size(X_update{i},1)), '   detect_ba : ', num2str(size(X_update2{i},1))));
            else
                disp(strcat(num2str(data_th), 'th     >', num2str(100*(i_count-start_frame)/(end_frame-start_frame+1)), '%', '     detect : ', num2str(size(imax,1)), '   detect_npa : ', num2str(size(X_update{i},1))));
            end
            detection_num(:,i) = [size(imax,1); size(X_update{i},1)];
        end

        if blob_center_enable
            disp(strcat(num2str(data_th), 'th     >', num2str(100*(i_count-start_frame)/(end_frame-start_frame+1)), '%', ' i:',num2str(i),' frame:',num2str(i_count), '   detect_blob_center : ', num2str(size(X_update2{i},1))));
        end

        % graph
        if detect_fig_enable
            % create new roi window if it does not exist
            if ~exist('figureWindow','var') || isempty(figureWindow) || ~ishandle(figureWindow)
                figureWindow = figure('name','selecting roi','NumberTitle','off');
            end

            % change title message
            set(figureWindow, 'name', ['detection for ', shuttleVideo.name]);
            figure(figureWindow);
            clf

            if intensity_shift ~= 0
                imshow(uint8(img_gray_double));
            else
                imshow(img_real);
            end
            hold on;

            if size(X_update2{i},1) ~= 0
                plot(Y_update2{i}(:),X_update2{i}(:),'or'); % the updated actual tracking
                quiver(Y_update2{i}(:),X_update2{i}(:),keep_direction_sorted{i}(1,:)',keep_direction_sorted{i}(2,:)',  0.3, 'r', 'MaxHeadSize', 0.2, 'LineWidth', 0.2)  %arrow
            end
            % save figure
            f=getframe;
            filename2 = [sprintf('%05d',i_count) '.png'];
            imwrite(f.cdata,strcat('./detect_output/',shuttleVideo.name,'_',filename,'/',filename2));
            pause(0.001)
        end
        % graph for detection analysis
        keep_i = [keep_i i];
        keep_count = [keep_count size(X_update2{i},1)];
        set(handles.text9, 'String',[num2str(int64(100*(i_count-start_frame)/(end_frame-start_frame+1))) ' %']);
        pause(0.001);
        i = i + 1;
    end
%end
    X = X_update2;
    Y = Y_update2;

    % before saving, check standard deviation of fly count
    sd = std(keep_count);
    mcount = mean(keep_count);
    if 0 < sd && sd < 0.1
        % fly count should be same every frame.
        % let's fix false positive or false negative
        errorCases = find(abs(keep_count - mcount) > 0.9);
        for i = 1 : size(errorCases, 2)
            idx = errorCases(i);
            errorFrameX = X{idx};
            errorFrameY = Y{idx};
            errorFrameAreas = keep_areas{idx};
            
            % error case 1 : [false positive] sometimes wing is separated as a individual blob
            if keep_count(idx) > mcount
                % find nearest points
                min1 = 1; min2 = 2;
                minDist = 4096; % initial dummy
                flyCount = size(errorFrameX, 1);
                for j = 1 : flyCount - 1
                    for k = j+1 : flyCount
                        dist = abs(errorFrameX(j) - errorFrameX(k)) + abs(errorFrameY(j) - errorFrameY(k));
                        if minDist > dist
                            min1 = j; min2 = k;
                            minDist = dist;
                        end
                    end
                end
                % remove smaller one!
                if errorFrameAreas(min1) > errorFrameAreas(min2)
                    X{idx}(min2) = [];
                    Y{idx}(min2) = [];
                else
                    X{idx}(min1) = [];
                    Y{idx}(min1) = [];
                end
                keep_count(idx) = flyCount - 1;
            end
        end
    end
    
    % save it!
    filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
    save(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'.mat'),  'X','Y', 'keep_direction_sorted', 'keep_ecc_sorted', 'keep_angle_sorted', 'keep_areas');
    save(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'keep_count.mat'), 'keep_count');

    set(handles.text9, 'String','100 %'); % done!
end

% show end text
time = toc;
set(handles.edit1, 'String',strcat('detection ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');


% tracker--- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)  % tracker
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath(genpath('function'));
addpath(genpath('input'));
addpath(genpath('parameter'));
addpath(genpath('output'));
addpath(genpath('multi'));
addpath(genpath('../input_share'));

file_list2 =  dir('../input_share/*avi');
if isempty(file_list2)
    file_list2 = dir('../input_share/*mov');
end

if ~isempty(file_list2)
    %     file_list = [];
    file_list3 = dir('./input/input_video_control.xlsx');
    if ~isempty(file_list3)
        [num,txt,raw] = xlsread('./input/input_video_control.xlsx');
        raw_a = raw(1,:);
    else
        disp('please put input xlsx files into the folder');
        return;
    end
else
    disp('please put input video files into the folder');
    return;
end

% show start text
set(handles.edit1, 'String','tracking ...')
set(handles.text9, 'String','Running','BackgroundColor','red');

%% parameters setting
tic % start timer

% blobfilter parameters
h = 30;
sigma = 6;
blob_threshold = 0.8;

% near point average
npa_radius = 12; % set 0 to skip

% for checking in check_blob_threshold.m
frame_num = 10;

% reject distance
% reject_dist = 40;
% reject_dist = 200;

% for strike track
strike_track_threshold = 6;

% assignment for no assignment
assign_for_noassign = 1;

% output figure enable
detect_fig_enable = 0; % in detection.m
figure_enable = get(handles.radiobutton2,'Value');  % in tracker_savefig_op.m
visible_enable = get(handles.radiobutton3,'Value');
line_length = 19;


% velocity threshold enable
velocity_thres_enable = 0;

% velocity threshold
velocity_thres = 50;

% velocity graph enable (0)
velocity_graph_enable = 0;

% blob analysis enable (detection) (1)
ba_enable = 1;  % inside extrema

% minimum distance threshold
min_dist_threshold = 50;

% output number eneable
num_text_enable = 1;

% blob center detection (1)
blob_center_enable = 1;

% extrema detection (0)
extrema_enable = 0;

% background subtraction
bg_subtract_enable = 1;

% the closest neighbour approach
cna_enable = 1;

% check direction
check_direction_enable = 1;

% Kalman only
kalman_only_enable = 0;

% shift the intensity
intensity_shift = -20;

% choose animal type
animal_type = get(handles.popupmenu1,'Value');

% kalman filter multiple object tracking

if figure_enable
    if visible_enable
        figure('name','tracker_savefig_op.m','NumberTitle','off')
    else
        figure('name','tracker_savefig_op.m','NumberTitle','off','visible','off')
    end

end

%% Kalman

dt = 1;  % sampling rate
frame_start = 1; % starting frame
MAX_FLIES = 400; % maxmum number of flies

u = 0; % no acceleration
noise_process = 1; % process noise
noise_meas_x = .1;  % measurement noise in x direction
noise_meas_y = .1;  % measurement noise in y direction
Ez = [noise_meas_x 0; 0 noise_meas_y];
Ex = [dt^4/4 0 dt^3/2 0; ...
    0 dt^4/4 0 dt^3/2; ...
    dt^3/2 0 dt^2 0; ...
    0 dt^3/2 0 dt^2].*noise_process^2; % Ex convert the process noise (stdv) into covariance matrix

P = Ex; % estimate of initial position variance (covariance matrix)

%% update equations in 2-D
A = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1];
B = [(dt^2/2); (dt^2/2); dt; dt];
C = [1 0 0 0; 0 1 0 0];

for data_th = 1:(size(raw,1)-1)
    if ~num(data_th,1)
        continue;
    end
    
    reject_dist = num(data_th, 11);
    start_frame = num(data_th, 4);
    end_frame = num(data_th, 5);
    frame_steps = num(data_th, 16);
    shuttleVideo = VideoReader(strcat('../input_share/',char(txt(data_th+1,2))));

    % load detection
    filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
    load(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'.mat'))

    % make output folder
    mkdir(strcat('./output/',shuttleVideo.name,'_',filename,'_pic'));
    mkdir(strcat('./output/',shuttleVideo.name,'_',filename,'_data'));

    % initialize result variables
    Q_loc_meas = []; % location measure

    % initialize estimation variables for two dimensions
    Q = [X{frame_start} Y{frame_start} zeros(length(X{frame_start}),1) zeros(length(X{frame_start}),1)]';
    Q_estimate = nan(4, MAX_FLIES);
    Q_estimate(:,1:size(Q,2)) = Q;  % initial location
    direction_track = nan(2, MAX_FLIES); % initialize the direction
    direction_track(:,1:size(keep_direction_sorted{frame_start},2)) = keep_direction_sorted{frame_start};
    ecc_enable = exist('keep_ecc_sorted');
    angle_enable = exist('keep_angle_sorted');
    if ecc_enable
        ecc_track = nan(1, MAX_FLIES);
        ecc_track(:,1:size(keep_ecc_sorted{frame_start},2)) = keep_ecc_sorted{frame_start};
    end
    if angle_enable
        angle_track = nan(1, MAX_FLIES);
        angle_track(:,1:size(keep_angle_sorted{frame_start},2)) = keep_angle_sorted{frame_start};
    end
    Q_loc_estimateY = nan(MAX_FLIES); % position estimate
    Q_loc_estimateX = nan(MAX_FLIES); % position estimate
    P_estimate = P;  % covariance estimator
    strk_trks = zeros(1, MAX_FLIES);  % counter of how many strikes a track has gotten
    outbound_trks = zeros(1, MAX_FLIES);  % counter of out boundary track
    nD = size(X{frame_start},1); % initize number of detections
    flyNum =  find(isnan(Q_estimate(1,:))==1,1)-1 ; % initize number of track estimates
    v_keep = nan(3, MAX_FLIES); % mean value of velocity
    v_agent_max_keep = nan(1, MAX_FLIES); % max velocity of an agent at each time step

    keep_data = cell(1,4);  % x y vx vy
    outFrameNum = int64((end_frame - start_frame + 1) / frame_steps) + 2;
    for i = 1:8
        keep_data{i} = nan(outFrameNum, MAX_FLIES);
    end

    % size
    img_initial = read(shuttleVideo,1);
    img_h = size(img_initial,1);
    img_w = size(img_initial,2);

    t = 1;
    for t_count = start_frame:frame_steps:end_frame
        % make the given detections matrix
        Q_loc_meas = [X{t} Y{t}];
        direction_meas = keep_direction_sorted{t};

        % major & minor
        if ecc_enable
            ecc_meas = keep_ecc_sorted{t};
        end

        % bodyline angle
        if angle_enable
            angle_meas = keep_angle_sorted{t};
        end


        % do the kalman filter
        % Predict next state
        nD = size(X{t},1); %set new number of detections

        Q_estimate_before_update = Q_estimate;  % keep Q_estimate before the update

        %                 % keep data from Q_estimate_before_update
        %                 for F = 1:nF
        %
        %                     keep_data{1}(t,F) = Q_estimate_before_update(1,F);
        %                     keep_data{2}(t,F) = Q_estimate_before_update(2,F);
        %                     keep_data{3}(t,F) = Q_estimate_before_update(3,F);
        %                     keep_data{4}(t,F) = Q_estimate_before_update(4,F);
        %
        %                 end

        for F = 1:flyNum
            Q_estimate(:,F) = A * Q_estimate(:,F) + B * u;
            %         if (Q_estimate(1,F) > img_h) || (Q_estimate(2,F) > img_w) || (Q_estimate(1,F) < 0) || (Q_estimate(2,F) < 0)
            %             % if the predict is out of bound
            %             Q_estimate(:,F) = NaN;
            %         end
        end



        %predict next covariance
        P = A * P* A' + Ex;
        % Kalman Gain
        K = P*C'*inv(C*P*C'+Ez);


        % assign the detections to estimated track positions
        %make the distance (cost) matrice between all pairs rows = tracks, coln =
        %detections
        if ~isempty(Q_loc_meas)

            est_dist = pdist([Q_estimate(1:2,1:flyNum)'; Q_loc_meas]);
            est_dist = squareform(est_dist); %make square
            est_dist = est_dist(1:flyNum,flyNum+1:end) ; %limit to just the tracks to detection distances

            %                 for est_count = 1:nF    % added on 2016-07-28
            %                     if min(est_dist(est_count,:)) < 50
            %                         est_dist(find(est_dist(est_count,:) ~= min(est_dist(est_count,:)))) = est_dist(find(est_dist(est_count,:) ~= min(est_dist(est_count,:)))) * 2;
            %                     end
            %                 end


            [asgn, cost] = assignmentoptimal(est_dist); %do the assignment with hungarian algo
            asgn = asgn';

            %check for tough situations and if it's tough, just go with estimate and ignore the data
            %make asgn = 0 for that tracking element

            %check 1: is the detection far from the observation? if so, reject it.
            rej = [];
            for F = 1:flyNum
                if asgn(F) > 0  % if track F has pair asgn(F)
                    rej(F) = est_dist(F,asgn(F)) < reject_dist ;
                    if check_direction_enable
                        v1 = direction_track(:,F);
                        v2 = direction_meas(:,asgn(F));
                        if (norm(v1) ~= 0) && (norm(v2) ~= 0)
                            angle_v1_v2 = acosd(dot(v1,v2)/norm(v1)/norm(v2));  % calculate the angle between two vectors
                            rej(F) = (-90 < angle_v1_v2) && (angle_v1_v2 < 90); % reject if direction is too different
                        end
                    end
                else
                    rej(F) = 0;
                end
            end


            %

            asgn = asgn.*rej;

            if ~kalman_only_enable
                Q_estimate_before_update(1:2, (asgn ~= 0)) = NaN;
                Q_loc_meas2 = Q_loc_meas;
                Q_loc_meas2(ismember(1:size(Q_loc_meas,1),asgn),:) = NaN;

                est_dist2 = pdist([Q_estimate_before_update(1:2,1:flyNum)'; Q_loc_meas2]);
                est_dist2 = squareform(est_dist2); %make square
                est_dist2 = est_dist2(1:flyNum,flyNum+1:end);  %limit to just the tracks to detection distances

                if cna_enable   % Closest Neighbour Approach
                    asgn2 = asgn.*0;
                    row_est_dist2 = max(sum(~isnan(est_dist2)));
                    col_est_dist2 = max(sum(~isnan(est_dist2),2));

                    if ((row_est_dist2 - col_est_dist2) >= 0)
                        count_target = col_est_dist2;
                    else
                        count_target = row_est_dist2;
                    end

                    for count2 = 1:count_target
                        %                             if min(min(est_dist2)) < reject_dist    % check again for reject distance in CNA case 20161014
                        [m,n] = find(est_dist2==min(min(est_dist2)));
if ~isempty(m) && ~isempty(n) % 2017-4-26 TODO: need to check later
                            asgn2(m(1)) = n(1);
                            est_dist2(m(1),:) = NaN;
                            est_dist2(:,n(1)) = NaN;
end
                        %                             end   % fixed bug 2016-12-30

                    end

                else    % hungarian assignment algorithm
                    [asgn2, cost2] = assignmentoptimal(est_dist2); %do the assignment with hungarian algo
                    asgn2 = asgn2';
                end


                asgn = asgn + asgn2;

            else
                asgn2 = asgn.*0;
            end



            %apply the assingment to the update
            k = 1;
            velocity_temp2 = [];
            for F = 1:length(asgn)
                Q_estimate_previous = Q_estimate(:,k);
                if asgn(F) > 0  % found its match
                    if asgn2(F) ~= 0    % second matching assignment
                        Q_estimate(:,k) = Q_estimate(:,k) + K * (Q_loc_meas(asgn(F),:)' - C * Q_estimate(:,k)); % same as asgn2
                        direction_track(:,k) = direction_meas(:,asgn(F));   % update the direction to be the match's direction
                        if ecc_enable
                            ecc_track(:,k) = ecc_meas(:,asgn(F));
                        end
                        if angle_enable
                            angle_track(:,k) = angle_meas(:,asgn(F));
                        end
                    else
                        Q_estimate(:,k) = Q_estimate(:,k) + K * (Q_loc_meas(asgn(F),:)' - C * Q_estimate(:,k)); % same as asgn
                        direction_track(:,k) = direction_meas(:,asgn(F));   % update the direction to be the match's direction
                        if ecc_enable
                            ecc_track(:,k) = ecc_meas(:,asgn(F));
                        end
                        if angle_enable
                            angle_track(:,k) = angle_meas(:,asgn(F));
                        end
                    end
                elseif asgn(F) == 0 % assignment for no assignment
                    if assign_for_noassign
                        if (Q_estimate(1,k) > img_h) || (Q_estimate(2,k) > img_w) || (Q_estimate(1,k) < 0) || (Q_estimate(2,k) < 0)
                            % if the predict is out of bound then do nothing

                        else
                            if min(est_dist(k,:)) < min_dist_threshold  % search nearest measurement within min_dist_threshold and op
                                [m,i] = min(est_dist(k,:));
                                Q_estimate(:,k) = Q_estimate(:,k) + K * (Q_loc_meas(i,:)' - C * Q_estimate(:,k));
                            end
                        end

                    end

                end

                % velocity thresholding
                if ~isnan(Q_estimate(1,k))  % if the value is not NaN
                    if velocity_thres_enable
                        % velocity filter (delete or use previous if the velocity is higher than velocity_thres)
                        if sqrt(Q_estimate(3,k)^2 + Q_estimate(4,k)^2) > velocity_thres
                            Q_estimate(:,k) = NaN;    % delete
                            %                       Q_estimate(:,k) = Q_estimate_previous;  % use the previous
                        end
                    end

                end



                k = k + 1;
            end

        end     % end of if ~isempty(Q_loc_meas)

        % update covariance estimation.
        P =  (eye(4)-K*C)*P;

        % Store data
        Q_loc_estimateX(t,1:flyNum) = Q_estimate(1,1:flyNum);
        Q_loc_estimateY(t,1:flyNum) = Q_estimate(2,1:flyNum);

        % keep data from Q_estimate
        for F = 1:flyNum
            keep_data{1}(t,F) = Q_estimate(1,F);
            keep_data{2}(t,F) = Q_estimate(2,F);
            keep_data{3}(t,F) = Q_estimate(3,F);
            keep_data{4}(t,F) = Q_estimate(4,F);
            keep_data{5}(t,F) = direction_track(1,F);   % keep_data{5} and keep_data{6} are for direction
            keep_data{6}(t,F) = direction_track(2,F);
            if ecc_enable
                keep_data{7}(t,F) = ecc_track(1,F);
            end
            if angle_enable
                keep_data{8}(t,F) = angle_track(1,F);
            end
        end


        if ~isempty(Q_loc_meas)

            %find the new detections. basically, anything that doesn't get assigned is a new tracking
            new_trk = Q_loc_meas(~ismember(1:size(Q_loc_meas,1),asgn),:)';
            if ~isempty(new_trk)
                Q_estimate(:,flyNum+1:flyNum+size(new_trk,2))=  [new_trk; zeros(2,size(new_trk,2))];
                flyNum = flyNum + size(new_trk,2);  % number of track estimates with new ones included
            end

        end  % end of if ~isempty(Q_loc_meas)

        %give a strike to any tracking that didn't get matched up to a
        %detection
        no_trk_list = find(asgn==0);
        prev_strk_trks = strk_trks;
        if ~isempty(no_trk_list)
            strk_trks(no_trk_list) = strk_trks(no_trk_list) + 1;
        end
        %% consecutive strike
        % if the strike is not consecutive then reset
        strk_trks(strk_trks == prev_strk_trks) = 0;


        %if a track has a strike greater than 6, delete the tracking. i.e.
        %make it nan first vid = 3
        bad_trks = find(strk_trks > strike_track_threshold);
        Q_estimate(:,bad_trks) = NaN;

        % output figure
        %%{
        if figure_enable
            clf
            img = read(shuttleVideo,t_count);
            %             img = imread(strcat('./input/',file_list(t).name));
            imshow(img);
            hold on;
            plot(Y{t}(:),X{t}(:),'or'); % the actual tracking
            T = size(Q_loc_estimateX,2);
            Ms = [3 5]; %marker sizes
            c_list = ['r' 'b' 'g' 'c' 'm' 'y'];
            for Dc = 1:flyNum     %normal
                %                     for Dc = 1:1        %rodent
                if ~isnan(Q_loc_estimateX(t,Dc))
                    Sz = mod(Dc,2)+1; %pick marker size
                    Cz = mod(Dc,6)+1; %pick color
                    if animal_type == 2
                        Cz = 1;
                    end
                    if t < line_length+2
                        st = t-1;
                    else
                        st = line_length;
                    end
                    tmX = Q_loc_estimateX(t-st:t,Dc);
                    tmY = Q_loc_estimateY(t-st:t,Dc);
                    plot(tmY,tmX,'.-','markersize',Ms(Sz),'color',c_list(Cz),'linewidth',3)  % rodent 1 instead of Cz
                    if num_text_enable
                        num_txt = strcat(' = ', num2str(Dc));
                        text(tmY(end),tmX(end),num_txt)
                    end
                    hold on
                    %                 quiver(Y{t}(11:12),X{t}(11:12),keep_direction_sorted{t}(1,11:12)',keep_direction_sorted{t}(2,11:12)', 'r', 'MaxHeadSize',1, 'LineWidth',1)  %arrow
                    axis off
                end
            end

            % save figure
            f=getframe;
            filename2 = [sprintf('%05d',t_count) '.png'];
            imwrite(f.cdata,strcat('./output/',shuttleVideo.name,'_',filename,'_pic/',filename2));

            pause(0.001)

        end


        %}
        disp(strcat('processing : ',shuttleVideo.name,'  ',num2str(100*(t_count-start_frame)/(end_frame-start_frame+1)), '%', '     t : ', num2str(t)   ));
        %     sum(strk_trks)
        set(handles.text9, 'String',[num2str(int64(100*(t_count-start_frame)/(end_frame-start_frame+1))) ' %']);
        pause(0.001)
        t = t + 1;
    end
    set(handles.text9, 'String', '100 %'); % done!

    % save data as text
    write_file_x = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_x','.txt'),'wt');
    write_file_y = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_y','.txt'),'wt');
    write_file_vx = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_vx','.txt'),'wt');
    write_file_vy = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_vy','.txt'),'wt');
    write_file_vxy = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_vxy','.txt'),'wt');
    write_file_dir = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_dir','.txt'),'wt');    % direction 2016-11-10
    write_file_dd = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_dd','.txt'),'wt');    % direction 2016-11-10
    write_file_dd2 = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_dd2','.txt'),'wt');    % direction 2016-11-11
    if ecc_enable
        write_file_ecc = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_ecc','.txt'),'wt');    % direction 2016-11-29
        keep_data{7} = keep_data{7}(:,1:flyNum);
    end
    if angle_enable
        write_file_angle = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_angle','.txt'),'wt');    % bodyline 2017-03-17
        keep_data{8} = keep_data{8}(:,1:flyNum);
        % inverse the angle upside-down
        keep_data{8} = -keep_data{8};
    end
    write_file_dis = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_dis','.txt'),'wt');
    write_file_svxy = fopen(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_svxy','.txt'),'wt');


    keep_data{1} = keep_data{1}(:,1:flyNum);
    keep_data{2} = keep_data{2}(:,1:flyNum);
    keep_data{3} = keep_data{3}(:,1:flyNum);
    keep_data{4} = keep_data{4}(:,1:flyNum);
    keep_data{5} = keep_data{5}(:,1:flyNum);
    keep_data{6} = keep_data{6}(:,1:flyNum);


    % find end of row
    a = isnan(keep_data{1});
    b = sum(a,2);
    end_row = find(b==flyNum,1) - 1;
    % make save string
    save_string = [];
    for s_count = 1:flyNum
        save_string = [save_string '%.4f '];
    end
    save_string = [save_string '\n'];


    % cook raw data before saving
    for row_count = 1:end_row
        fprintf(write_file_y,save_string , img_h - keep_data{1}(row_count, :));
        fprintf(write_file_x,save_string , keep_data{2}(row_count, :));
        if row_count > 1
            distance_travel = sqrt((keep_data{2}(row_count, :) - keep_data{2}(row_count-1, :)).^2 + (keep_data{1}(row_count, :) - keep_data{1}(row_count-1, :)).^2);
            fprintf(write_file_dis,save_string , distance_travel);
        end
        fprintf(write_file_vy,save_string , (-1).*keep_data{3}(row_count, :));
        fprintf(write_file_vx,save_string , keep_data{4}(row_count, :));
        vxy = sqrt( keep_data{3}(row_count, :).^2 +  keep_data{4}(row_count, :).^2  );
        fprintf(write_file_vxy,save_string , vxy);
        if row_count == 1
            v1 = [keep_data{5}(row_count, :); (-1).*keep_data{6}(row_count, :)];
            check_v1 = sum(v1.*v1);
            v1(:,check_v1==0) = NaN;
            angle_v1 = atan2d(v1(2,:),v1(1,:));
            fprintf(write_file_dd,save_string , (0).*keep_data{5}(row_count, :) );
            fprintf(write_file_dd2,save_string , (0).*keep_data{5}(row_count, :) );
        else
            v0 = v1;    % v2 contains the previous v1
            v1 = [keep_data{5}(row_count, :); (-1).*keep_data{6}(row_count, :)];
            check_v1 = sum(v1.*v1);
            v1(:,check_v1==0) = NaN;
            angle_v1 = atan2d(v1(2,:),v1(1,:));
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
            fprintf(write_file_dd,save_string , angle_v1_v0 );
            fprintf(write_file_dd2,save_string , angle_v1_v0_2 );
        end
        fprintf(write_file_dir,save_string , angle_v1 );
        if ecc_enable
            fprintf(write_file_ecc,save_string , keep_data{7}(row_count, :));
        end
        if angle_enable
            fprintf(write_file_angle,save_string , keep_data{8}(row_count, :));
        end

        % calculate sideway velocity
        bodyline_y = v1(2,:);
        bodyline_x = v1(1,:);
        % fill nan with data from angle
        nan_index = isnan(bodyline_y);
        bodyline_y(nan_index) = sind(keep_data{8}(row_count, nan_index));
        bodyline_x(nan_index) = cosd(keep_data{8}(row_count, nan_index));
        vy = (-1).*keep_data{3}(row_count, :);
        vx = keep_data{4}(row_count, :);
        setA = [bodyline_x' bodyline_y' zeros(size(bodyline_x,2),1)];
        setB = [vx' vy' zeros(size(vx,2),1)];
        corss_pro = cross(setA,setB);
        norm_setA = sqrt(sum(abs(setA).^2,2));
        svxy = corss_pro(:,3)./norm_setA;
        fprintf(write_file_svxy,save_string , svxy');   % sideway velocity
%                 dir_vxy = atan2d(vy,vx);
%                 angle_for_svxy = dir_vxy-angle_v1;
%                 fprintf(write_file_svxy,save_string , vxy.*sind(angle_for_svxy));

    end

    fclose(write_file_x);
    fclose(write_file_y);
    fclose(write_file_vx);
    fclose(write_file_vy);
    fclose(write_file_vxy);
    fclose(write_file_dir);
    fclose(write_file_dd);
    fclose(write_file_dd2);
    if ecc_enable
        fclose(write_file_ecc);
    end
    if angle_enable
        fclose(write_file_angle);
    end
    fclose(write_file_dis);
    fclose(write_file_svxy);

    % save keep_data
    save(strcat('./multi/track_',shuttleVideo.name,'_',filename,'.mat'), 'keep_data')

    % save input data used for generating this result
    raw_b = raw(data_th+1,:);
    raw_save = vertcat(raw_a,raw_b);
    sheet = 1;
    xlRange = 'A1';
    xlswrite(strcat('./output/',shuttleVideo.name,'_',filename,'_data/',shuttleVideo.name,'_',filename,'_','config.xlsx'),raw_save,sheet,xlRange);
end

% show end text
time = toc;
set(handles.edit1, 'String',strcat('tracking ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [ X_update_keep, Y_update_keep, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( blob_img, blob_img_logical, H, blob_threshold, blobSeparateRate, frameCount, blobAvgSizeIn)

[origAreas, origCenterPoints, origBoxes, origMajorAxis, origMinorAxis, origOrient, origEcc] = step(H, blob_img_logical);

labeledImage = bwlabel(blob_img_logical);   % label the image

area_mean = mean(origAreas);
blobAvgSize = (area_mean + blobAvgSizeIn * (frameCount - 1)) / frameCount;
blob_num = size(origAreas,1);
X_update_keep = [];
Y_update_keep = [];
blobAreas = [];
blobCenterPoints = [];
blobBoxes = [];
blobMajorAxis = [];
blobMinorAxis = [];
blobOrient = [];
blobEcc = [];

% loop for checking all blobs
for i = 1 : blob_num
    % check blobAreas dimension of current blob and how bigger than avarage.
    area_ratio = double(origAreas(i))/blobAvgSize;
    if (mod(area_ratio,1) > blobSeparateRate)
        expect_num = area_ratio + (1-mod(area_ratio,1));
    else
        expect_num = round(area_ratio); % round to the nearest integer
    end

    % check expected number of targets (animals)
    chooseOne = true;
    if expect_num <= 1  % expect one
        % set output later
    elseif expect_num > 4 % too big! isn't it?
        chooseOne = false;
    elseif expect_num > 1
        % find separated area
        blob_threshold2 = blob_threshold - 0.2;
        if blob_threshold2 < 0, blob_threshold2 = 0; end % should be positive

        label_mask = labeledImage==i;
        blob_img_masked = blob_img .* label_mask;

        % trimmed from original gray scale image
        rect = origBoxes(i,:);
        blob_img_trimmed = imcrop(blob_img_masked, rect);

        % stronger gaussian again
        blob_img_trimmed = imgaussfilt(blob_img_trimmed, 1);

        for th_i = 1 : 40
            blob_threshold2 = blob_threshold2 + 0.05;

            blob_img_trimmed2 = imbinarize(blob_img_trimmed, blob_threshold2);
            [trimmedAreas, trimmedCenterPoints, trimmedBoxes, trimmedMajorAxis, trimmedMinorAxis, trimmedOrient, trimmedEcc] = step(H, blob_img_trimmed2);

            if expect_num == size(trimmedAreas, 1) % change from <= to == 20161015
                x_choose = trimmedCenterPoints(1:expect_num,2);
                y_choose = trimmedCenterPoints(1:expect_num,1);    % choose expect_num according to area (large)
                X_update_keep = [X_update_keep ; x_choose + double(rect(2))];
                Y_update_keep = [Y_update_keep ; y_choose + double(rect(1))];
                blobAreas = [blobAreas ; trimmedAreas];
                blobMajorAxis = [blobMajorAxis ; trimmedMajorAxis];
                blobMinorAxis = [blobMinorAxis ; trimmedMinorAxis];
                blobOrient = [blobOrient ; trimmedOrient];
                blobEcc = [blobEcc ; trimmedEcc];
                for j=1 : expect_num
                    pt = trimmedCenterPoints(j,:) + [double(rect(1)) double(rect(2))];
                    box = trimmedBoxes(j,:) + [int32(rect(1)) int32(rect(2)) 0 0];
                    blobCenterPoints = [blobCenterPoints ; pt];
                    blobBoxes = [blobBoxes ; box];
                end
                chooseOne = false;
                break
            end
        end
    end
    if chooseOne
        % choose one
        X_update_keep = [X_update_keep ; origCenterPoints(i,2)];
        Y_update_keep = [Y_update_keep ; origCenterPoints(i,1)];
        blobAreas = [blobAreas ; origAreas(i)];
        blobCenterPoints = [blobCenterPoints ; origCenterPoints(i,:)];
        blobBoxes = [blobBoxes ; origBoxes(i,:)];
        blobMajorAxis = [blobMajorAxis ; origMajorAxis(i)];
        blobMinorAxis = [blobMinorAxis ; origMinorAxis(i)];
        blobOrient = [blobOrient ; origOrient(i)];
        blobEcc = [blobEcc ; origEcc(i)];
    end
end


function [ output_image ] = PD_blobfilter( image, h, sigma )
%UNTITLED ?±?Ì?Ö??Ì?T—v??±?±?É?L?q
%   h & sigma : the bigger, the larger the blob can be found
%   example : >>subplot(121); imagesc(h) >>subplot(122); mesh(h)
%   >>colormap(jet)

%   laplacian of a gaussian (LOG) template
log_kernel = fspecial('log', h, sigma);
%   2d convolution
output_image = conv2(image, log_kernel, 'same');

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

%%
function [ color1, color2 ] = getTopAndBottomColors(image, len, cosph, sinph, cx, cy, r)
dx = len * cosph;
dy = len * sinph;
x1 = int64(cx+dx); y1 = int64(cy+dy);
x2 = int64(cx-dx); y2 = int64(cy-dy);
colBox1 = image(y1-r:y1+r, x1-r:x1+r);
colBox2 = image(y2-r:y2+r, x2-r:x2+r);
area = ((r*2+1) * (r*2+1));
color1 = sum(sum(colBox1)) / area;
color2 = sum(sum(colBox2)) / area;

%%
function [ outVector, isFound ] = check4PointsColorsOnBody(vec, c1, c2, c3, c4, TH_OVER_HEAD_COLOR, TH_WING_COLOR_MAX, TH_WING_COLOR_MIN)
found = true;
% if c1 is darker, c1 is head.
if c1 > c2
    if c3 < c4
        % c2 should be head (darker), then c3 should be wing (darker). so flip now
        vec = -vec;
    else
        % oops c1-c2 and c3-c4 is conflicted
        if c3 > TH_OVER_HEAD_COLOR && TH_WING_COLOR_MIN < c4 && c4 < TH_WING_COLOR_MAX % c4 should be wing & c3 should be over head
            vec = -vec;
        else
            found = false;
        end
    end
else
    % c1 should be head (darker), then c4 should be wing (darker).
    if c3 < c4
        % oops c1-c2 and c3-c4 is conflicted
        if c4 > TH_OVER_HEAD_COLOR && TH_WING_COLOR_MIN < c3 && c3 < TH_WING_COLOR_MAX % c3 should be wing & c4 should be over head
            vec = -vec;
        else
            found = false;
        end
    end
end
outVector = vec;
isFound = found;

%%
function [ keep_direction, keep_angle ] = PD_direction2(grayImage, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient)
% init
areaNumber = size(blobAreas, 1);
keep_direction = zeros(2, areaNumber); % allocate memory
keep_angle = zeros(1, areaNumber); % allocate memory;

% constant hidden params
TH_OVER_HEAD_COLOR = 245;
TH_WING_COLOR_MAX = 232;
TH_WING_COLOR_MIN = 195;
TH_HEAD_WING_DIFF_COLOR = 15; % between head and wing
TH_WING_BG_DIFF_COLOR = 25;   % between wing and background

% find direction for every blobs
for i = 1:areaNumber
    % pre calculation
    angle = -blobOrient(i)*180 / pi;
    cx = blobCenterPoints(i,1);
    cy = blobCenterPoints(i,2);
    ph = -blobOrient(i);
    cosph =  cos(ph);
    sinph =  sin(ph);
    len = blobMajorAxis(i) * 0.35;
    vec = [len*cosph; len*sinph];

    % get head and tail colors
    [ c1, c2 ] = getTopAndBottomColors(grayImage, len, cosph, sinph, cx, cy, 2);

    % get over head and over tail (maybe wing) colors
    [ c3, c4 ] = getTopAndBottomColors(grayImage, blobMajorAxis(i) * 0.6, cosph, sinph, cx, cy, 2);

    % 1st step. find head and wing on long axis line (just check 4 points' color) 
    [ vec, found ] = check4PointsColorsOnBody(vec, c1, c2, c3, c4, TH_OVER_HEAD_COLOR, TH_WING_COLOR_MAX, TH_WING_COLOR_MIN);

    if ~found
        % 1st step - check one more points
        [ c1a, c2a ] = getTopAndBottomColors(grayImage, blobMajorAxis(i) * 0.4, cosph, sinph, cx, cy, 1);
        [ c3a, c4a ] = getTopAndBottomColors(grayImage, blobMajorAxis(i) * 0.5, cosph, sinph, cx, cy, 1);
        [ vec, found ] = check4PointsColorsOnBody(vec, c1a, c2a, c3a, c4a, TH_OVER_HEAD_COLOR, TH_WING_COLOR_MAX, TH_WING_COLOR_MIN);
    end

    % 2nd step. find side back wing
    if ~found
        for j=1:3
            % check -30 and +30
            if j==2 continue; end
            ph2 = ph + pi/180 * (j-2)*30;
            cosph2 =  cos(ph2);
            sinph2 =  sin(ph2);
            [ c5, c6 ] = getTopAndBottomColors(grayImage, blobMajorAxis(i) * 0.45, cosph2, sinph2, cx, cy, 2);
            if abs(c5 - c6) > TH_WING_BG_DIFF_COLOR
                % wing should connected body and over-wing should white
                % because some time miss-detects next side body.
                [ c7, c8 ] = getTopAndBottomColors(grayImage, blobMajorAxis(i) * 0.4, cosph2, sinph2, cx, cy, 2);
                [ c9, c10 ] = getTopAndBottomColors(grayImage, blobMajorAxis(i) * 0.6, cosph2, sinph2, cx, cy, 2);
                % if c6 is wing, check colors on line.
                if (c6 - c8) > -5 && (c10 - c6) > 5
                    found = true;
                    break;
                % if c5 is wing, check colors on line.
                elseif (c5 - c7) > -5 && (c9 - c5) > 5
                    vec = -vec;
                    found = true;
                    break;
                end
            end
        end
    end

    % 3rd step. check long (body) axis colors
    if ~found
        for j=0.40:0.05:0.55
            [ c5, c6 ] = getTopAndBottomColors(grayImage, blobMajorAxis(i) * j, cosph, sinph, cx, cy, 2);
            if c6 > TH_OVER_HEAD_COLOR && TH_WING_COLOR_MIN < c5 && c5 < TH_WING_COLOR_MAX % c5 should be wing & c6 should be over head
                vec = -vec;
                found = true;
                break
            elseif c5 > TH_OVER_HEAD_COLOR && TH_WING_COLOR_MIN < c6 && c6 < TH_WING_COLOR_MAX % c6 should be wing & c5 should be over head
                found = true;
                break;
            elseif (c5 - c6) > TH_HEAD_WING_DIFF_COLOR && TH_WING_COLOR_MIN < c5
                % c6 should be head. so flip now
                vec = -vec;
                found = true;
                break;
            elseif (c6 - c5) > TH_HEAD_WING_DIFF_COLOR && TH_WING_COLOR_MIN < c6
                % c5 should be head.
                found = true;
                break;
            end
        end
    end
    % hmm...not detected well
    if ~found
        vec = vec * 0;
    end
    keep_direction(:,i) = vec;
    keep_angle(:,i) = angle;
end

%%
function [assignment, cost] = assignmentoptimal(distMatrix)
%ASSIGNMENTOPTIMAL    Compute optimal assignment by Munkres algorithm
%   ASSIGNMENTOPTIMAL(DISTMATRIX) computes the optimal assignment (minimum
%   overall costs) for the given rectangular distance or cost matrix, for
%   example the assignment of tracks (in rows) to observations (in
%   columns). The result is a column vector containing the assigned column
%   number in each row (or 0 if no assignment could be done).
%
%   [ASSIGNMENT, COST] = ASSIGNMENTOPTIMAL(DISTMATRIX) returns the
%   assignment vector and the overall cost.
%
%   The distance matrix may contain infinite values (forbidden
%   assignments). Internally, the infinite values are set to a very large
%   finite number, so that the Munkres algorithm itself works on
%   finite-number matrices. Before returning the assignment, all
%   assignments with infinite distance are deleted (i.e. set to zero).
%
%   A description of Munkres algorithm (also called Hungarian algorithm)
%   can easily be found on the web.
%
%   <a href="assignment.html">assignment.html</a>  <a href="http://www.mathworks.com/matlabcentral/fileexchange/6543">File Exchange</a>  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EVW2A4G2HBVAU">Donate via PayPal</a>
%
%   Markus Buehren
%   Last modified 05.07.2011

% save original distMatrix for cost computation
originalDistMatrix = distMatrix;

% check for negative elements
if any(distMatrix(:) < 0)
    error('All matrix elements have to be non-negative.');
end

% get matrix dimensions
[nOfRows, nOfColumns] = size(distMatrix);

% check for infinite values
finiteIndex   = isfinite(distMatrix);
infiniteIndex = find(~finiteIndex);
if ~isempty(infiniteIndex)
    % set infinite values to large finite value
    maxFiniteValue = max(max(distMatrix(finiteIndex)));
    if maxFiniteValue > 0
        infValue = abs(10 * maxFiniteValue * nOfRows * nOfColumns);
    else
        infValue = 10;
    end
    if isempty(infValue)
        % all elements are infinite
        assignment = zeros(nOfRows, 1);
        cost       = 0;
        return
    end
    distMatrix(infiniteIndex) = infValue;
end

% memory allocation
coveredColumns = zeros(1,       nOfColumns);
coveredRows    = zeros(nOfRows, 1);
starMatrix     = zeros(nOfRows, nOfColumns);
primeMatrix    = zeros(nOfRows, nOfColumns);

% preliminary steps
if nOfRows <= nOfColumns
    minDim = nOfRows;
    
    % find the smallest element of each row
    minVector = min(distMatrix, [], 2);
    
    % subtract the smallest element of each row from the row
    distMatrix = distMatrix - repmat(minVector, 1, nOfColumns);
    
    % Steps 1 and 2
    for row = 1:nOfRows
        for col = find(distMatrix(row,:)==0)
            if ~coveredColumns(col)%~any(starMatrix(:,col))
                starMatrix(row, col) = 1;
                coveredColumns(col)  = 1;
                break
            end
        end
    end
    
else % nOfRows > nOfColumns
    minDim = nOfColumns;
    
    % find the smallest element of each column
    minVector = min(distMatrix);
    
    % subtract the smallest element of each column from the column
    distMatrix = distMatrix - repmat(minVector, nOfRows, 1);
    
    % Steps 1 and 2
    for col = 1:nOfColumns
        for row = find(distMatrix(:,col)==0)'
            if ~coveredRows(row)
                starMatrix(row, col) = 1;
                coveredColumns(col)  = 1;
                coveredRows(row)     = 1;
                break
            end
        end
    end
    coveredRows(:) = 0; % was used auxiliary above
end

if sum(coveredColumns) == minDim
    % algorithm finished
    assignment = buildassignmentvector(starMatrix);
else
    % move to step 3
    [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
        step3(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim); %#ok
end

% compute cost and remove invalid assignments
[assignment, cost] = computeassignmentcost(assignment, originalDistMatrix, nOfRows);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function assignment = buildassignmentvector(starMatrix)

[maxValue, assignment] = max(starMatrix, [], 2);
assignment(maxValue == 0) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, cost] = computeassignmentcost(assignment, distMatrix, nOfRows)

rowIndex   = find(assignment);
costVector = distMatrix(rowIndex + nOfRows * (assignment(rowIndex)-1));
finiteIndex = isfinite(costVector);
cost = sum(costVector(finiteIndex));
assignment(rowIndex(~finiteIndex)) = 0;

% Step 2: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    step2(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim)

% cover every column containing a starred zero
maxValue = max(starMatrix);
coveredColumns(maxValue == 1) = 1;

if sum(coveredColumns) == minDim
    % algorithm finished
    assignment = buildassignmentvector(starMatrix);
else
    % move to step 3
    [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
        step3(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim);
end

% Step 3: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    step3(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim)

zerosFound = 1;
while zerosFound
    
    zerosFound = 0;
    for col = find(~coveredColumns)
        for row = find(~coveredRows')
            if distMatrix(row,col) == 0
                
                primeMatrix(row, col) = 1;
                starCol = find(starMatrix(row,:));
                if isempty(starCol)
                    % move to step 4
                    [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
                        step4(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, row, col, minDim);
                    return
                else
                    coveredRows(row)        = 1;
                    coveredColumns(starCol) = 0;
                    zerosFound              = 1;
                    break % go on in next column
                end
            end
        end
    end
end

% move to step 5
[assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    step5(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim);

% Step 4: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    step4(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, row, col, minDim)

newStarMatrix          = starMatrix;
newStarMatrix(row,col) = 1;

starCol = col;
starRow = find(starMatrix(:, starCol));

while ~isempty(starRow)
    
    % unstar the starred zero
    newStarMatrix(starRow, starCol) = 0;
    
    % find primed zero in row
    primeRow = starRow;
    primeCol = find(primeMatrix(primeRow, :));
    
    % star the primed zero
    newStarMatrix(primeRow, primeCol) = 1;
    
    % find starred zero in column
    starCol = primeCol;
    starRow = find(starMatrix(:, starCol));
    
end
starMatrix = newStarMatrix;

primeMatrix(:) = 0;
coveredRows(:) = 0;

% move to step 2
[assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    step2(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim);


% Step 5: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    step5(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim)

% find smallest uncovered element
uncoveredRowsIndex    = find(~coveredRows');
uncoveredColumnsIndex = find(~coveredColumns);
[s, index1] = min(distMatrix(uncoveredRowsIndex,uncoveredColumnsIndex));
[s, index2] = min(s); %#ok
h = distMatrix(uncoveredRowsIndex(index1(index2)), uncoveredColumnsIndex(index2));

% add h to each covered row
index = find(coveredRows);
distMatrix(index, :) = distMatrix(index, :) + h;

% subtract h from each uncovered column
distMatrix(:, uncoveredColumnsIndex) = distMatrix(:, uncoveredColumnsIndex) - h;

% move to step 3
[assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    step3(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim);


% --- Executes on button press in RIO.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath(genpath('function'));
addpath(genpath('input'));
addpath(genpath('parameter'));
addpath(genpath('multi'));
addpath(genpath('detect_output'));
addpath(genpath('../input_share'));

file_list2 =  dir('../input_share/*avi');
if isempty(file_list2)
    file_list2 = dir('../input_share/*mov');
end

if ~isempty(file_list2)
    %     file_list = [];
    file_list3 = dir('./input/input_video_control.xlsx');
    if ~isempty(file_list3)
        [num,txt,raw] = xlsread('./input/input_video_control.xlsx');
    else
        disp('please put input xlsx files into the folder');
        return;
    end
else
    disp('please put input video files into the folder');
    return;
end

% show start text
set(handles.edit1, 'String','selecting "Region of Interest" ...')
set(handles.text9, 'String','Running','BackgroundColor','red');

% select roi for every movie
for data_th = 1:(size(raw,1)-1)
    if num(data_th,1) && num(data_th,10)
        shuttleVideo = VideoReader(strcat('../input_share/',char(txt(data_th+1,2))));
        frameImage = read(shuttleVideo,1);
        grayImage = rgb2gray(frameImage);

        pathName = strcat('./roi/',shuttleVideo.name);
        roiFileName = strcat(pathName,'/',shuttleVideo.name,'_roi.png');

        % create new roi window if it does not exist
        if ~exist('figureWindow','var') || isempty(figureWindow) || ~ishandle(figureWindow)
            figureWindow = figure('name','selecting roi','NumberTitle','off');
        end
        
        % change title message
        set(figureWindow, 'name', ['select roi for ', shuttleVideo.name]);

        if exist(roiFileName, 'file')
            roiImage = imread(roiFileName);
            roiImage = im2double(roiImage);
            img = double(grayImage).*imcomplement(roiImage);
            img = uint8(img);
        else
            if ~exist(pathName, 'dir')
                mkdir(pathName);
            end
            img = frameImage;
        end
        
        % show polygon selection window
        newRoiImage = roipoly(img);

        % if canceled, do not show and save roi file
        if ~isempty(newRoiImage)
            img = double(grayImage).*imcomplement(newRoiImage);
            img = uint8(img);
            imshow(img)

            % write roi file
            imwrite(newRoiImage, roiFileName);
        end
    end
end

% close background image window
if exist('figureWindow','var') && ~isempty(figureWindow) && ishandle(figureWindow)
    pause(2);
    close(figureWindow);
end

% show end text
set(handles.edit1, 'String','selecting "Region of Interest" ... done!')
set(handles.text9, 'String','Ready','BackgroundColor','green');


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tic

video_flag = 0;

%% make video by browsing

% [filename, pathname, filterindex] = uigetfile( {  ...
%     '*.*',  'All Files (*.*)'}, ...
%     'Pick a file', ...
%     'MultiSelect', 'on', './output');
% 
% video_name = 'video';
% fps = get(handles.edit2,'String');
% fps_num = str2num(fps);
% 
% if isempty(fps_num)
%     errordlg('Please fill fps.','Error Code I');
% else
%     
% keyboard

%% make video from input file
[num,txt,raw] = xlsread('./input/input_video_control.xlsx');

for data_th = 1:(size(raw,1)-1)
    if num(data_th,1)
        start_frame = num(data_th, 4);
        end_frame = num(data_th, 5);
        filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
        video_name = char(txt(data_th+1,2));
        folder_name = strcat('./output/',video_name,'_',filename,'_pic');
        
        
        fps = get(handles.edit2,'String');
        fps_num = str2num(fps);
        
        if isempty(fps_num)
            errordlg('Please fill fps.','Error Code I');
        else
            
            addpath(genpath('output'))
            
            adjust_img_enable = 0;
            adjust_img = -20;   % additional value for adjusting the img
            
            set_framerate = fps_num;  % set frame-rate manually here
            
            imageNames = dir(fullfile(folder_name,'*.png'));
            if isempty(imageNames)
                errordlg('No input images.','Error Code II');
                break;
            end
            
            imageNames = {imageNames.name}';
            
            name_begin = char(imageNames(1));
            name_begin = name_begin(1:end-4);
            name_last = char(imageNames(end));
            name_last = name_last(1:end-4);
            
            outputVideo = VideoWriter(fullfile(folder_name,strcat(video_name,'_',name_begin,'_to_',name_last)));
            outputVideo.FrameRate = set_framerate;
            
            
            %% make video
            
            open(outputVideo)
            
            for ii = 1:length(imageNames)
                img = imread(fullfile(folder_name,imageNames{ii}));
                img2 = rgb2gray(img);
                
                if adjust_img_enable
                    img = img + adjust_img;
                    img(img==245+adjust_img) = 245;
                end
                writeVideo(outputVideo,img)
                clc
                pause(0.001)
                set(handles.text9, 'String',[num2str(100*ii/length(imageNames)) ' %'])
            end
            
            close(outputVideo)
            video_flag = 1;
            %     img2 = img - adjust_img;
            %     imshowpair(img,img2,'montage')
        end
        
        
    end
end



time = toc;
if video_flag
    set(handles.edit1, 'String',strcat('video done!     t =',num2str(time),'s'))
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double





% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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

%% http://www.mathworks.com/matlabcentral/fileexchange/12275-extrema-m--extrema2-m
function [xmax,imax,xmin,imin] = extrema(x)
%EXTREMA   Gets the global extrema points from a time series.
%   [XMAX,IMAX,XMIN,IMIN] = EXTREMA(X) returns the global minima and maxima
%   points of the vector X ignoring NaN's, where
%    XMAX - maxima points in descending order
%    IMAX - indexes of the XMAX
%    XMIN - minima points in descending order
%    IMIN - indexes of the XMIN
%
%   DEFINITION (from http://en.wikipedia.org/wiki/Maxima_and_minima):
%   In mathematics, maxima and minima, also known as extrema, are points in
%   the domain of a function at which the function takes a largest value
%   (maximum) or smallest value (minimum), either within a given
%   neighbourhood (local extrema) or on the function domain in its entirety
%   (global extrema).
%
%   Example:
%      x = 2*pi*linspace(-1,1);
%      y = cos(x) - 0.5 + 0.5*rand(size(x)); y(40:45) = 1.85; y(50:53)=NaN;
%      [ymax,imax,ymin,imin] = extrema(y);
%      plot(x,y,x(imax),ymax,'g.',x(imin),ymin,'r.')
%
%   See also EXTREMA2, MAX, MIN

%   Written by
%   Lic. on Physics Carlos Adrián Vargas Aguilera
%   Physical Oceanography MS candidate
%   UNIVERSIDAD DE GUADALAJARA
%   Mexico, 2004
%
%   nubeobscura@hotmail.com

% From       : http://www.mathworks.com/matlabcentral/fileexchange
% File ID    : 12275
% Submited at: 2006-09-14
% 2006-11-11 : English translation from spanish.
% 2006-11-17 : Accept NaN's.
% 2007-04-09 : Change name to MAXIMA, and definition added.


xmax = [];
imax = [];
xmin = [];
imin = [];

% Vector input?
Nt = numel(x);
if Nt ~= length(x)
    error('Entry must be a vector.')
end

% NaN's:
inan = find(isnan(x));
indx = 1:Nt;
if ~isempty(inan)
    indx(inan) = [];
    x(inan) = [];
    Nt = length(x);
end

% Difference between subsequent elements:
dx = diff(x);

% Is an horizontal line?
if ~any(dx)
    return
end

% Flat peaks? Put the middle element:
a = find(dx~=0);              % Indexes where x changes
lm = find(diff(a)~=1) + 1;    % Indexes where a do not changes
d = a(lm) - a(lm-1);          % Number of elements in the flat peak
a(lm) = a(lm) - floor(d/2);   % Save middle elements
a(end+1) = Nt;

% Peaks?
xa  = x(a);             % Serie without flat peaks
b = (diff(xa) > 0);     % 1  =>  positive slopes (minima begin)
% 0  =>  negative slopes (maxima begin)
xb  = diff(b);          % -1 =>  maxima indexes (but one)
% +1 =>  minima indexes (but one)
imax = find(xb == -1) + 1; % maxima indexes
imin = find(xb == +1) + 1; % minima indexes
imax = a(imax);
imin = a(imin);

nmaxi = length(imax);
nmini = length(imin);

% Maximum or minumim on a flat peak at the ends?
if (nmaxi==0) && (nmini==0)
    if x(1) > x(Nt)
        xmax = x(1);
        imax = indx(1);
        xmin = x(Nt);
        imin = indx(Nt);
    elseif x(1) < x(Nt)
        xmax = x(Nt);
        imax = indx(Nt);
        xmin = x(1);
        imin = indx(1);
    end
    return
end

% Maximum or minumim at the ends?
if (nmaxi==0)
    imax(1:2) = [1 Nt];
elseif (nmini==0)
    imin(1:2) = [1 Nt];
else
    if imax(1) < imin(1)
        imin(2:nmini+1) = imin;
        imin(1) = 1;
    else
        imax(2:nmaxi+1) = imax;
        imax(1) = 1;
    end
    if imax(end) > imin(end)
        imin(end+1) = Nt;
    else
        imax(end+1) = Nt;
    end
end
xmax = x(imax);
xmin = x(imin);

% NaN's:
if ~isempty(inan)
    imax = indx(imax);
    imin = indx(imin);
end

% Same size as x:
imax = reshape(imax,size(xmax));
imin = reshape(imin,size(xmin));

% Descending order:
[temp,inmax] = sort(-xmax); clear temp
xmax = xmax(inmax);
imax = imax(inmax);
[xmin,inmin] = sort(xmin);
imin = imin(inmin);

function [ theta,rho, inlrNum, direction ] = ransac_circle( center, pts,iterNum,thDist,thInlrRatio , mode)
%RANSAC Use RANdom SAmple Consensus to fit a line
%	RESCOEF = RANSAC(PTS,ITERNUM,THDIST,THINLRRATIO) PTS is 2*n matrix including
%	n points, ITERNUM is the number of iteration, THDIST is the inlier
%	distance threshold and ROUND(THINLRRATIO*SIZE(PTS,2)) is the inlier number threshold. The final
%	fitted line is RHO = sin(THETA)*x+cos(THETA)*y.
%	Yan Ke @ THUEE, xjed09@gmail.com

sampleNum = 2;
ptNum = size(pts,2);
thInlr = round(thInlrRatio*ptNum);
inlrNum = zeros(1,iterNum);
theta1 = zeros(1,iterNum);
rho1 = zeros(1,iterNum);
direction1 = zeros(2,iterNum);

for p = 1:iterNum
    
    %     pts2 = pts;
    
    % 1. fit using 2 random points
    if mode == 1
        sampleIdx = randIndex(ptNum,sampleNum);
        ptSample = pts(:,sampleIdx);
    else % mode 0 not random
        ptSample = [center pts(:,p)];
    end
    d = ptSample(:,2)-ptSample(:,1);
    d = d/norm(d); % direction vector of the line
    
    
    % 2. count the inliers, if more than thInlr, refit; else iterate
    n = [-d(2),d(1)]; % unit normal vector of the line
    
    %     % 1.1 modify a bit
    %     m = n(2)/n(1);
    %     if m*( pts(1,p) - center(1)) + center(2) > pts(2,p)
    %         pts2(:,find(m*( pts(1,:) - center(1)) + center(2) <= pts(2,:))) = [];
    %     elseif m*( pts(1,p) - center(1)) + center(2) < pts(2,p)
    %         pts2(:,find(m*( pts(1,:) - center(1)) + center(2) >= pts(2,:))) = [];
    %     else
    %
    %     end
    %     ptNum = size(pts2,2);
    
    dist1 = n*(pts-repmat(ptSample(:,1),1,ptNum));
    % 	dist1 = n*(pts2-repmat(ptSample(:,1),1,ptNum));
    inlier1 = find(abs(dist1) < thDist);
    inlrNum(p) = length(inlier1);
    if length(inlier1) < thInlr, continue; end
    ev = princomp(pts(:,inlier1)');
    d1 = ev(:,1);
    theta1(p) = -atan2(d1(2),d1(1)); % save the coefs
    rho1(p) = [-d1(2),d1(1)]*mean(pts(:,inlier1),2);
    direction1(:,p) = d;
end

% % 3. choose the coef with the most inliers
% [~,idx] = max(inlrNum);
% theta = theta1(idx);
% rho = rho1(idx);

theta = theta1';
rho = rho1';
inlrNum = inlrNum';
direction = direction1';


% --- Detect + Track
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pushbutton4_Callback(hObject, eventdata, handles)
pushbutton5_Callback(hObject, eventdata, handles)


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
