function varargout = trackingResultDialog(varargin)
    % TRACKINGRESULTDIALOG MATLAB code for trackingResultDialog.fig
    %      TRACKINGRESULTDIALOG, by itself, creates a new TRACKINGRESULTDIALOG or raises the existing
    %      singleton*.
    %
    %      H = TRACKINGRESULTDIALOG returns the handle to a new TRACKINGRESULTDIALOG or the handle to
    %      the existing singleton*.
    %
    %      TRACKINGRESULTDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in TRACKINGRESULTDIALOG.M with the given input arguments.
    %
    %      TRACKINGRESULTDIALOG('Property','Value',...) creates a new TRACKINGRESULTDIALOG or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before trackingResultDialog_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to trackingResultDialog_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help trackingResultDialog

    % Last Modified by GUIDE v2.5 29-Dec-2017 00:10:48

    % Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @trackingResultDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @trackingResultDialog_OutputFcn, ...
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
end


% --- Executes just before trackingResultDialog is made visible.
function trackingResultDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to trackingResultDialog (see VARARGIN)

    % Choose default command line output for trackingResultDialog
    handles.output = hObject;
    guidata(hObject, handles);

    % load environment value
    if size(varargin, 1) > 0
        rowNum = int64(str2num(char(varargin{1}(1))));
        handles.isArgin = true;
    else
        rowNum = 1;
        handles.isArgin = false;
    end
    if isempty(rowNum), rowNum = 1; end

    % load video list
    inputListFile = 'etc/input_videos.mat';
    if ~exist(inputListFile, 'file')
        errordlg('please select movies before operation.', 'Error');
        return;
    end
    vl = load(inputListFile);
    videoPath = vl.videoPath;
    videoFiles = vl.videoFiles;

    % load configuration files
    confFileName = [videoPath videoFiles{rowNum} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    records = table2cell(confTable);
    
    % make output folder
    confPath = [videoPath videoFiles{rowNum} '_tpro/'];
    filename = [sprintf('%05d',records{4}) '_' sprintf('%05d',records{5})];

    % load detection & tracking
    load(strcat(confPath,'multi/detect_',filename,'.mat'));
    load(strcat(confPath,'multi/detect_',filename,'keep_count.mat'));
    load(strcat(confPath,'multi/track_',filename,'.mat'));

    % initialize GUI
    sharedInst = struct; % allocate shared instance
    sharedInst.videoPath = videoPath;
    sharedInst.confPath = [videoPath videoFiles{rowNum} '_tpro/'];
    sharedInst.confFileName = confFileName;
    sharedInst.shuttleVideo = TProVideoReader(videoPath, records{2}, records{6});
    sharedInst.rowNum = rowNum;
    sharedInst.startFrame = records{4};
    sharedInst.endFrame = records{5};
    sharedInst.maxFrame = sharedInst.shuttleVideo.NumberOfFrames;
    sharedInst.frameSteps = records{16};
    sharedInst.fpsNum = records{7};
    sharedInst.frameNum = sharedInst.startFrame;
    sharedInst.stepTime = 0.03;
    sharedInst.showDetectResult = 1;
    sharedInst.showNumber = 1;
    sharedInst.listMode = 1; % all
    sharedInst.listFly = 0;
    sharedInst.lineMode = 2; % tail
    sharedInst.lineLength = 19;
    sharedInst.backMode = 1; % movie
    sharedInst.mmPerPixel = records{9};
    sharedInst.roiNum = records{10};
    sharedInst.isInvert = records{12};
    sharedInst.currentROI = 0;
    sharedInst.axesType1 = 'count';
    sharedInst.isModified = false;
    sharedInst.editMode = 1; % select / add mode

    % fix old parameters
    if sharedInst.mmPerPixel <= 0
        sharedInst.mmPerPixel = 0.1;
    end
    sharedInst.contMin = getVideoConfigValue(records, 29, 0);
    sharedInst.contMax = getVideoConfigValue(records, 30, 0);
    sharedInst.sharpRadius = getVideoConfigValue(records, 31, 0);
    sharedInst.sharpAmount = getVideoConfigValue(records, 32, 0);

    sharedInst.X = X;
    sharedInst.Y = Y;
    sharedInst.keep_direction_sorted = keep_direction_sorted;
    sharedInst.keep_ecc_sorted = keep_ecc_sorted;
    sharedInst.keep_angle_sorted = keep_angle_sorted;
    sharedInst.keep_areas = keep_areas;
    sharedInst.keep_data = keep_data;
    sharedInst.selectX = {};
    sharedInst.selectY = {};
    sharedInst.selectFrame = sharedInst.frameNum;
    sharedInst.longAxesDrag = 0;
    sharedInst.shiftAxes = 0;
    sharedInst.startPoint = [];
    
    % load edit log
    histFile = [confPath 'multi/trackingEditHistory.mat'];
    if exist(histFile, 'file')
        cf = load(histFile, 'editHistory');
        sharedInst.editHistory = cf.editHistory;
        set(handles.Untitled_19, 'Enable', 'on');
    else
        sharedInst.editHistory = {};
        set(handles.Untitled_19, 'Enable', 'off');
    end
    sharedInst.redoHistory = {};
    set(handles.Untitled_26, 'Enable', 'off');

    sharedInst.originalImage = [];

    set(handles.text4, 'String', sharedInst.shuttleVideo.NumberOfFrames);
    set(handles.text6, 'String', sharedInst.shuttleVideo.FrameRate);
    set(handles.slider1, 'Min', 1, 'Max', sharedInst.maxFrame, 'Value', sharedInst.startFrame);
    set(handles.edit1, 'String', sharedInst.frameNum);
    set(handles.checkbox1, 'Value', sharedInst.showNumber);
    set(handles.checkbox2, 'Value', sharedInst.showDetectResult);

    set(handles.pushbutton3, 'Enable', 'off')
    set(handles.pushbutton15, 'Enable', 'off')
    set(handles.popupmenu5, 'Enable', 'off')
    set(handles.edit3, 'Enable', 'on')
    set(handles.axes5, 'visible', 'off')
    
    set(hObject, 'name', ['Tracking result for ', sharedInst.shuttleVideo.name]); % set window title

    % load mat or config 
    sharedInst.mean_blobmajor = 3.56 / sharedInst.mmPerPixel;
    sharedInst.mean_blobminor = 1.07 / sharedInst.mmPerPixel;
    if exist('keep_mean_blobmajor', 'var')
        sharedInst.mean_blobmajor = nanmean(keep_mean_blobmajor);
        sharedInst.mean_blobminor = nanmean(keep_mean_blobminor);
    else
        sharedInst.mean_blobmajor = readTproConfig('meanBlobMajor', 3.56) / sharedInst.mmPerPixel;
        sharedInst.mean_blobminor = readTproConfig('meanBlobMinor', 1.07) / sharedInst.mmPerPixel;
    end

    % load config 
    sharedInst.exportDcd = readTproConfig('exportDcd', 0);
    sharedInst.exportMd = readTproConfig('exportMinDistance', 0);
    sharedInst.ewdRadius = readTproConfig('ewdRadius', 5);
    sharedInst.pdbscanRadius = readTproConfig('pdbscanRadius', 5);
    sharedInst.dcdRadius = readTproConfig('dcdRadius', 7.5);
    sharedInst.dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);
    sharedInst.nnAlgorithm = readTproConfig('nnAlgorithm', 'single'); %'single', 'average', 'ward';
    sharedInst.nnHeight = readTproConfig('nnHeight', 5);

    % calc color map for ewd
    sharedInst.ewdColors = expandColor({[0 0 .45], [0 0 1], [1 0 0], [1 .7 .7]}, 100);

    % set fly list box
    flyNum = size(keep_data{1}, 2);
    listItem = [];
    for i = 1:flyNum
        listItem = [listItem;{i}];
    end
    set(handles.popupmenu5,'String',listItem);

    % fly image box size for deep learning
    sharedInst.meanBlobmajor = readTproConfig('meanBlobMajor', 3.56);
    sharedInst.boxSize = findFlyImageBoxSize(sharedInst.meanBlobmajor, sharedInst.mmPerPixel);

    % load background image
    videoName = sharedInst.shuttleVideo.name;
    bgImageFile = strcat(sharedInst.confPath,'background.png');
    if exist(bgImageFile, 'file')
        bgImage = imread(bgImageFile);
        if size(size(bgImage),2) == 2 % one plane background
            bgImage(:,:,2) = bgImage(:,:,1);
            bgImage(:,:,3) = bgImage(:,:,1);
        end
        bgImage = rgb2gray(bgImage);
        sharedInst.bgImage = bgImage;
        sharedInst.bgImageDouble = single(bgImage);
        sharedInst.bgImageMean = mean(mean(bgImage));
        sharedInst.img_h = size(bgImage,1);
        sharedInst.img_w = size(bgImage,2);
    else
        sharedInst.bgImage = [];
        sharedInst.bgImageDouble = [];
        sharedInst.bgImageMean = [];
        sharedInst.img_h = 1024;
        sharedInst.img_w = 1024;
    end

    % load roi image file
    roiMaskImage = [];
    roiMasks = {};
    csvFileName = [sharedInst.confPath 'roi.csv'];
    if exist(csvFileName, 'file')
        roiTable = readtable(csvFileName,'ReadVariableNames',false);
        roiFiles = table2cell(roiTable);
    end
    for i=1:sharedInst.roiNum
        if exist(csvFileName, 'file')
            roiFileName = roiFiles{i};
        else
            if i==1 idx=''; else idx=num2str(i); end
            roiFileName = [sharedInst.confPath 'roi' idx '.png'];
        end
        if exist(roiFileName, 'file')
            img = imread(roiFileName);
            roiMasks = [roiMasks, im2single(img)];
            if i==1
                roiMaskImage = roiMasks{i};
            else
                roiMaskImage = roiMaskImage | roiMasks{i};
            end
        end
    end
    sharedInst.roiMaskImage = roiMaskImage;
    sharedInst.roiMasks = roiMasks;

    % set ROI list box
    listItem = {'all'};
    for i = 1:sharedInst.roiNum
        listItem = [listItem;{['ROI-' num2str(i)]}];
    end
    set(handles.popupmenu7,'String',listItem);

    % count each ROI fly number
    countFliesEachROI(handles, X, Y, sharedInst.roiNum, roiMasks, roiMaskImage);

    % calc velocity and etc.
    if exist('assignCost','var')
        addResult2Axes(handles, assignCost, 'assignCost', handles.popupmenu8);
    end
    addResult2Axes(handles, sharedInst.keep_data{2}, 'x', handles.popupmenu8);
    addResult2Axes(handles, sharedInst.keep_data{1}, 'y', handles.popupmenu8);

    result = calcVxy(keep_data{3}, keep_data{4}) * sharedInst.fpsNum * sharedInst.mmPerPixel;
    cname = 'velocity';
    addResult2Axes(handles, result, cname, handles.popupmenu8);

    % load last time data
    resultNames = {'aggr_voronoi_result', 'aggr_ewd_result', 'aggr_pdbscan_result', 'aggr_md_result', 'aggr_hwmd_result', 'aggr_grid_result', ...
        'aggr_ewd_result_tracking', 'nn_cluster_result_tracking', 'aggr_dcd_result', 'aggr_dcd_result_tracking'};
    for i=1:length(resultNames)
        fname = [sharedInst.confPath 'multi/' resultNames{i} '.mat'];
        if exist(fname, 'file')
            load(fname);
            setappdata(handles.figure1,resultNames{i},result);
            addResult2Axes(handles, result, resultNames{i}, handles.popupmenu8);
        end
    end
    set(handles.popupmenu8,'Value',1);

    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    setappdata(handles.figure1,'draglock',0);
    guidata(hObject, handles);  % Update handles structure

    % show long params
    showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI, sharedInst.listFly);

    % show first frame
    showMainAxesRectangle(handles.axes6, handles, []);
    if ~isempty(sharedInst.bgImage)
        imshow(sharedInst.bgImage);
        cla;
    end
    showFrameInAxes(hObject, handles, sharedInst.startFrame);

    % UIWAIT makes startEndDialog wait for user response (see UIRESUME)
    %uiwait(handles.figure1); % wait for finishing dialog
