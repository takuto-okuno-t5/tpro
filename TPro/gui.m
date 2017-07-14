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

% Last Modified by GUIDE v2.5 13-Jul-2017 13:54:47

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
if exist('./io','dir')
    addpath('./io');
    addpath('./gui');
    addpath('./calc');
    addpath('./util');
    addpath('./dialogs');
end

% init command line input
handles.movies = {};
handles.template = [];
handles.batch = [];
handles.path = [];
handles.rois = {};
handles.autobackground = 0;
handles.autodetect = 0;
handles.autotracking = 0;
handles.autofinish = 0;

% load command line input
i = 1;
while true
	if i > size(varargin, 2)
        break;
    end
    switch varargin{i}
        case {'-b','--batch'}
            handles.batch = varargin{i+1};
            i = i + 1;
        case {'-p','--path'}
            handles.path = varargin{i+1};
            i = i + 1;
        case {'-c','--conf'}
            handles.template = varargin{i+1};
            i = i + 1;
        case {'-r','--roi'}
            handles.rois = [handles.rois varargin{i+1}];
            i = i + 1;
        case {'-g','--background'}
            handles.autobackground = 1;
        case {'-d','--detect'}
            handles.autodetect = 1;
        case {'-t','--tracking'}
            handles.autotracking = 1;
        case {'-f','--finish'}
            handles.autofinish = 1;
        case {'-h','--help'}
            disp('usage: gui [options] movies ...');
            disp('  -b, --batch file    batch csv [file]');
            disp('  -p, --path path     movie [path] for batch process');
            disp('  -c, --conf file     detection and tracking configuration template [file]');
            disp('  -r, --roi file      ROI image [file]');
            disp('  -g, --background    force to start background detection');
            disp('  -d, --detect        force to start detection');
            disp('  -t, --tracking      force to start tracking');
            disp('  -f, --finish        force to finish tpro after processing');
            disp('  -h, --help          show tpro command line help');
            handles.autofinish = 1;
        otherwise
            handles.movies = [handles.movies varargin{i}];
    end
    i = i + 1;
end
guidata(hObject, handles);

% set window title
versionNumber = '1.4.3';
set(gcf, 'name', ['TPro version ', versionNumber]);
set(handles.text14, 'String', ['TPro ', versionNumber])

% set initialized message
set(handles.text14, 'String','Welcome! Please click the buttons on the left to run')

% init gui parts
handles.uitable2.ColumnName = {'file name','path'};
handles.uitable2.ColumnWidth = {200,440};
handles.uitable2.RowName = [];

if exist('ui/drag_and_drop.png','file')
    axes(handles.axes1); % set drawing area
    imshow(imread('ui/drag_and_drop.png'));
    handles.axes1.Box = 'off';
    handles.axes1.Color = 'None';
    handles.axes1.FontSize = 1;
    handles.axes1.XMinorTick = 'off';
    handles.axes1.YMinorTick = 'off';
    handles.axes1.XTick = [0];
    handles.axes1.YTick = [0];
else
    handles.axes1.Visible = 'off';
end

initFileUITable(handles);
checkAllButtons(handles);
pause(0.01);

% initialize dndcontrol
dndcontrol.initJava();

jPanel = javaObjectEDT('javax.swing.JPanel');
bgcolor = get(gcf, 'Color');
jPanel.setBackground(java.awt.Color(bgcolor(1),bgcolor(2),bgcolor(3)));

% Add Scrollpane to figure
[~,hContainer] = javacomponent(jPanel,[],hObject);
set(hContainer,'Units','normalized','Position',[0 0 1 1]);
uistack(hContainer,'bottom');
%hObject.Children

% Set Drop callback functions
dndobj = dndcontrol(jPanel, hContainer);
dndobj.DropFileFcn = @onDropFile;
dndobj.DropStringFcn = @onDropFile;

% working with command line mode
runCommandLineMode(hObject, eventdata, handles);


%% 
function initFileUITable(handles)
inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;
tebleItems = {};

for i = 1:size(videoFiles,1)
    row = {videoFiles{i}, videoPath};
    tebleItems = [tebleItems; row];
end
% update uitable
handles.uitable2.Data = tebleItems;


%% Callback function
function onDropFile(hObject, eventdata)
videoFiles = {};
tebleItems = {};
switch eventdata.DropType
    case 'file'
        % process all dragged files
        for n = 1:numel(eventdata.Data)
            [videoPath, name, ext] = fileparts(eventdata.Data{n});
            videoFiles = [videoFiles; [name ext]];
        end
    case 'string'
        % nothing to do
end
% sort input files
videoFiles = sort(videoFiles);
for n = 1:length(videoFiles)
    row = {videoFiles{n}, videoPath};
    tebleItems = [tebleItems; row];
end

% show starting message
hUIControl = hObject.hUIControl;
hFig = ancestor(hUIControl, 'figure');
handles = guidata(hFig);
set(handles.text14, 'String', 'creating configuration file (csv) ...');
disableAllButtons(handles);
pause(0.01);

tic;

% create config files if possible
status = createConfigFiles([videoPath '/'], videoFiles, handles.template);

time = toc;