end


% --- Outputs from this function are returned to the command line.
function varargout = trackingResultDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;    
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.isModified
        selection = questdlg('Do you save tracking data before closing window?',...
                             'Confirmation',...
                             'Yes','No','Cancel','Yes');
        switch selection
        case 'Cancel'
            return;
        case 'Yes'
            pushbutton15_Callback(handles.pushbutton15, eventdata, handles);
        case 'No'
            % nothing todo
        end
    end

    delete(hObject);
end

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
    %	Key: name of the key that was pressed, in lower case
    %	Character: character interpretation of the key(s) that was pressed
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    % shift + key
    if size(eventdata.Modifier,2) > 0 && strcmp(eventdata.Modifier{:}, 'shift')
        switch eventdata.Key
        case 'rightarrow'
        case 'leftarrow'
        case 's'
            % swap trajectory at current frame
            ids = getIdsFromPoints(sharedInst.selectX, sharedInst.selectY, handles);
            if length(ids) ~= 2
                text(6, 30, 'can not swap trajectories. please select 2 points.', 'Color',[1 .2 .2])
                return;
            end
            sharedInst.selectX = {};
            sharedInst.selectY = {};
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            swapTrackingData(ids(1), ids(2), sharedInst.frameNum, sharedInst.frameNum, true, handles);
            showFrameInAxes(hObject, handles, sharedInst.frameNum);
        end
        return;
    end
    % control + key
    if size(eventdata.Modifier,2) > 0 && strcmp(eventdata.Modifier{:}, 'control')
        switch eventdata.Key
        case 'rightarrow'
            if sharedInst.frameNum < sharedInst.maxFrame
                pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
                set(handles.slider1, 'value', sharedInst.frameNum + sharedInst.frameSteps*10);
                slider1_Callback(handles.slider1, eventdata, handles)
            end
        case 'leftarrow'
            if sharedInst.frameNum > 1
                pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
                set(handles.slider1, 'value', sharedInst.frameNum - sharedInst.frameSteps*10);
                slider1_Callback(handles.slider1, eventdata, handles)
            end
        case 'uparrow'
            if sharedInst.frameNum < sharedInst.maxFrame
                pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
                set(handles.slider1, 'value', sharedInst.frameNum + sharedInst.frameSteps*100);
                slider1_Callback(handles.slider1, eventdata, handles)
            end
        case 'downarrow'
            if sharedInst.frameNum > 1
                pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
                set(handles.slider1, 'value', sharedInst.frameNum - sharedInst.frameSteps*100);
                slider1_Callback(handles.slider1, eventdata, handles)
            end
        end
        return;
    end
    % just key
    switch eventdata.Key
    case 'rightarrow'
        pushbutton4_Callback(hObject, eventdata, handles);
    case 'leftarrow'
        pushbutton5_Callback(hObject, eventdata, handles);
    case 'uparrow'
        pushbutton2_Callback(hObject, eventdata, handles);
    case 'downarrow'
        pushbutton3_Callback(hObject, eventdata, handles);
    case 's'
        % swap trajectory after whole frames
        ids = getIdsFromPoints(sharedInst.selectX, sharedInst.selectY, handles);
        if length(ids) ~= 2
            text(6, 30, 'can not swap trajectories. please select 2 points.', 'Color',[1 .2 .2])
            return;
        end
        sharedInst.selectX = {};
        sharedInst.selectY = {};
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
        swapTrackingData(ids(1), ids(2), sharedInst.frameNum, sharedInst.endFrame, true, handles);
        showFrameInAxes(hObject, handles, sharedInst.frameNum);
    case 'delete'
        frameNum = sharedInst.frameNum;
        if ~isempty(sharedInst.selectX)
            ids = getIdsFromPoints(sharedInst.selectX, sharedInst.selectY, handles);
            for i=1:length(ids)
                moveTrackingPoint(ids(i), frameNum, NaN, NaN, true, handles);
            end
        elseif sharedInst.editMode == 1 && sharedInst.listMode == 2
            % move point
            moveTrackingPoint(sharedInst.listFly, frameNum, NaN, NaN, true, handles);
        end
        sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
        sharedInst.selectX = {};
        sharedInst.selectY = {};
        setappdata(handles.figure1,'x',sharedInst.keep_data{2}); % update shared
        setappdata(handles.figure1,'y',sharedInst.keep_data{1}); % update shared
        showFrameInAxes(hObject, handles, sharedInst.frameNum);        
    case 'escape'
        sharedInst.editMode = 1;
        sharedInst.selectX = {};
        sharedInst.selectY = {};
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
        showFrameInAxes(hObject, handles, sharedInst.frameNum);
    end
end

function ids = getIdsFromPoints(X, Y, handles)
    ids = [];
    if isempty(X)
        return;
    end
    sz = length(X{1});
    if sz == 0
        return;
    end
    if sz ~= length(Y{1})
        return;
    end

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    selPts = [X{1}(:) Y{1}(:)];
    estPts = [sharedInst.keep_data{1}(t,:)' sharedInst.keep_data{2}(t,:)'];
    dist = pdist([selPts; estPts]);
    dist1 = squareform(dist); %make square
    dist2 = dist1(1:sz, (sz+1):end);
    for i=1:sz
        [m, idx] = min(dist2(i,:));
        ids = [ids, idx];
    end
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
%    figure1_WindowKeyPressFcn(hObject, eventdata, handles);
end

function figure1_KeyReleaseFcn(hObject, eventdata, handles)
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if gca == handles.axes1
        cp = get(gca,'CurrentPoint');
        frameNum = sharedInst.frameNum;

        % select point
        if sharedInst.editMode == 1 && sharedInst.listMode == 1
            unselected = false;
            selected = false;
            A = [cp(1,2), cp(1,1)];
            sframe = frameNum;
            slen = 1;
            start_t = round((sframe - sharedInst.startFrame) / sharedInst.frameSteps) + 1;

            if ~isempty(sharedInst.selectX)
                for i=1:slen
                    B = [sharedInst.selectX{i}, sharedInst.selectY{i}];
                    if ~isempty(B)
                        distances = sqrt(sum(bsxfun(@minus, B, A).^2,2));
                        [minDist,k] = min(distances);
                        if minDist < 9
                            sharedInst.selectX{i}(k) = [];
                            sharedInst.selectY{i}(k) = [];
                            unselected = true;
                        end
                    end
                end
            end
            if ~unselected
                if isempty(sharedInst.selectX)
                    sharedInst.selectX = cell(slen,1);
                    sharedInst.selectY = cell(slen,1);
                end
                for i=1:slen
                    t = start_t+(i-1);
                    B = [sharedInst.keep_data{1}(t,:)' sharedInst.keep_data{2}(t,:)'];
                    if ~isempty(B)
                        distances = sqrt(sum(bsxfun(@minus, B, A).^2,2));
                        [minDist,k] = min(distances);
                        if minDist < 9
                            sharedInst.selectX{i} = [sharedInst.selectX{i}(:); B(k,1)];
                            sharedInst.selectY{i} = [sharedInst.selectY{i}(:); B(k,2)];
                            selected = true;
                        end
                    end
                end
            end
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            % unselect all point
            if ~unselected && ~selected
                sharedInst.selectX = {};
                sharedInst.selectY = {};
                sharedInst.startPoint = A;
                setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            end
        elseif sharedInst.editMode == 1 && sharedInst.listMode == 2
            y = cp(1,2);
            x = cp(1,1);
            if x > 0 && x < sharedInst.img_w && y > 0 && y < sharedInst.img_h
                % move point
                moveTrackingPoint(sharedInst.listFly, frameNum, y, x, true, handles);

                sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
                setappdata(handles.figure1,'x',sharedInst.keep_data{2}); % update shared
                setappdata(handles.figure1,'y',sharedInst.keep_data{1}); % update shared
            end
        end
        % show frame
        showFrameInAxes(hObject, handles, sharedInst.frameNum);

    elseif gca == handles.axes2 || gca == handles.axes3
        cp = get(gca,'CurrentPoint');
        sharedInst.selectX = {};
        sharedInst.selectY = {};
        sharedInst.selectFrame = round(sharedInst.startFrame + cp(1));
        sharedInst.longAxesDrag = sharedInst.selectFrame;
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

        setappdata(handles.figure1,'draglock',1);
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.longAxesDrag);
        slider1_Callback(handles.slider1, [], handles)
        setappdata(handles.figure1,'draglock',0);
    end
end

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if ~isempty(sharedInst.startPoint)
        A = sharedInst.startPoint;
        cp = get(handles.axes1,'CurrentPoint');
        x = min(A(2), cp(1,1));
        y = min(A(1), cp(1,2));
        rect = [x, y, abs(cp(1,1)-A(2)), abs(cp(1,2)-A(1))];
        showMainAxesRectangle(handles.axes6, handles, rect);
    end
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if ~isempty(sharedInst.startPoint)
        % calc points
        A = sharedInst.startPoint;
        cp = get(handles.axes1,'CurrentPoint');
        xmin = min(A(2), cp(1,1));
        xmax = max(A(2), cp(1,1));
        ymin = min(A(1), cp(1,2));
        ymax = max(A(1), cp(1,2));

        % select point
        frameNum = sharedInst.frameNum;
        sframe = min(frameNum,sharedInst.selectFrame);
        eframe = max(frameNum,sharedInst.selectFrame);
        slen = eframe - sframe + 1;
        start_t = round((sframe - sharedInst.startFrame) / sharedInst.frameSteps) + 1;

        if isempty(sharedInst.selectX)
            sharedInst.selectX = cell(slen,1);
            sharedInst.selectY = cell(slen,1);
        end
        for i=1:slen
            t = start_t+(i-1);
            B = [sharedInst.keep_data{1}(t,:)' sharedInst.keep_data{2}(t,:)'];
            for k=1:size(B,1)
                if xmax > B(k,2) && B(k,2) > xmin && ymax > B(k,1) && B(k,1) > ymin
                    sharedInst.selectX{i} = [sharedInst.selectX{i}(:); B(k,1)];
                    sharedInst.selectY{i} = [sharedInst.selectY{i}(:); B(k,2)];
                end
            end
        end
        sharedInst.startPoint = [];
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
        % show plots
        pause(0.1);
        showMainAxesRectangle(handles.axes6, handles, []);
        showFrameInAxes(hObject, handles, sharedInst.frameNum);
    end
end

%%
function edit1_Callback(hObject, eventdata, handles)
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    frame = str2double(get(hObject,'String'));
    set(handles.slider1, 'value', frame);
    slider1_Callback(handles.slider1, eventdata, handles)
end

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
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    frameNum = int64(get(hObject,'Value'));
    sharedInst.frameNum = frameNum + rem(frameNum-sharedInst.startFrame, sharedInst.frameSteps);
    if ~isempty(eventdata)
        sharedInst.selectFrame = sharedInst.frameNum;
    end
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    if sharedInst.selectFrame == sharedInst.frameNum
        set(handles.edit1, 'String', sharedInst.frameNum);
    else
        set(handles.edit1, 'String', [num2str(sharedInst.selectFrame) '-' num2str(sharedInst.frameNum)]);
    end
    guidata(hObject, handles);    % Update handles structure
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure');
    figure1_CloseRequestFcn(hFig, eventdata, handles);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    if getappdata(handles.figure1,'playing') > 0
        return; % already playing
    end

    setappdata(handles.figure1,'playing',1);
    set(handles.pushbutton2, 'Enable', 'off')
    set(handles.pushbutton3, 'Enable', 'on')
    set(handles.popupmenu2, 'Enable', 'off')
    
    playing = 1;
    frameNum = sharedInst.frameNum;
    while playing
        if frameNum < sharedInst.maxFrame
            frameNum = frameNum + sharedInst.frameSteps;
            
            set(handles.slider1, 'value', frameNum);
            slider1_Callback(handles.slider1, eventdata, handles)
            pause(sharedInst.stepTime);
        else
            pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        end
        playing = getappdata(handles.figure1,'playing');
    end
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    setappdata(handles.figure1,'playing',0);
    set(handles.pushbutton2, 'Enable', 'on')
    set(handles.pushbutton3, 'Enable', 'off')
    set(handles.popupmenu2, 'Enable', 'on')
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.frameNum < sharedInst.maxFrame
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.frameNum + sharedInst.frameSteps);
        slider1_Callback(handles.slider1, eventdata, handles)
    end
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.frameNum > 1
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.frameNum - sharedInst.frameSteps);
        slider1_Callback(handles.slider1, eventdata, handles)
    end
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.stepTime = str2num(contents{get(hObject,'Value')});
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
end

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
    % hObject    handle to checkbox1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.showNumber = get(hObject,'Value');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles,sharedInst.frameNum);
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    % hObject    handle to checkbox2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.showDetectResult = get(hObject,'Value');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.listMode = 1;
    sharedInst.listFly = 0;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.popupmenu5, 'Enable', 'off')

    showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI, sharedInst.listFly);
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.listMode = 2;
    contents = cellstr(get(handles.popupmenu5,'String'));
    sharedInst.listFly = str2num(contents{get(handles.popupmenu5,'Value')});
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.popupmenu5, 'Enable', 'on')

    showLongAxesMulti(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI, sharedInst.listFly);
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.lineMode = 1;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.edit3, 'Enable', 'off')
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.lineMode = 2;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.edit3, 'Enable', 'on')
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