% show result message
if status 
    set(handles.text14, 'String',strcat('creating configuration file (csv) ... done!     t =',num2str(time),'s'));
    set(handles.text9,'String','Ready','BackgroundColor','green');
else
    set(handles.text14, 'String',strcat('can not output configuration file (csv)'));
    set(handles.text9,'String','Failed','BackgroundColor','red');
end
checkAllButtons(handles);

% update uitable
handles.uitable2.Data = tebleItems;


%% TPro command line mode
function runCommandLineMode(hObject, eventdata, handles)
% start batch process
if length(handles.batch) > 0
    % load batch file
    if ~exist(handles.batch, 'file')
        disp(['can not read batch file : ' handles.batch]);
        delete(hObject);
        return;
    end

    confTable = readtable(handles.batch);
    batches = table2cell(confTable);
    
    videoPath = handles.path;
    videoFiles = {};
    tebleItems = {};
    for i=1:size(batches,1)
        videoFiles = [videoFiles; batches{i,2}];
        row = {batches{i,2}, handles.path};
        tebleItems = [tebleItems; row];
    end
    handles.uitable2.Data = tebleItems;

    % create config files if possible
    status = createConfigFiles([videoPath '/'], videoFiles, handles.batch);
    if ~status
        disp('failed to create a configuration file');
        delete(hObject);
        return;
    end
end
% start to load movie files
if length(handles.movies) > 0
    videoFiles = {};
    tebleItems = {};
    for i=1:length(handles.movies)
        [videoPath, name, ext] = fileparts(handles.movies{i});
        videoFiles = [videoFiles; [name ext]];
    end
    % sort input files
    videoFiles = sort(videoFiles);
    for n = 1:length(videoFiles)
        row = {videoFiles{n}, videoPath};
        tebleItems = [tebleItems; row];
    end
    handles.uitable2.Data = tebleItems;

    % create config files if possible
    status = createConfigFiles([videoPath '/'], videoFiles, handles.template);
    if ~status
        disp('failed to create a configuration file');
        delete(hObject);
        return;
    end
end
% create roi files
if length(handles.rois) > 0
    roiFiles = {};
    for i=1:length(handles.rois)
        roiFileName = handles.rois{i};
        if exist(roiFileName, 'file')
            roiImage = imread(roiFileName);
            clear roiImage;
        end
        roiFiles = [roiFiles; roiFileName];
    end

    for i=1:length(videoFiles)
        confPath = [videoPath '/' videoFiles{i} '_tpro/'];
        csvFileName = [confPath 'roi.csv'];
        confFileName = [confPath 'input_video_control.csv'];

        % save roi.csv
        T = array2table(roiFiles);
        writetable(T,csvFileName,'WriteVariableNames',false);

        % update ROI param in configuration
        confTable = readtable(confFileName);
        record = table2cell(confTable);
        record{10} = length(roiFiles);
        status = saveInputControlFile(confFileName, record);
        if ~status
            disp(['failed to save a configuration file : ' confFileName]);
            delete(hObject);
            return;
        end
    end
end
% update uitable
checkAllButtons(handles);
pause(0.01);

if handles.autobackground
    pushbutton2_Callback(handles.pushbutton2, eventdata, handles)
end
if handles.autodetect
    pushbutton4_Callback(handles.pushbutton4, eventdata, handles)
end
if handles.autotracking
    pushbutton5_Callback(handles.pushbutton5, eventdata, handles)
end
if handles.autofinish
    delete(hObject);
end


%% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];


%% prepare--- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.text9,'String','Running','BackgroundColor','red');

addpath(genpath('../input_share'));