function edit3_Callback(hObject, eventdata, handles)
    % hObject    handle to edit3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    num = str2num(get(handles.edit3, 'String'));
    if isempty(num)
        set(handles.edit3, 'String', sharedInst.lineLength);
    else
        if num < 0 || num > sharedInst.endFrame
            set(handles.edit1, 'String', sharedInst.lineLength);
        else
            sharedInst.lineLength = num;
        end
    end
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
end

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
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.listFly = str2num(contents{get(hObject,'Value')});
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    showLongAxesMulti(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI, sharedInst.listFly);
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.backMode = get(hObject,'Value');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton14 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    setappdata(handles.figure1,'playing',1);
    set(handles.pushbutton1, 'Enable', 'off')
    set(handles.pushbutton2, 'Enable', 'off')
    set(handles.pushbutton3, 'Enable', 'on')
    set(handles.pushbutton4, 'Enable', 'off')
    set(handles.pushbutton5, 'Enable', 'off')
    set(handles.popupmenu2, 'Enable', 'off')
    set(handles.pushbutton14, 'Enable', 'off')
    set(handles.pushbutton15, 'Enable', 'off')
    
    % make output folder
    confPath = sharedInst.confPath;
    if ~exist([confPath 'movie'], 'dir')
        mkdir([confPath 'movie']);
    end

    addpath([confPath 'movie']);
    
    videoName = sharedInst.shuttleVideo.name;
    filename = [videoName sprintf('_%05d',sharedInst.startFrame) sprintf('_%05d',sharedInst.endFrame) '.avi'];
    outputVideo = VideoWriter(fullfile([confPath 'movie'], filename));
    outputVideo.FrameRate = sharedInst.fpsNum / sharedInst.frameSteps;

    % make video
    open(outputVideo)

    for frameNum = sharedInst.startFrame:sharedInst.frameSteps:sharedInst.endFrame
        set(handles.slider1, 'value', frameNum);
        slider1_Callback(handles.slider1, eventdata, handles)

        % Check for Cancel button press
        playing = getappdata(handles.figure1,'playing');
        if playing == 0
            break;
        end
        
        % write video
        f=getframe;
        writeVideo(outputVideo, f.cdata);

        % Report current estimate in the waitbar's message field
        % rate = (frameNum - sharedInst.startFrame)/(sharedInst.endFrame - sharedInst.startFrame);
        pause(0.03);
    end
    close(outputVideo)
    
    set(handles.pushbutton1, 'Enable', 'on')
    set(handles.pushbutton2, 'Enable', 'on')
    set(handles.pushbutton4, 'Enable', 'on')
    set(handles.pushbutton5, 'Enable', 'on')
    set(handles.popupmenu2, 'Enable', 'on')
    set(handles.pushbutton14, 'Enable', 'on')
    if sharedInst.isModified
        set(handles.pushbutton15, 'Enable', 'on')
    else
        set(handles.pushbutton15, 'Enable', 'off')
    end
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton15 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    Untitled_24_Callback(hObject, eventdata, handles);
    Untitled_25_Callback(hObject, eventdata, handles);
end

% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu7 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String')); % returns popupmenu7 contents as cell array
    item = contents{get(hObject,'Value')}; % returns selected item from popupmenu7

    if strcmp(item,'all')
        currentROI = 0;
    else
        currentROI = str2num(char(strrep({item},'ROI-','')));
    end
    sharedInst.currentROI = currentROI;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu7 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.axesType1 = contents{get(hObject,'Value')};
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    if strcmp(sharedInst.axesType1, 'nn_cluster_result_tracking')
        sharedInst.axesType1 = 'aggr_dcd_result_tracking';
    end

    showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI, sharedInst.listFly);
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% menu

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [fileName, path, filterIndex] = uigetfile( {  ...
        '*.csv',  'CSV File (*.csv)'}, ...
        'Pick a file', ...
        'MultiSelect', 'off', '.');

    if ~filterIndex
        return;
    end

    try
        csvTable = readtable([path fileName],'ReadVariableNames',false);
        records = table2cell(csvTable);
        result = cell2mat(records);
    catch e
        errordlg('please select a csv file.', 'Error');
        return;
    end

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % add result to axes & show in axes
    cname = fileName(1:(end-4));
    addResult2Axes(handles, result, cname, handles.popupmenu8);
    popupmenu8_Callback(handles.popupmenu8, eventdata, handles)

    h = msgbox({'import csv file successfully!'});
end

% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [fileName, path, filterIndex] = uiputfile( {  ...
        '*.csv',  'CSV File (*.csv)'}, ...
        'Export as', '.');

    if ~filterIndex
        return;
    end

    outputFileName = [path fileName];
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    cname = [sharedInst.axesType1 '_' num2str(sharedInst.currentROI)];
    data = getappdata(handles.figure1, cname); % get data
    if isempty(data)
        data = getappdata(handles.figure1, sharedInst.axesType1);
    end
    if isempty(data)
        errordlg('can not get current axes data.', 'Error');
        return;
    end
    if size(data,1) < size(data,2)
        data = data';
    end

    try
        T = array2table(data);
        writetable(T,outputFileName,'WriteVariableNames',false);
    catch e
        errordlg('can not export a csv file.', 'Error');
        return;
    end
end

% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure');
    figure1_CloseRequestFcn(hFig, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_7 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    if sharedInst.roiNum < 2
        errordlg('There should be more than 2 ROIs.', 'Error');
        return;
    end
    roi1 = 1;
    roi2 = 2;
    result = calcPI(sharedInst.X, sharedInst.Y, {sharedInst.roiMasks{roi1}, sharedInst.roiMasks{roi2}});

    % show in plot
    plotWithNewFigure(handles, result, 1, -1, []);
    
    % add result to axes & show in axes
    cname = ['pi_roi_' num2str(roi1) '_vs_' num2str(roi2)];
    addResult2Axes(handles, result, cname, handles.popupmenu8);
    popupmenu8_Callback(handles.popupmenu8, eventdata, handles);
end
% --------------------------------------------------------------------
function Untitled_13_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_13 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};

    % load latest config
    sharedInst.dcdRadius = readTproConfig('dcdRadius', 7.5);
    sharedInst.dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    radius = sharedInst.dcdRadius;
    dcdCnRadius = sharedInst.dcdCnRadius;

    % calc local density of ewd
    hFig = [];
    lastMax = 0;
    for mm=radius:5:radius % start and end value is just for debug
        r = mm / sharedInst.mmPerPixel;
        cnr = dcdCnRadius / sharedInst.mmPerPixel;
        [means, results] = calcLocalDensityDcdAllFly(Q_loc_estimateX, Q_loc_estimateY, sharedInst.roiMaskImage, r, cnr);

        % show in plot
        if lastMax < max(max(results))
            lastMax = max(max(results));
        end
        hFig = plotAllFlyWithNewFigure(handles, results, lastMax, 0, hFig);
    end

    % show statistical data
    flyNum = size(results,2);
    cells = cell(flyNum,2);
    for i=1:flyNum
        cells(i,:) = {i,nanmean(results(:,i))};
        num = cell2mat(cells(i,2));
        disp(['id=' num2str(i) ' max=' num2str(max(results(:,i)))  ' min=' num2str(min(results(:,i)))  ' mean=' num2str(num)]);
    end
    tbl = cell2table(cells);
    outtbl = sortrows(tbl, 2, 'descend');
    out = table2cell(outtbl);
    orderstr = [];
    for i=1:flyNum
        orderstr = [orderstr ' ' num2str(cell2mat(out(i,1)))];
    end
    disp(['dcd order index =' orderstr]);

    % add result to axes & show in axes
    cname = 'aggr_dcd_result';
    addResult2Axes(handles, means, cname, handles.popupmenu8);
    addResult2Axes(handles, results, [cname '_tracking'], handles.popupmenu8);
    result = means;
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    result = results;
    save([sharedInst.confPath 'multi/' cname '_tracking.mat'], 'result');
    popupmenu8_Callback(handles.popupmenu8, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_14_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_14 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};
    multiR = 2.5:0.5:10;
    dcdCnRadius = sharedInst.dcdCnRadius;
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;

    % calc local density of ewd
    hFig = [];
    lastMax = 0;
    multiR = multiR / sharedInst.mmPerPixel;
    cnR = dcdCnRadius / sharedInst.mmPerPixel;
    results = calcLocalDensityDcdAllFlyMultiR(Q_loc_estimateX, Q_loc_estimateY, sharedInst.roiMaskImage, multiR, cnR);

    % show in plot
    lastMax = 0;
    flyNum = size(results,2);
    for i = 1:flyNum
        result = squeeze(results(t,i,:));
        if lastMax < max(result)
            lastMax = max(result);
        end
        hFig = plotWithNewFigure(handles, result, lastMax, 0, hFig);
    end

    % add result to axes & show in axes
    cname = 'aggr_dcd_result_mr';
    addResult2Axes(handles, results, cname, handles.popupmenu8);
    result = results;
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu8_Callback(handles.popupmenu8, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};
    radius = sharedInst.ewdRadius;

    % calc local density of ewd
    hFig = [];
    lastMax = 0;
    for mm=radius:5:radius % start and end value is just for debug
        r = mm / sharedInst.mmPerPixel;
        [means, results] = calcLocalDensityEwdAllFly(Q_loc_estimateX, Q_loc_estimateY, sharedInst.roiMaskImage, r);

        % show in plot
        if lastMax < max(max(results))
            lastMax = max(max(results));
        end
        hFig = plotAllFlyWithNewFigure(handles, results, lastMax, 0, hFig);
    end

    % show statistical data
    flyNum = size(results,2);
    cells = cell(flyNum,2);
    for i=1:flyNum
        cells(i,:) = {i,nanmean(results(:,i))};
        num = cell2mat(cells(i,2));
        disp(['id=' num2str(i) ' max=' num2str(max(results(:,i)))  ' min=' num2str(min(results(:,i)))  ' mean=' num2str(num)]);
    end
    tbl = cell2table(cells);
    outtbl = sortrows(tbl, 2, 'descend');
    out = table2cell(outtbl);
    orderstr = [];
    for i=1:flyNum
        orderstr = [orderstr ' ' num2str(cell2mat(out(i,1)))];
    end
    disp(['ewd order index =' orderstr]);

    % add result to axes & show in axes
    cname = 'aggr_ewd_result';
    addResult2Axes(handles, means, cname, handles.popupmenu8);
    addResult2Axes(handles, results, [cname '_tracking'], handles.popupmenu8);
    result = means;
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    result = results;
    save([sharedInst.confPath 'multi/' cname '_tracking.mat'], 'result');
    popupmenu8_Callback(handles.popupmenu8, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_9 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    areaMap = sharedInst.roiMaskImage;
    radius = sharedInst.pdbscanRadius;

    % calc local density of pixel density-based scan
    hFig = [];
    lastMax = 0;
    for mm=radius:5:radius
        % show wait dialog
        hWaitBar = waitbar(0,'processing ...','Name','calcurate pixel density-besed scan',...
                    'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
        setappdata(hWaitBar,'canceling',0)

        r = mm / sharedInst.mmPerPixel;
        result = calcLocalDensityPxScan(sharedInst.X, sharedInst.Y, sharedInst.roiMaskImage, r, hWaitBar, areaMap);

        % show in plot
        if lastMax < max(result)
            lastMax = max(result);
        end
        hFig = plotWithNewFigure(handles, result, lastMax, 0, hFig);

        % show aggregation index frequency
        freq = getCountHistgram(result, 100);
        barWithNewFigure(handles, freq, max(freq), 0, 1, length(freq));
    end

    % add result to axes & show in axes
    cname = 'aggr_pdbscan_result';
    addResult2Axes(handles, result, cname, handles.popupmenu8);
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu8_Callback(handles.popupmenu8, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_10 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    id1 = get(handles.popupmenu5,'Value');
    selection = questdlg(['Do you remove fly data (id=' num2str(id1) ')?'],...
                         'Confirmation',...
                         'Yes','No','No');
    switch selection
    case 'Yes'
        % nothing todo
    case 'No'
        return;
    end

    % remove fly data (id)
    for i=1:8
        sharedInst.keep_data{i}(:,id1) = [];
    end

    % set fly list box
    flyNum = size(sharedInst.keep_data{1}, 2);
    listItem = [];
    for i = 1:flyNum
        listItem = [listItem;{i}];
    end
    set(handles.popupmenu5,'Value', 1);
    set(handles.popupmenu5,'String',listItem);

    sharedInst.listFly = 1;
    sharedInst.isModified = true;
    set(handles.pushbutton15, 'Enable', 'on');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --------------------------------------------------------------------
function Untitled_11_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_11 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    id1 = 1;
    id2 = size(sharedInst.keep_data{1},2);
    [dlg, id1, id2, startFrame, endFrame] = inputSwapIdsDialog({num2str(id1), num2str(id2), num2str(sharedInst.startFrame), num2str(sharedInst.endFrame)});
    delete(dlg);
    if id1 < 0
        return;
    end

    swapTrackingData(id1, id2, startFrame, endFrame, true, handles);

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    setappdata(handles.figure1,'x',sharedInst.keep_data{2}); % update shared
    setappdata(handles.figure1,'y',sharedInst.keep_data{1}); % update shared

    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

function moveTrackingPoint(id, frameNum, x, y, isSaveHistory, handles)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % move point
    row = frameNum - sharedInst.startFrame + 1;
    px = sharedInst.keep_data{1}(row,id);
    py = sharedInst.keep_data{2}(row,id);
    sharedInst.keep_data{1}(row,id) = x;
    sharedInst.keep_data{2}(row,id) = y;

    % update edit history
    if isSaveHistory
        if size(sharedInst.editHistory,2) < 7
            sharedInst.editHistory{size(sharedInst.editHistory,1),7} = [];
        end
        sharedInst.editHistory = [sharedInst.editHistory; {'pmove', id, frameNum, x, y, px, py}];
        sharedInst.redoHistory = {};
        set(handles.Untitled_19, 'Enable', 'on');
        set(handles.Untitled_26, 'Enable', 'off');
    end

    sharedInst.isModified = true;
    set(handles.pushbutton15, 'Enable', 'on');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
end

function swapTrackingData(id1, id2, startFrame, endFrame, isSaveHistory, handles)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % swap data
    startRow = startFrame - sharedInst.startFrame + 1;
    endRow = (endFrame - sharedInst.startFrame) / sharedInst.frameSteps + 1;

    for i=1:8
        if id1 == 0
            sharedInst.keep_data{i}(startRow:endRow,id2) = NaN;
        elseif id2 == 0
            sharedInst.keep_data{i}(startRow:endRow,id1) = NaN;
        else
            tmp = sharedInst.keep_data{i}(startRow:endRow,id1);
            sharedInst.keep_data{i}(startRow:endRow,id1) = sharedInst.keep_data{i}(startRow:endRow,id2);
            sharedInst.keep_data{i}(startRow:endRow,id2) = tmp;
        end
    end

    % update edit history
    if isSaveHistory
        sharedInst.editHistory = [sharedInst.editHistory; {'swap', id1, id2, startFrame, endFrame, [], []}];
        sharedInst.redoHistory = {};
        set(handles.Untitled_19, 'Enable', 'on');
        set(handles.Untitled_26, 'Enable', 'off');
    end

    sharedInst.isModified = true;
    set(handles.pushbutton15, 'Enable', 'on');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
end

function mergeTrackingData(id1, id2, isSaveHistory, handles)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % merge data (id2) into (id1), and remove (id2)
    idx = find(~isnan(sharedInst.keep_data{1}(:,id2)));
    startRow = idx(1);
    endRow = idx(end);

    for i=1:8
        sharedInst.keep_data{i}(startRow:endRow,id1) = sharedInst.keep_data{i}(startRow:endRow,id2);
        sharedInst.keep_data{i}(:,id2) = [];
    end

    % update edit history
    if isSaveHistory
        sharedInst.editHistory = [sharedInst.editHistory; {'merge', id1, id2, startRow, endRow, [], []}];
        sharedInst.redoHistory = {};
        set(handles.Untitled_19, 'Enable', 'on');
        set(handles.Untitled_26, 'Enable', 'off');
    end

    % set fly list box
    flyNum = size(sharedInst.keep_data{1}, 2);
    listItem = [];
    for i = 1:flyNum
        listItem = [listItem;{i}];
    end
    set(handles.popupmenu5,'Value', 1);
    set(handles.popupmenu5,'String',listItem);

    sharedInst.listFly = 1;
    sharedInst.isModified = true;
    set(handles.pushbutton15, 'Enable', 'on');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
end

% --------------------------------------------------------------------
function Untitled_12_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_12 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    id1 = 1;
    id2 = size(sharedInst.keep_data{1},2);
    [dlg, id1, id2] = inputMergeIdsDialog({num2str(id1), num2str(id2), num2str(sharedInst.startFrame), num2str(sharedInst.endFrame)});
    delete(dlg);
    if id1 <= 0
        return;
    end

    mergeTrackingData(id1, id2, true, handles);

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    setappdata(handles.figure1,'x',sharedInst.keep_data{2}); % update shared
    setappdata(handles.figure1,'y',sharedInst.keep_data{1}); % update shared

    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end


% --------------------------------------------------------------------
function Untitled_15_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_15 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};
    num = 10;

    % calculate top num of distances and variance
    [means, vars] = calcNumDistanceVarAllFly(Q_loc_estimateX, Q_loc_estimateY, sharedInst.roiMaskImage, num);

    % add result to axes & show in axes
    cname = 'aggr_topmeans_result_tracking';
    addResult2Axes(handles, means, cname, handles.popupmenu8);
    result = means;
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');

    cname = 'aggr_topvars_result_tracking';
    addResult2Axes(handles, vars, cname, handles.popupmenu8);
    result = vars;
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu8_Callback(handles.popupmenu8, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_16_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_16 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};

    % load latest config
    sharedInst.nnHeight = readTproConfig('nnHeight', 5);
    sharedInst.nnAlgorithm = readTproConfig('nnAlgorithm', 'single');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    height = sharedInst.nnHeight / sharedInst.mmPerPixel;
    algorithm = sharedInst.nnAlgorithm; %'single', 'average', 'ward';

    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    fx = Q_loc_estimateX(t,:);
    fy = Q_loc_estimateY(t,:);
    fx(fx==0) = NaN;
    fy(fy==0) = NaN;

    pts = [fx', fy'];
    dist = pdist(pts);
    ctype = {'average', 'ward', 'single', 'complete'};
    for i=1:length(ctype)
        tree = linkage(dist,ctype{i});
        %Y = inconsistent(tree)

        % plot dendrogram
        f = figure;
        set(f, 'name', ['nn ' ctype{i} ' dendrogram']); % set window title
        [h,clustered,outperm] = dendrogram(tree, 0);
        ax = gca; % current axes
        ax.FontSize = 6;
    end
    tree = linkage(dist, algorithm);

    % plot colored points
    col = cluster(tree,'cutoff',height,'criterion','distance');
    axes(handles.axes1); % set drawing area
    hold on;
    scatter(fy,fx,height*height,col,'LineWidth',0.5); % the actual detecting
    hold off;
end

% --------------------------------------------------------------------
function Untitled_17_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_17 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};

    % load latest config
    sharedInst.nnHeight = readTproConfig('nnHeight', 5);
    sharedInst.nnAlgorithm = readTproConfig('nnAlgorithm', 'single');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    height = sharedInst.nnHeight / sharedInst.mmPerPixel;
    algorithm = sharedInst.nnAlgorithm;

    % calculate top num of distances and variance
    result = calcClusterNNAllFly(Q_loc_estimateX, Q_loc_estimateY, sharedInst.roiMaskImage, algorithm, height);

    % add result to axes & show in axes
    cname = 'nn_cluster_result_tracking';
    addResult2Axes(handles, result, cname, handles.popupmenu8);
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');

    [result, groupCount, biggestGroup, biggestGroupFlyNum, singleFlyNum] = calcClusterNNGroups(result);
    save([sharedInst.confPath 'multi/nn_groups.mat'], 'result', 'groupCount', 'biggestGroup', 'biggestGroupFlyNum');
    addResult2Axes(handles, result, 'nn_groups', handles.popupmenu8);
    addResult2Axes(handles, groupCount, 'nn_groupCount', handles.popupmenu8);
    addResult2Axes(handles, biggestGroupFlyNum, 'nn_biggestGroupFlyNum', handles.popupmenu8);
    addResult2Axes(handles, singleFlyNum, 'nn_singleFlyNum', handles.popupmenu8);
    popupmenu8_Callback(handles.popupmenu8, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_18_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_18 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    X = sharedInst.keep_data{1};
    Y = sharedInst.keep_data{2};
    dirX = sharedInst.keep_data{5};
    dirY = sharedInst.keep_data{6};

    checkNums = 101;

    % deep learning data
    if ~exist('./deeplearningMaleFemale.mat', 'file')
        errordlg('deeplearningMaleFemale.mat is not found.', 'Error');
        return;
    end

    % load
    load('./deeplearningMaleFemale.mat');
    load('./deeplearningFrontBack2.mat');
    
    % generate random
    r = randperm(sharedInst.endFrame - sharedInst.startFrame + 1);
    r = r(1:checkNums);

    % check male and female
    blobNumber = size(Y,2);
    flySexes = zeros(blobNumber,1);
    for j = 1 : checkNums
        frameNum =  r(j) + sharedInst.startFrame - 1;
        img = TProRead(sharedInst.shuttleVideo, frameNum);
        step2Image = applyBackgroundSub(handles, img);
        
        glayImages = cell(blobNumber,1);
        for i = 1:blobNumber
            % pre calculation
            cx = X(frameNum,i);
            cy = Y(frameNum,i);
            vec = [dirX(frameNum,i); dirY(frameNum,i)];

            trimmedImage = getOneFlyBoxImage_(step2Image, cy, cx, vec, sharedInst.boxSize);
            img = resizeImage64ForDL(trimmedImage);
            % Extract image features using the CNN
            imageFeatures = activations(netForFrontBack, img, 11);

            % Make a prediction using the classifier
            label = predict(classifierFrontBack, imageFeatures);
            if label == 'fly_back'
                vec = -vec;
                img = imrotate(img, 180, 'crop', 'bilinear');
            end
            glayImages{i} = img;
        end
        
        labels = distinguishMaleFemale_deepLearning(glayImages, netForMaleFemale, classifierMaleFemale);
        for i = 1:blobNumber
            if labels{i} == 'fly_male'
                flySexes(i) = flySexes(i) + 1;
            end
        end
        disp([num2str(j) ') checking frame : ' num2str(frameNum)]);
    end

    % show result
    flySexes = flySexes ./ checkNums;
    for i = 1:blobNumber
        if flySexes(i) > 0.5
            sex = 'male';
        else
            sex = 'female';
        end
        disp([num2str(i) ') ' sex ' (' num2str(flySexes(i)) ')']);
    end
end

% --------------------------------------------------------------------
function Untitled_19_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_19 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    histNum = size(sharedInst.editHistory, 1);
    if histNum > 0
        hist = sharedInst.editHistory(histNum,:);
        if strcmp(hist{1},'swap') && sharedInst.listMode == 1
            sharedInst.redoHistory = [sharedInst.redoHistory; hist];
            sharedInst.editHistory(histNum,:) = [];
            sharedInst.selectX = {};
            sharedInst.selectY = {};
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            swapTrackingData(hist{2}, hist{3}, hist{4}, hist{5}, false, handles);
            showFrameInAxes(hObject, handles, sharedInst.frameNum);
            text(6, 30, ['undo swap: ' num2str(hist{2}) ' and ' num2str(hist{3}) ' at frame ' num2str(hist{4})], 'Color',[1 .2 .2])
            if histNum == 1
                set(handles.Untitled_19, 'Enable', 'off');
            end
            set(handles.Untitled_26, 'Enable', 'on');
        elseif strcmp(hist{1},'pmove')
            sharedInst.redoHistory = [sharedInst.redoHistory; hist];
            sharedInst.editHistory(histNum,:) = [];
            sharedInst.selectX = {};
            sharedInst.selectY = {};
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            moveTrackingPoint(hist{2}, hist{3}, hist{6}, hist{7}, false, handles);
            showFrameInAxes(hObject, handles, sharedInst.frameNum);
            text(6, 30, ['undo point move: id=' num2str(hist{2}) ' at frame ' num2str(hist{3})], 'Color',[1 .2 .2])
            if histNum == 1
                set(handles.Untitled_19, 'Enable', 'off');
            end
            set(handles.Untitled_26, 'Enable', 'on');
        else
            text(6, 30, 'can not undo. bad fly list mode or unsupported operation.', 'Color',[1 .2 .2])
        end
    end
end

% --------------------------------------------------------------------
function Untitled_20_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_20 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_21_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_21 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % automatic merge fly IDs
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    X = sharedInst.keep_data{1};
    fn = size(X,2);
    frame = size(X,1);

    for i=fn:-1:1
        if ~isnan(X(1,i))
            continue;
        end
        x1 = X(1:(frame-2),i);
        xfirst = find(~isnan(x1),1,'first');
        for j=(i-1):-1:1
            s = max(1, xfirst-5);
            e = min(xfirst+5, frame-2);
            x2 = X(s:e,j);
            nanidx = find(isnan(x2));
            nanlen = length(nanidx);
            if nanlen > 0 && nanlen < 11 && nanidx(1) < 10
                % check more. trajectory should not be overwritten.
                nanidx = find(~isnan(X(e:frame-2,j)));
                if ~isempty(nanidx)
                    continue;
                end
                disp(['merge trajectory : ' num2str(j) ' <= ' num2str(i) ' (xfirst=' num2str(xfirst) ')']);
                mergeTrackingData(j, i, true, handles);
                break;
            end
        end
    end
    
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    setappdata(handles.figure1,'x',sharedInst.keep_data{2}); % update shared
    setappdata(handles.figure1,'y',sharedInst.keep_data{1}); % update shared

    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end


% --------------------------------------------------------------------
function Untitled_23_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_23 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % apply edit history
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % unselect points
    sharedInst.selectX = {};
    sharedInst.selectY = {};
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    % TODO: load csv file
    src = load([sharedInst.confPath 'multi/trackingEditHistoryOrg.mat']);
    % apply history
    for i=1:size(src.editHistory,1)
        id1 = src.editHistory{i,2};
        id2 = src.editHistory{i,3};
        startFrame = src.editHistory{i,4};
        endFrame = src.editHistory{i,5};
        switch(src.editHistory{i,1})
        case 'merge'
            mergeTrackingData(id1, id2, true, handles);
        case 'swap'
            swapTrackingData(id1, id2, startFrame, endFrame, true, handles);
        end
    end

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    setappdata(handles.figure1,'x',sharedInst.keep_data{2}); % update shared
    setappdata(handles.figure1,'y',sharedInst.keep_data{1}); % update shared

    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --------------------------------------------------------------------
function Untitled_24_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_24 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.isModified == false
        return;
    end

    confPath = sharedInst.confPath;
    filename = [sprintf('%05d',sharedInst.startFrame) '_' sprintf('%05d',sharedInst.endFrame)];
    keep_data = sharedInst.keep_data;
    editHistory = sharedInst.editHistory;

    % save keep_data
    save(strcat(confPath,'multi/track_',filename,'.mat'), 'keep_data');

    % save edit log
    save([sharedInst.confPath 'multi/trackingEditHistory.mat'], 'editHistory');

    sharedInst.isModified = false;
    set(handles.pushbutton15, 'Enable', 'off')
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
end

% --------------------------------------------------------------------
function Untitled_25_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_25 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    confPath = sharedInst.confPath;
    filename = [sprintf('%05d',sharedInst.startFrame) '_' sprintf('%05d',sharedInst.endFrame)];
    keep_data = sharedInst.keep_data;
    roiMasks = sharedInst.roiMasks;
    roiNum = length(roiMasks);
    
    %
    disp(['saving tracking result : ' sharedInst.shuttleVideo.name]);
    tic;

    % make output folder
    if ~exist([confPath 'output'], 'dir')
        mkdir([confPath 'output']);
    end
    for i=1:roiNum
        outputDataPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
        if ~exist(outputDataPath, 'dir')
            mkdir(outputDataPath);
        end
    end

    % optional data export
    mdparam = [];
    dcdparam = [];
    if sharedInst.exportDcd
        dcdparam = [sharedInst.dcdRadius / sharedInst.mmPerPixel, sharedInst.dcdCnRadius / sharedInst.mmPerPixel];
    end
    if sharedInst.exportMd
        mdparam = [sharedInst.mmPerPixel];
    end

    % save data as text
    flyNum = size(keep_data{1}, 2);
    end_row = size(keep_data{1}, 1) - 2;
    img_h = sharedInst.img_h;
    img_w = sharedInst.img_w;
    for i=1:roiNum
        outputDataPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
        dataFileName = [outputDataPath sharedInst.shuttleVideo.name '_' filename];

        % output text data
        saveTrackingResultText(dataFileName, keep_data, end_row, flyNum, img_h, img_w, roiMasks{i}, dcdparam, mdparam, []);
    end
    time = toc;
    disp(['done!     t =' num2str(time) 's']);
end

% --------------------------------------------------------------------
function Untitled_26_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_26 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    histNum = size(sharedInst.redoHistory, 1);
    if histNum > 0
        hist = sharedInst.redoHistory(histNum,:);
        if strcmp(hist{1},'swap') && sharedInst.listMode == 1
            sharedInst.editHistory = [sharedInst.editHistory; hist];
            sharedInst.redoHistory(histNum,:) = [];
            sharedInst.selectX = {};
            sharedInst.selectY = {};
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            swapTrackingData(hist{2}, hist{3}, hist{4}, hist{5}, false, handles);
            showFrameInAxes(hObject, handles, sharedInst.frameNum);
            text(6, 30, ['redo swap: ' num2str(hist{2}) ' and ' num2str(hist{3}) ' at frame ' num2str(hist{4})], 'Color',[1 .2 .2])
            if histNum == 1
                set(handles.Untitled_26, 'Enable', 'off');
            end
            set(handles.Untitled_19, 'Enable', 'on');
        elseif strcmp(hist{1},'pmove')
            sharedInst.editHistory = [sharedInst.editHistory; hist];
            sharedInst.redoHistory(histNum,:) = [];
            sharedInst.selectX = {};
            sharedInst.selectY = {};
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            moveTrackingPoint(hist{2}, hist{3}, hist{4}, hist{5}, false, handles);
            showFrameInAxes(hObject, handles, sharedInst.frameNum);
            text(6, 30, ['redo point move: id=' num2str(hist{2}) ' at frame ' num2str(hist{3})], 'Color',[1 .2 .2])
            if histNum == 1
                set(handles.Untitled_26, 'Enable', 'off');
            end
            set(handles.Untitled_19, 'Enable', 'on');
        else
            text(6, 30, 'can not redo. bad fly list mode or unsupported operation.', 'Color',[1 .2 .2])
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% utility functions

%% show frame function
function showFrameInAxes(hObject, handles, frameNum)
    axes(handles.axes1); % set drawing area

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if ~isempty(sharedInst.originalImage) && (ndims(sharedInst.originalImage) > 1) % check cache
        img = sharedInst.originalImage;
    else
        img = TProRead(sharedInst.shuttleVideo, frameNum);
        sharedInst.originalImage = img;
    end

    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    % show detection result
    if t > size(sharedInst.X,2) || t < 1
        % show original image
        cla;
        if sharedInst.backMode <= 2
            imshow(img);
        end
        return;
    end

    X = sharedInst.X{t}(:);
    Y = sharedInst.Y{t}(:);
    img_h = size(img,1);
    img_w = size(img,2);
    
    if strcmp(sharedInst.axesType1,'aggr_pdbscan_result')
        [rr cc] = meshgrid(1:img_w, 1:img_h);
        r = sharedInst.pdbscanRadius / sharedInst.mmPerPixel;
        [map, count] = calcLocalDensityPxScanFrame(Y, X, rr, cc, r, img_h, img_w);
        map(sharedInst.roiMaskImage==0) = 0;
        % to color
        if ismatrix(img)
            img = cat(3,img,img,img);
        end
        redImage = img(:,:,2);
        redImage = uint8(single(redImage).*(imcomplement(map*0.1)));
        img(:,:,2) = redImage;
    end

    % show original image
    cla;
    if sharedInst.backMode == 1
        imshow(img);
    elseif sharedInst.backMode == 2
        imshow(sharedInst.bgImage);
    elseif sharedInst.backMode == 3
        pos = [0 0 sharedInst.img_w sharedInst.img_h];
        rectangle('Position',pos,'FaceColor',[0 0 0]);
    end

    angle = sharedInst.keep_data{8};
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};
    flameMax = size(Q_loc_estimateX, 1);
    flyNum = size(Q_loc_estimateX, 2);
    listFly = sharedInst.listFly;
    currentMask = sharedInst.roiMaskImage;

    % check ROI
    if sharedInst.currentROI > 0
        currentMask = sharedInst.roiMasks{sharedInst.currentROI};
        for fn = length(X):-1:1
            if isnan(Y(fn)) || isnan(X(fn)) || currentMask(round(X(fn)),round(Y(fn))) <= 0
                X(fn) = NaN;
                Y(fn) = NaN;
            end
        end
    end

    % show detection number
    C_LIST = ['r' 'b' 'g' 'c' 'm' 'y'];

    hold on;
    if strcmp(sharedInst.axesType1,'aggr_ewd_result_tracking') || strcmp(sharedInst.axesType1,'aggr_dcd_result_tracking') || ...
       strcmp(sharedInst.axesType1,'aggr_dcd_result_mr') || strcmp(sharedInst.axesType1,'nn_cluster_result_tracking') || ...
       strcmp(sharedInst.axesType1,'nn_groups') || strcmp(sharedInst.axesType1,'nn_groupCount') || ...
       strcmp(sharedInst.axesType1,'nn_biggestGroupFlyNum')
        major = sharedInst.mean_blobmajor * 0.9;
        minor = major / 5 * 2;
        pos = [-major/2 -minor/2 major minor];
        fy = Q_loc_estimateY(t,:);
        fx = Q_loc_estimateX(t,:);
        % get clustering result of all fly
        data = getappdata(handles.figure1, 'nn_cluster_result_tracking');
        if ~isempty(data) && strcmp(sharedInst.axesType1,'nn_cluster_result_tracking')
            height = sharedInst.nnHeight;
            if height > 10, height = 10; end
            height = height / sharedInst.mmPerPixel;
            sharedInst.axesType1 = 'aggr_dcd_result_tracking';

            culster = data(t,:);
            for i=1:max(culster)
                idxs = find(culster==i);
                if length(idxs)<=1
                    culster(idxs) = 0;
                end
            end
            idxs = find(culster==0);
            fy2 = fy; fx2 = fx;
            fy2(idxs) = [];
            fx2(idxs) = [];
            culster(idxs) = [];
            scatter(fy2,fx2,height*height,culster,'filled','LineWidth',0.5); % the actual detecting
        end
        % nn clustered groups
        data = getappdata(handles.figure1, 'nn_groups');
        if ~isempty(data) && strcmp(sharedInst.axesType1,'nn_groups') || strcmp(sharedInst.axesType1,'nn_groupCount') || ...
             strcmp(sharedInst.axesType1,'nn_biggestGroupFlyNum')
            height = sharedInst.nnHeight;
            if height > 10, height = 10; end
            height = height / sharedInst.mmPerPixel;

            culster = data(t,:);
            idxs = find(isnan(culster));
            fy2 = fy; fx2 = fx;
            fy2(idxs) = [];
            fx2(idxs) = [];
            culster(idxs) = [];
            scatter(fy2,fx2,height*height,culster,'filled','LineWidth',0.5); % the actual detecting
        end
        % local densities
        if strcmp(sharedInst.axesType1,'aggr_ewd_result_tracking') || strcmp(sharedInst.axesType1,'aggr_dcd_result_tracking') || ...
           strcmp(sharedInst.axesType1,'aggr_dcd_result_mr')
            % get ewd/dcd result of all fly
            data = getappdata(handles.figure1, sharedInst.axesType1);
            if size(data,3) == 1
                ewdmin = min(min(data));
                ewdmax = max(max(data));
            else
                mrIdx = 11;
                ewdmin = min(min(data(:,:,mrIdx)));
                ewdmax = max(max(data(:,:,mrIdx)));
            end
            for i=1:length(fx)
                if ~isnan(fy(i)) && ~isnan(fx(i))
                    if size(data,3) == 1
                        score = data(t,i);
                    else
                        score = data(t,i,mrIdx);
                    end
                    if ~isnan(score)
                        idx = floor((score - ewdmin) / (ewdmax - ewdmin) * 100 * 1.5);
                        if idx <= 0, idx = 1; end
                        if idx > size(sharedInst.ewdColors,1), idx = size(sharedInst.ewdColors,1); end
                        col = sharedInst.ewdColors(idx,:);
                        g = hgtransform();
                        r = rectangle('Parent',g,'Position',pos,'Curvature',[1 1],'FaceColor',col,'EdgeColor',col/2);
                        ang = angle(t,i);
                        if isnan(ang)
                            ang = 0;
                        end
                        g.Matrix = makehgtform('translate',[fy(i) fx(i) 0],'zrotate',-ang/180*pi);
                    end
                end
            end
        end
    elseif sharedInst.showDetectResult
        if sharedInst.listMode == 1
            plot(Y,X,'or'); % the actual detecting
        else
            fy = Q_loc_estimateY(t,listFly);
            fx = Q_loc_estimateX(t,listFly);
            if ~isnan(fy) && ~isnan(fx) && currentMask(round(fx),round(fy)) > 0
                plot(fy,fx,'or'); % the actual detecting
            end
        end
        % show selected point
        if ~isempty(sharedInst.selectX)
            slen = 1; % just for one frame
            for i=1:slen
                plot(sharedInst.selectY{i},sharedInst.selectX{i},'or','Color', [.3 1 .3]);
            end
        end
    end

    for fn = 1:flyNum
        col = mod(fn,6)+1; %pick color

        if sharedInst.listMode == 2 && listFly ~= fn
            continue; % show only one fly
        end
    
        if sharedInst.lineMode == 1
            % show all lines
            % find first frame
            ff = 1;
            while (isnan(Q_loc_estimateX(ff,fn)) || Q_loc_estimateX(ff,fn) == 0) && ff < flameMax
                ff = ff + 1;
            end
            if ff == flameMax
                continue; % bad data ignore it
            end
            % find end frame
            fe = ff + 1;
            while (~isnan(Q_loc_estimateX(fe,fn)) || Q_loc_estimateX(fe,fn) ~= 0) && fe < flameMax
                fe = fe + 1;
            end
            if fe ~= flameMax
                fe = fe - 1;
            end

            tmX = Q_loc_estimateX(ff:fe,fn);
            tmY = Q_loc_estimateY(ff:fe,fn);
            % check ROI
            if sharedInst.currentROI > 0
                for j = length(tmX):-1:1
                    if isnan(tmX(j)) || isnan(tmY(j)) || currentMask(round(tmX(j)),round(tmY(j))) <= 0
                        tmX(j) = NaN;
                        tmY(j) = NaN;
                    end
                end
            end
            if sharedInst.lineLength > 0
                plot(tmY, tmX, '-', 'markersize', 1, 'color', C_LIST(col), 'linewidth', 1)  % rodent 1 instead of Cz
            end

            % show number
            if sharedInst.showNumber && listFly > 0
                num_txt = ['  ', num2str(fn)];
                text(Q_loc_estimateY(t,listFly),Q_loc_estimateX(t,listFly),num_txt, 'Color','red')
            end            
        else
            % show tail lines
            if ~isnan(Q_loc_estimateX(t,fn))
                if t < sharedInst.lineLength+2
                    st = t-1;
                else
                    st = sharedInst.lineLength;
                end
                while (isnan(Q_loc_estimateX(t-st,fn)) || Q_loc_estimateX(t-st,fn) == 0) && st > 0
                    st = st - 1;
                end
                tmX = Q_loc_estimateX(t-st:t,fn);
                tmY = Q_loc_estimateY(t-st:t,fn);
                % check ROI
                if sharedInst.currentROI > 0
                    for j = length(tmX):-1:1
                        if isnan(tmX(j)) || isnan(tmY(j)) || currentMask(round(tmX(j)),round(tmY(j))) <= 0
                            tmX(j) = NaN;
                            tmY(j) = NaN;
                        end
                    end
                end
                if sharedInst.lineLength > 0
                    plot(tmY, tmX, '-', 'markersize', 1, 'color', C_LIST(col), 'linewidth', 1)  % rodent 1 instead of Cz
                end

                % show number
                if sharedInst.showNumber
                    num_txt = ['  ', num2str(fn)];
                    text(double(tmY(end)),double(tmX(end)),num_txt, 'Color','red')
                    % quiver(Y{t}(11:12),X{t}(11:12),keep_direction_sorted{t}(1,11:12)',keep_direction_sorted{t}(2,11:12)', 'r', 'MaxHeadSize',1, 'LineWidth',1)  %arrow
                end
            end
        end
    end
    % show edit mode
    if sharedInst.editMode > 0
        if sharedInst.editMode == 1 && sharedInst.listMode == 1
            modeText = 'please click to select tracking point.';
        elseif sharedInst.editMode == 1 && sharedInst.listMode == 2
            modeText = 'please click to move tracking point. (Ctrl+Z to undo)';
        end
        text(6, 12, modeText, 'Color',[1 .4 .4])
    end
    hold off;

    % show long params
    showLongAxesTimeLine(handles.axes3, handles, t);

    % reset current axes (prevent miss click)
    axes(handles.axes1); % set drawing area

    % show axes value
    flyId = sharedInst.listFly;
    type = sharedInst.axesType1;
    data = getappdata(handles.figure1, [type '_' num2str(sharedInst.currentROI)]); % get data
    if isempty(data)
        if ~isempty(flyId) && flyId == 0
            type = strrep(type, '_tracking', '');
        end
        data = getappdata(handles.figure1, type);
    end
    if ~isempty(data)
        if ~isempty(flyId) && flyId > 0 && size(data,1)~=1 && size(data,2)~=1
            yval = data(t,flyId);
        else
            yval = data(t);
        end
        set(handles.text8, 'String', yval);
    end
    % show detected count
    guidata(hObject, handles);    % Update handles structure
end