% show file select modal
[fileNames, videoPath, filterIndex] = uigetfile( {  ...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', ...
    'MultiSelect', 'on', '../input_share');

if ~filterIndex
    set(handles.text9,'String', 'Canceled', 'BackgroundColor', 'red');
    return;
end

% show starting message
set(handles.text14, 'String', 'creating configuration file (csv) ...');
disableAllButtons(handles);
pause(0.01);

tic;

if ischar(fileNames)
    fileCount = 1;
else
    fileCount = size(fileNames,2);
end

% process all selected files
videoFiles = {};
tebleItems = {};

for i = 1:fileCount
    if fileCount > 1
        fileName = fileNames{i};
    else
        fileName = fileNames;
    end
    videoFiles = [videoFiles; fileName];
end
% sort input files
videoFiles = sort(videoFiles);
for n = 1:length(videoFiles)
    row = {videoFiles{n}, videoPath};
    tebleItems = [tebleItems; row];
end

% create config files if possible
status = createConfigFiles(videoPath, videoFiles, handles.template);

time = toc;

% show result message
if status 
    set(handles.text14, 'String',strcat('creating configuration file (csv) ... done!     t =',num2str(time),'s'));
    set(handles.text9,'String','Ready','BackgroundColor','green');
else
    set(handles.text14, 'String',strcat('can not output configuration file (csv)'));
    set(handles.text9,'String','Failed','BackgroundColor','red');
end
checkAllButtons(handles);
% update uitable
handles.uitable2.Data = tebleItems;


% bg--- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    errordlg('please select movies before operation.', 'Error');
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    records = [records; C];
end

% show start text
set(handles.text14, 'String','detecting background ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

addpath(videoPath);

tic % start timer

% background detection for active movie
for data_th = 1:size(records,1)
    % check active flag
    if ~records{data_th, 1}
        continue;
    end

    shuttleVideo = TProVideoReader(videoPath, records{data_th, 2});

    % show detecting message
    set(handles.text14, 'String', ['detecting background for ', shuttleVideo.name]);

    % set output file name
    pathName = strcat(videoPath, shuttleVideo.name, '_tpro/');
    backgroundFileName = strcat(pathName,'/background.png');

    % show startEndDialog or command line auto start
    if handles.autobackground
        startFrame = records{data_th, 4};
        endFrame = records{data_th, 6};
        checkNums = 50;
    else
        [dlg, startFrame, endFrame, checkNums] = startEndDialog({'1', num2str(shuttleVideo.NumberOfFrames), shuttleVideo.name});
        delete(dlg);
    end

    if startFrame < 0
        continue;
    end
    if (endFrame - startFrame + 1) < checkNums
        checkNums = (endFrame - startFrame + 1);
    end

    % initialize output matrix 
    frameImage = TProRead(shuttleVideo,1);
    [m,n,l] = size(frameImage);
    grayImages = uint8(zeros(m,n,checkNums));
    clear frameImage;

    % generate random
    r = randperm(endFrame - startFrame + 1);
    r = r(1:checkNums);

    % show wait dialog
    hWaitBar = waitbar(0,'processing ...','Name',['detecting background for ', shuttleVideo.name],...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitBar,'canceling',0)

    % find appropriate background pixels
    for i = 1 : checkNums
        % Check for Cancel button press
        isCancel = getappdata(hWaitBar, 'canceling');
        if isCancel
            break;
        end
        % Report current estimate in the waitbar's message field
        waitbar(i/checkNums, hWaitBar, [num2str(100*i/checkNums) ' %']);
        pause(0.001);

        frameImage = TProRead(shuttleVideo, r(i) + startFrame - 1);
        grayImage = rgb2gray(frameImage);
        grayImages(:,:,i) = grayImage;
        clear frameImage;
    end
    bgImage = mode(grayImages,3); % this takes much memory and CPU power
    pause(3); % wait for freeing memory

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
    
    % delete dialog bar
    delete(hWaitBar);
    
    if isCancel
        continue;
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
    clear bgImage;
end

% close background image window
if exist('figureWindow','var') && ~isempty(figureWindow) && ishandle(figureWindow)
    pause(2);
    if ishandle(figureWindow) % sometime closed by user
        close(figureWindow);
    end
end

% show end text
time = toc;
set(handles.text14, 'String',strcat('detecting background ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);


% check_threshold--- Executes on button press in pushbutton3
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    errordlg('please select movies before operation.', 'Error');
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    records = [records; C];
end

% show start text
set(handles.text14, 'String','checking detection threashold ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

addpath(videoPath);

% delete last config cache
lastConfigFile = 'etc/last_detect_config.mat';
if exist(lastConfigFile, 'file')
    delete(lastConfigFile);
end

% loop for every movies
for i = 1 : size(records,1)
    % show detection optimizer
    dlg = detectoptimizer({num2str(i)});
    delete(dlg);
    pause(0.1);
end

set(handles.text14, 'String',strcat('checking detection threashold ... done!'))
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);


% detection--- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    errordlg('please select movies before operation.', 'Error');
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    records = [records; C];
end

% show start text
set(handles.text14, 'String','detection ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

addpath(videoPath);

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

%%

% added on 2016-07-28
for data_th = 1:size(records,1)
    % check active flag
    if ~records{data_th, 1}
        continue;
    end
    
    blob_threshold = records{data_th, 8};
    start_frame = records{data_th, 4};
    end_frame = records{data_th, 5};
    frame_steps = records{data_th, 16};
    h = records{data_th, 13};
    sigma = records{data_th, 14};
    area_pixel = records{data_th, 15};
    blobSeparateRate = records{data_th, 17};
    roiNum = records{data_th, 10};

    confPath = [videoPath videoFiles{data_th} '_tpro/'];
    if ~exist([confPath 'multi'], 'dir')
        mkdir([confPath 'multi']);
    end

    shuttleVideo = TProVideoReader(videoPath, records{data_th, 2});

    % ROI
    roi_mask = [];
    roiMasks = {};
    csvFileName = [confPath 'roi.csv'];
    if exist(csvFileName, 'file')
        roiTable = readtable(csvFileName,'ReadVariableNames',false);
        roiFiles = table2cell(roiTable);
    end
    for i=1:roiNum
        if exist(csvFileName, 'file')
            roiFileName = roiFiles{i};
        else
            if i==1 idx=''; else idx=num2str(i); end
            roiFileName = [confPath 'roi' idx '.png'];
        end
        if exist(roiFileName, 'file')
            img = imread(roiFileName);
            roiMasks = [roiMasks, im2double(img)];
            if i==1
                roi_mask = roiMasks{i};
            else
                roi_mask = roi_mask | roiMasks{i};
            end
        end
    end

    bgImageFile = strcat(confPath,'background.png');
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
    for i=1:roiNum
        outputPath = [confPath 'detect_output/' filename '_roi' num2str(i)];
        if ~exist(outputPath, 'dir')
            mkdir(outputPath);
        end
    end
    X = cell(1,length(end_frame-start_frame+1));
    Y = cell(1,length(end_frame-start_frame+1));
    X_update2 = X;
    Y_update2 = Y;
    detection_num = nan(2,end_frame-start_frame+1);
    blobAvgSize = 0;
    
    disp(['start detection : ' shuttleVideo.name]);

%load(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'.mat'));
%load(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'keep_count.mat'));
%X_update2 = X;
%Y_update2 = Y;
%if size(X,2) <= 1
    % show wait dialog
    hWaitBar = waitbar(0,'processing ...','Name',['detecting for ', shuttleVideo.name],...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitBar,'canceling',0)

    keep_i = [];
    keep_count = [];

    i = 1;
    for i_count = start_frame : frame_steps : end_frame
        % Check for Cancel button press
        isCancel = getappdata(hWaitBar, 'canceling');
        if isCancel
            break;
        end
        if i_count == 3781
            a=0;
        end
        % process detection
        img_real = TProRead(shuttleVideo, i_count);
        grayImg = rgb2gray(img_real);
        clear img_real;
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

        img = im2bw(blob_img, blob_threshold);
        blob_img_logical2 = bwareaopen(img, area_pixel);   % delete blob that has area less than 50

        % get blobs from step function
        if blob_center_enable
            [ X_update2{i}, Y_update2{i}, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( blob_img, blob_img_logical2, blob_threshold, blobSeparateRate, i, blobAvgSize);
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
        %{
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
            hold off;
            
            % save figure
            f=getframe;
            filename2 = [sprintf('%05d',i_count) '.png'];
            imwrite(f.cdata, strcat(confPath,'detect_output/',filename,'/',filename2));
            pause(0.001)
        end
        %}
        % graph for detection analysis
        keep_i = [keep_i i];
        keep_count = [keep_count size(X_update2{i},1)];
        % Report current estimate in the waitbar's message field
        rate = (i_count-start_frame+1)/(end_frame-start_frame+1);
        waitbar(rate, hWaitBar, [num2str(int64(100*rate)) ' %']);
        pause(0.001);
        i = i + 1;
    end
%end
    % delete dialog bar
    delete(hWaitBar);
    
    if isCancel
        continue;
    end
    
    img_h = size(grayImg, 1);

    X = X_update2;
    Y = Y_update2;

    % before saving, check standard deviation of fly count
    sd = std(keep_count);
    mcount = mean(keep_count);
    zerocnt = sum(keep_count==0) / length(keep_count);
    maxcnt = max(keep_count);
    mincnt = min(keep_count);
    if 0 < sd && sd < 1 && zerocnt < 0.2 && (maxcnt-mincnt) <= 5
        % fly count should be same every frame.
        % let's fix false positive or false negative
        errorCases = find(abs(keep_count - mcount) > 0.5);
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
    
    % save data
    save(strcat(confPath,'multi/detect_',filename,'.mat'),  'X','Y', 'keep_direction_sorted', 'keep_ecc_sorted', 'keep_angle_sorted', 'keep_areas');
    save(strcat(confPath,'multi/detect_',filename,'keep_count.mat'), 'keep_count');
    
    % save data as text
    for i=1:roiNum
        outputPath = [confPath 'detect_output/' filename '_roi' num2str(i) '/'];
        countFileName = [outputPath shuttleVideo.name '_' filename '_count.txt'];
        write_file_cnt = fopen(countFileName, 'wt');
        write_file_x = fopen([outputPath shuttleVideo.name '_' filename '_x.txt'], 'wt');
        write_file_y = fopen([outputPath shuttleVideo.name '_' filename '_y.txt'], 'wt');

        % cook raw data before saving
        end_row = size(X, 2);
        for row_count = 1:end_row
            fy = X{row_count}(:);
            fx = Y{row_count}(:);
            flyNum = length(fx);
            for j = flyNum:-1:1
                if roiMasks{i}(round(fy(j)),round(fx(j))) <= 0
                    fx(j) = [];
                    fy(j) = [];
                end
            end
            % make save string
            flyNum = length(fx);
            fmtString = generatePrintFormatString(flyNum);

            fprintf(write_file_cnt, '%d\n', flyNum);
            fprintf(write_file_x, fmtString, fx);
            fprintf(write_file_y, fmtString, img_h - fy);
        end

        fclose(write_file_cnt);
        fclose(write_file_x);
        fclose(write_file_y);

        % open text file with notepad (only windows)
        % system(['start notepad ' countFileName]);
        winopen(countFileName);
    end

    set(handles.text9, 'String','100 %'); % done!
    pause(3); % pause 3 sec
end

% show end text
time = toc;
set(handles.text14, 'String',strcat('detection ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);


% tracker--- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)  % tracker
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    errordlg('please select movies before operation.', 'Error');
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    records = [records; C];
end

addpath(videoPath);

% show start text
set(handles.text14, 'String','tracking ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

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

% velocity threshold enable
velocity_thres_enable = 1;

% velocity threshold
velocity_thres = 160;

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

% Kalman only
kalman_only_enable = 0;

% shift the intensity
intensity_shift = -20;

% kalman filter multiple object tracking

% Kalman

dt = 1;  % sampling rate
frame_start = 1; % starting frame
MAX_FLIES = 800; % maxmum number of flies

tproConfig = 'etc/tproconfig.csv';
if exist(tproConfig, 'file')
    tproConfTable = readtable(tproConfig,'ReadRowNames',true);
    values = tproConfTable{'trackingFlyMax',1};
    if size(values,1) > 0
        MAX_FLIES = values(1);
    end
end

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

for data_th = 1:size(records,1)
    if ~records{data_th, 1}
        continue;
    end
    
    reject_dist = records{data_th, 11};
    start_frame = records{data_th, 4};
    end_frame = records{data_th, 5};
    frame_steps = records{data_th, 16};
    roiNum = records{data_th, 10};
    shuttleVideo = TProVideoReader(videoPath, records{data_th, 2});

    % make output folder
    confPath = [videoPath videoFiles{data_th} '_tpro/'];
    if ~exist([confPath 'output'], 'dir')
        mkdir([confPath 'output']);
    end
    filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
    for i=1:roiNum
        outputDataPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
        if ~exist(outputDataPath, 'dir')
            mkdir(outputDataPath);
        end
    end

    % load detection
    load(strcat(confPath,'multi/detect_',filename,'.mat'));

    % load roi
    roiImage = [];
    roiMasks = {};
    csvFileName = [confPath 'roi.csv'];
    if exist(csvFileName, 'file')
        roiTable = readtable(csvFileName,'ReadVariableNames',false);
        roiFiles = table2cell(roiTable);
    end
    for i=1:roiNum
        if exist(csvFileName, 'file')
            roiFileName = roiFiles{i};
        else
            if i==1 idx=''; else idx=num2str(i); end
            roiFileName = [confPath 'roi' idx '.png'];
        end
        if exist(roiFileName, 'file')
            img = imread(roiFileName);
            roiMasks = [roiMasks, im2double(img)];
            if i==1
                roiImage = roiMasks{i};
            else
                roiImage = roiImage | roiMasks{i};
            end
        end
    end

    % initialize result variables
    Q_loc_meas = []; % location measure

    % initialize estimation variables for two dimensions
    Q = [X{frame_start} Y{frame_start} zeros(length(X{frame_start}),1) zeros(length(X{frame_start}),1)]';
    Q_estimate = nan(4, MAX_FLIES);
    Q_estimate(:,1:size(Q,2)) = Q;  % initial location
    direction_track = nan(2, MAX_FLIES); % initialize the direction
    direction_track(:,1:size(keep_direction_sorted{frame_start},2)) = keep_direction_sorted{frame_start};
    ecc_track = nan(1, MAX_FLIES);
    % ecc
    szMax = size(keep_ecc_sorted{frame_start},2);
    if szMax > 0
        ecc_track(:,1:szMax) = keep_ecc_sorted{frame_start};
    end
    % angle
    angle_track = nan(1, MAX_FLIES);
    szMax = size(keep_angle_sorted{frame_start},2);
    if szMax > 0
        angle_track(:,1:szMax) = keep_angle_sorted{frame_start};
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
    img_initial = TProRead(shuttleVideo,1);
    img_h = size(img_initial,1);
    img_w = size(img_initial,2);
    clear img_initial;
    
    % adjust velocity threshold 
    velocity_thres = velocity_thres * (img_h / 1000) * frame_steps; % TODO: how about fps

    disp(['start tracking : ' shuttleVideo.name]);

    % show wait dialog
    hWaitBar = waitbar(0,'processing ...','Name',['tracking for ', shuttleVideo.name],...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitBar,'canceling',0)

    t = 1;
    flyZeroCount = 0;
    for t_count = start_frame:frame_steps:end_frame
        % Check for Cancel button press
        isCancel = getappdata(hWaitBar, 'canceling');
        if isCancel
            break;
        end
        
        % make the given detections matrix
        Q_loc_meas = [X{t} Y{t}];
        direction_meas = keep_direction_sorted{t};

        % major & minor
        ecc_meas = keep_ecc_sorted{t};

        % bodyline angle
        angle_meas = keep_angle_sorted{t};

        % do the kalman filter
        % Predict next state
        nD = size(X{t},1); %set new number of detections
        if nD == 0
            flyZeroCount = flyZeroCount + 1; % counting for reseting assign
        else
            flyZeroCount = 0; % reset
        end

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
                    v1 = direction_track(:,F);
                    v2 = direction_meas(:,asgn(F));
                    if (norm(v1) ~= 0) && (norm(v2) ~= 0)
                        angle_v1_v2 = abs(acosd(dot(v1,v2)/norm(v1)/norm(v2)));  % calculate the angle between two vectors
                        rej(F) = (angle_v1_v2 < 45); % reject if direction is too different
                    end
                    if rej(F) == 1
                        e1 = ecc_track(F);
                        e2 = ecc_meas(asgn(F));
                        ecc_e1_e2 = abs(e1 - e2);
                        rej(F) = (ecc_e1_e2 < 0.3);
                    end
                else
                    rej(F) = 0;
                end
            end


            %
            if size(asgn,2) > 0
                asgn = asgn.*rej;
            end
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
                        if ~isempty(m) && ~isempty(n)
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
                        ecc_track(:,k) = ecc_meas(:,asgn(F));
                        angle_track(:,k) = angle_meas(:,asgn(F));
                    else
                        Q_estimate(:,k) = Q_estimate(:,k) + K * (Q_loc_meas(asgn(F),:)' - C * Q_estimate(:,k)); % same as asgn
                        direction_track(:,k) = direction_meas(:,asgn(F));   % update the direction to be the match's direction
                        ecc_track(:,k) = ecc_meas(:,asgn(F));
                        angle_track(:,k) = angle_meas(:,asgn(F));
                    end
                elseif asgn(F) == 0 % assignment for no assignment
                    if assign_for_noassign
                        y = round(Q_estimate(1,k));
                        x = round(Q_estimate(2,k));
                        if (y > img_h) || (x > img_w) || (y < 1) || (x < 1) || isnan(y) || isnan(x)
                            % if the predict is out of bound then delete
                            Q_estimate(:,k) = NaN;
                        else
                            if ~isempty(roiImage) && roiImage(y,x) == 0
                                % if the predict is out of ROI then stop fly movement
                                Q_estimate(1,k) = y - Q_estimate(3,k);
                                Q_estimate(2,k) = x - Q_estimate(4,k);
                                Q_estimate(3,k) = 0;
                                Q_estimate(4,k) = 0;
                            elseif min(est_dist(k,:)) < min_dist_threshold  % search nearest measurement within min_dist_threshold and op
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
            keep_data{7}(t,F) = ecc_track(1,F);
            keep_data{8}(t,F) = angle_track(1,F);
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
        if exist('asgn', 'var')
            if flyZeroCount >= 3 % zero fly is continuing. so reset assign
                if sum(asgn>0) > 0
                    for k = 1:length(asgn)
                        if asgn(k) == 0
                            continue;
                        end
                        y = round(Q_estimate(1,k));
                        x = round(Q_estimate(2,k));
                        if (y > img_h) || (x > img_w) || (y < 1) || (x < 1) || isnan(y) || isnan(x)
                            % if the predict is out of bound then delete
                            Q_estimate(:,k) = NaN;
                        elseif ~isempty(roiImage) && roiImage(y,x) == 0
                            % if the predict is out of ROI then delete
                            Q_estimate(:,k) = NaN;
                        end
                        asgn(k) = 0;
                    end
                end
            end
            
            no_trk_list = find(asgn==0);
            prev_strk_trks = strk_trks;
            if ~isempty(no_trk_list)
                strk_trks(no_trk_list) = strk_trks(no_trk_list) + 1;
            end
        
            % consecutive strike
            % if the strike is not consecutive then reset
            strk_trks(strk_trks == prev_strk_trks) = 0;

            %if a track has a strike greater than 6, delete the tracking. i.e.
            %make it nan first vid = 3
            bad_trks = find(strk_trks > strike_track_threshold);
            Q_estimate(:,bad_trks) = NaN;
        end

        % output figure
        %{
        if figure_enable
            % create new roi window if it does not exist
            if ~exist('figureWindow','var') || isempty(figureWindow) || ~ishandle(figureWindow)
                if visible_enable
                    figureWindow = figure('name','tracker_savefig_op.m','NumberTitle','off')
                else
                    figureWindow = figure('name','tracker_savefig_op.m','NumberTitle','off','visible','off')
                end
            end

            % change title message
            set(figureWindow, 'name', ['tracking for ', shuttleVideo.name]);
            figure(figureWindow);

            img = TProRead(shuttleVideo,t_count);
            %             img = imread(strcat('./input/',file_list(t).name));
            clf;
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
                    while (isnan(Q_loc_estimateX(t-st,Dc)) || Q_loc_estimateX(t-st,Dc) == 0) && st > 0
                        st = st - 1;
                    end
                    tmX = Q_loc_estimateX(t-st:t,Dc);
                    tmY = Q_loc_estimateY(t-st:t,Dc);
                    plot(tmY,tmX,'.-','markersize',Ms(Sz),'color',c_list(Cz),'linewidth',3)  % rodent 1 instead of Cz
                    if num_text_enable
                        num_txt = strcat(' = ', num2str(Dc));
                        text(tmY(end),tmX(end),num_txt)
                    end
                    %hold on;
                    %                 quiver(Y{t}(11:12),X{t}(11:12),keep_direction_sorted{t}(1,11:12)',keep_direction_sorted{t}(2,11:12)', 'r', 'MaxHeadSize',1, 'LineWidth',1)  %arrow
                    axis off;
                end
            end
            hold off;

            % save figure
            f=getframe;
            filename2 = [sprintf('%05d',t_count) '.png'];
            imwrite(f.cdata,strcat(confPath,'output/',filename,'_pic/',filename2));

            pause(0.001)
        end
        %}
        
        rate = (t_count-start_frame+1)/(end_frame-start_frame+1);
        disp(strcat('processing : ',shuttleVideo.name,'  ',num2str(100*rate), '%', '     t : ', num2str(t)   ));
        % Report current estimate in the waitbar's message field
        waitbar(rate, hWaitBar, [num2str(int64(100*rate)) ' %']);
        pause(0.01);
        t = t + 1;
    end
    
    % delete dialog bar
    delete(hWaitBar);

    if isCancel
        continue;
    end

    % find end of row (some frames has zero flies. so finding NaN is bad)
    end_row = t - 1;

    for j = 1:8
        keep_data{j} = keep_data{j}(:,1:flyNum);
    end
    % inverse the angle upside-down
    % fix angle flip
    keep_data{8} = -keep_data{8};
    keep_data{8} = fixAngleFlip(keep_data{8},1,end_row);

    % save keep_data
    save(strcat(confPath,'multi/track_',filename,'.mat'), 'keep_data');

    % save data as text
    for i=1:roiNum
        outputDataPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
        dataFileName = [outputDataPath shuttleVideo.name '_' filename];
    
        % output text data
        saveTrackingResultText(dataFileName, keep_data, end_row, flyNum, i, img_h, roiMasks);

        % save input data used for generating this result
        record = {records{data_th,:}};
        T = cell2table(record);
        T.Properties.VariableNames = confTable.Properties.VariableNames;
        writetable(T, [dataFileName '_config.csv']);
    end
    
    % show tracking result
    dlg = trackingResultDialog({num2str(data_th)});
    pause(3); % pause 3 sec
end

% show end text
time = toc;
set(handles.text14, 'String',strcat('tracking ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);


function [ blobPointX, blobPointY, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center(blob_img, blob_img_logical, blob_threshold, blobSeparateRate, frameCount, blobAvgSizeIn)

H = vision.BlobAnalysis;
H.MaximumCount = 100;
H.MajorAxisLengthOutputPort = 1;
H.MinorAxisLengthOutputPort = 1;
H.OrientationOutputPort = 1;
H.EccentricityOutputPort = 1;
H.ExtentOutputPort = 1; % just dummy for matlab 2015a runtime. if removing this, referense error happens.

[AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(H, blob_img_logical);
origAreas = AREA;
origCenterPoints = CENTROID;
origBoxes = BBOX;
origMajorAxis = MAJORAXIS;
origMinorAxis = MINORAXIS;
origOrient = ORIENTATION;
origEcc = ECCENTRICITY;

labeledImage = bwlabel(blob_img_logical);   % label the image

area_mean = mean(origAreas);
blobAvgSize = (area_mean + blobAvgSizeIn * (frameCount - 1)) / frameCount;
blob_num = size(origAreas,1);
blobPointX = [];
blobPointY = [];
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
        expect_num = floor(area_ratio); % floor to the nearest integer
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
        blob_th_max = max(max(blob_img_trimmed));
        blob_img_trimmed = blob_img_trimmed / blob_th_max;

        for th_i = 1 : 40
            blob_threshold2 = blob_threshold2 + 0.05;
            if blob_threshold2 > 1
                break;
            end

            blob_img_trimmed2 = im2bw(blob_img_trimmed, blob_threshold2);
            [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(H, blob_img_trimmed2);

            if expect_num <= size(AREA, 1) % change from <= to == 20161015
                x_choose = CENTROID(1:expect_num,2);
                y_choose = CENTROID(1:expect_num,1);    % choose expect_num according to area (large)
                blobPointX = [blobPointX ; x_choose + double(rect(2))];
                blobPointY = [blobPointY ; y_choose + double(rect(1))];
                blobAreas = [blobAreas ; AREA(1:expect_num)];
                blobMajorAxis = [blobMajorAxis ; MAJORAXIS(1:expect_num)];
                blobMinorAxis = [blobMinorAxis ; MINORAXIS(1:expect_num)];
                blobOrient = [blobOrient ; ORIENTATION(1:expect_num)];
                blobEcc = [blobEcc ; ECCENTRICITY(1:expect_num)];
                for j=1 : expect_num
                    pt = CENTROID(j,:) + [double(rect(1)) double(rect(2))];
                    box = BBOX(j,:) + [int32(rect(1)) int32(rect(2)) 0 0];
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
        blobPointX = [blobPointX ; origCenterPoints(i,2)];
        blobPointY = [blobPointY ; origCenterPoints(i,1)];
        blobAreas = [blobAreas ; origAreas(i)];
        blobCenterPoints = [blobCenterPoints ; origCenterPoints(i,:)];
        blobBoxes = [blobBoxes ; origBoxes(i,:)];
        blobMajorAxis = [blobMajorAxis ; origMajorAxis(i)];
        blobMinorAxis = [blobMinorAxis ; origMinorAxis(i)];
        blobOrient = [blobOrient ; origOrient(i)];
        blobEcc = [blobEcc ; origEcc(i)];
    end
end


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
function enableAllButtons(handles)
buttons = [handles.pushbutton1, handles.pushbutton2, handles.pushbutton3, handles.pushbutton4, ...
    handles.pushbutton5, handles.pushbutton6, handles.pushbutton8, handles.pushbutton10, ...
    handles.pushbutton11, handles.pushbutton12];
enableButtons(buttons);

%%
function enableButtons(buttons)
max = size(buttons, 2);
for i = 1 : max
    set(buttons(i), 'Enable', 'on');
end

%%
function disableAllButtons(handles)
buttons = [handles.pushbutton1, handles.pushbutton2, handles.pushbutton3, handles.pushbutton4, ...
    handles.pushbutton5, handles.pushbutton6, handles.pushbutton8, handles.pushbutton10, ...
    handles.pushbutton11, handles.pushbutton12];
disableButtons(buttons);

%%
function disableButtons(buttons)
max = size(buttons, 2);
for i = 1 : max
    set(buttons(i), 'Enable', 'off');
end

%%
function checkAllButtons(handles)
% first disable all buttons
disableAllButtons(handles)

% button1 is always on
set(handles.pushbutton1, 'Enable', 'on');

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    return; % no input files
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

videoFileNum = size(videoFiles,1);
if videoFileNum == 0
    return; % no video files
end

confFileName = [videoPath videoFiles{1} '_tpro/input_video_control.csv'];
if ~exist(confFileName, 'file')
    return; % no config file
end
confTable = readtable(confFileName);
record = table2cell(confTable);
start_frame = record{4};
end_frame = record{5};

% background button
set(handles.pushbutton2, 'Enable', 'on');

confPath = [videoPath videoFiles{1} '_tpro/'];
backgroundFileName = [confPath 'background.png'];
if ~exist(backgroundFileName, 'file')
    return; % no background image file
end

% roi button
set(handles.pushbutton6, 'Enable', 'on');

roiFileName = [confPath 'roi.png'];
csvFileName = [confPath 'roi.csv'];
if ~exist(roiFileName, 'file') && ~exist(csvFileName, 'file')
    return; % no roi image file
end

% threshold check button
set(handles.pushbutton3, 'Enable', 'on');
% detect button
set(handles.pushbutton4, 'Enable', 'on');
% detect + track button
set(handles.pushbutton8, 'Enable', 'on');

filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
keepFileName = [confPath 'multi/detect_' filename 'keep_count.mat'];
if ~exist(keepFileName, 'file')
    return; % no keep count file
end

% track button
set(handles.pushbutton5, 'Enable', 'on');
% show detection result button
set(handles.pushbutton12, 'Enable', 'on');

trackFileName = [confPath 'multi/track_' filename '.mat'];
if ~exist(trackFileName, 'file')
    return; % no tracking file
end

% show tracking result button
set(handles.pushbutton10, 'Enable', 'on');
% show annotation button
set(handles.pushbutton11, 'Enable', 'on');


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

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    errordlg('please select movies before operation.', 'Error');
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    records = [records; C];
end

% show start text
set(handles.text14, 'String','selecting "Region of Interest" ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

addpath(videoPath);

% select roi for every movie
for data_th = 1:size(records,1)
    if records{data_th, 1}
        shuttleVideo = TProVideoReader(videoPath, records{data_th, 2});
        frameImage = TProRead(shuttleVideo,1);
        grayImage = rgb2gray(frameImage);

        % show selectRoiWayDialog
        roiFileName = [videoPath shuttleVideo.name '_tpro/roi.png'];
        csvFileName = [videoPath shuttleVideo.name '_tpro/roi.csv'];
        if exist(csvFileName, 'file')
            selectedType = 2;
        elseif exist(roiFileName, 'file')
            selectedType = 1;
        else
            [dlg, selectedType] = selectRoiWayDialog({});
            delete(dlg);

            if selectedType < 0
                continue;
            end
        end

        % select fixed ROI image files or create new ROI images
        if selectedType == 2
            while true
                [i, figureWindow] = selectRoiFiles(csvFileName, shuttleVideo, grayImage);
                figureWindow = [];
                if i>=0 break; end
            end
        else
            [i, figureWindow] = createRoiImages(videoPath, shuttleVideo, frameImage, grayImage, records{data_th, 10});
        end
        clear frameImage;

        % update ROI param in configuration
        record = {records{data_th,:}};
        record{10} = i;
        confFileName = [videoPath videoFiles{data_th} '_tpro/input_video_control.csv'];
        status = saveInputControlFile(confFileName, record);
        if ~status
            errordlg(['failed to save a configuration file : ' confFileName], 'Error');
        end
    end
end

% close background image window
if exist('figureWindow','var') && ~isempty(figureWindow) && ishandle(figureWindow)
    pause(2);
    close(figureWindow);
end

% show end text
set(handles.text14, 'String','selecting "Region of Interest" ... done!')
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);





% --- Detect + Track
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pushbutton4_Callback(hObject, eventdata, handles)
pushbutton5_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    errordlg('please select movies before operation.', 'Error');
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    records = [records; C];
end

% loop for every movies
for i = 1 : size(records,1)
    % show tracking result
    dlg = trackingResultDialog({num2str(i)});
    pause(0.1);
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    errordlg('please select movies before operation.', 'Error');
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    records = [records; C];
end

% loop for every movies
for i = 1 : size(records,1)
    % show tracking result
    dlg = annotationDialog({num2str(i)});
    pause(0.1);
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputListFile = 'etc/input_videos.mat';
if ~exist(inputListFile, 'file')
    errordlg('please select movies before operation.', 'Error');
    return;
end
vl = load(inputListFile);
videoPath = vl.videoPath;
videoFiles = vl.videoFiles;

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPath videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    records = [records; C];
end

% loop for every movies
for i = 1 : size(records,1)
    % show tracking result
    dlg = detectionResultDialog({num2str(i)});
    pause(0.1);
end
