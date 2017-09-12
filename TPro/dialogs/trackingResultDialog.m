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

    % Last Modified by GUIDE v2.5 07-Sep-2017 18:49:29

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
    sharedInst.currentROI = 0;
    sharedInst.axesType1 = 'count';
    sharedInst.isModified = false;
    sharedInst.editMode = 1; % select / add mode

    % fix old parameters
    if sharedInst.mmPerPixel <= 0
        sharedInst.mmPerPixel = 0.1;
    end

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
    tproConfig = 'etc/tproconfig.csv';
    sharedInst.mean_blobmajor = 20;
    sharedInst.mean_blobminor = 10;
    if exist('keep_mean_blobmajor', 'var')
        sharedInst.mean_blobmajor = nanmean(keep_mean_blobmajor);
        sharedInst.mean_blobminor = nanmean(keep_mean_blobminor);
    else
        if exist(tproConfig, 'file')
            tproConfTable = readtable(tproConfig,'ReadRowNames',true);
            values = tproConfTable{'meanBlobMajor',1};
            if size(values,1) > 0
                sharedInst.mean_blobmajor = values(1);
            end
            values = tproConfTable{'meanBlobMinor',1};
            if size(values,1) > 0
                sharedInst.mean_blobminor = values(1);
            end
        end
    end

    % load config 
    sharedInst.exportEwd = 0;
    sharedInst.ewdRadius = 5;
    sharedInst.pdbscanRadius = 5;
    sharedInst.dwdRadius = 10;
    sharedInst.adjacentRadius = 2.5;
    if exist(tproConfig, 'file')
        tproConfTable = readtable(tproConfig,'ReadRowNames',true);
        values = tproConfTable{'exportEwd',1};
        if size(values,1) > 0
            sharedInst.exportEwd = values(1);
        end
        values = tproConfTable{'ewdRadius',1};
        if size(values,1) > 0
            sharedInst.ewdRadius = values(1);
        end
        values = tproConfTable{'pdbscanRadius',1};
        if size(values,1) > 0
            sharedInst.pdbscanRadius = values(1);
        end
        values = tproConfTable{'dwdRadius',1};
        if size(values,1) > 0
            sharedInst.dwdRadius = values(1);
        end
        values = tproConfTable{'dwdBodyRadius',1};
        if size(values,1) > 0
            sharedInst.adjacentRadius = values(1);
        end
    end

    % calc color map for ewd
    sharedInst.ewdColors = expandColor({[0 0 .45], [0 0 1], [1 0 0], [1 .7 .7]}, 100);

    % set fly list box
    flyNum = size(keep_data{1}, 2);
    listItem = [];
    for i = 1:flyNum
        listItem = [listItem;{i}];
    end
    set(handles.popupmenu5,'String',listItem);

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
        sharedInst.bgImageDouble = double(bgImage);
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
            roiMasks = [roiMasks, im2double(img)];
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
    result = calcVxy(keep_data{3}, keep_data{4}) * sharedInst.fpsNum * sharedInst.mmPerPixel;
    cname = 'velocity';
    addResult2Axes(handles, result, cname, handles.popupmenu8);

    % load last time data
    resultNames = {'aggr_voronoi_result', 'aggr_ewd_result', 'aggr_pdbscan_result', 'aggr_md_result', 'aggr_hwmd_result', 'aggr_grid_result', ...
        'aggr_ewd_result_tracking', 'aggr_dwd_result', 'aggr_dwd_result_tracking'};
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
    % just key
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    % shift + key
    if size(eventdata.Modifier,2) > 0 && strcmp(eventdata.Modifier{:}, 'shift')
        switch eventdata.Key
        case 'rightarrow'
        case 'leftarrow'
        end
        return;
    end
    switch eventdata.Key
    case 'rightarrow'
        pushbutton4_Callback(hObject, eventdata, handles);
    case 'leftarrow'
        pushbutton5_Callback(hObject, eventdata, handles);
    case 'uparrow'
        pushbutton2_Callback(hObject, eventdata, handles);
    case 'downarrow'
        pushbutton3_Callback(hObject, eventdata, handles);
    case 'escape'
        sharedInst.editMode = 1;
        sharedInst.selectX = {};
        sharedInst.selectY = {};
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
        showFrameInAxes(hObject, handles, sharedInst.frameNum);
    end
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
    figure1_WindowKeyPressFcn(hObject, eventdata, handles);
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
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
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
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    keep_data = sharedInst.keep_data;
    confPath = sharedInst.confPath;
    filename = [sprintf('%05d',sharedInst.startFrame) '_' sprintf('%05d',sharedInst.endFrame)];
    roiMasks = sharedInst.roiMasks;

    sharedInst.isModified = false;
    set(handles.pushbutton15, 'Enable', 'off')
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    disp(['saving tracking result : ' sharedInst.shuttleVideo.name]);
    tic;
    
    % save keep_data
    save(strcat(confPath,'multi/track_',filename,'.mat'), 'keep_data');

    % save data as text
    flyNum = size(keep_data{1}, 2);
    end_row = size(keep_data{1}, 1) - 2;
    img_h = sharedInst.img_h;
    img_w = sharedInst.img_w;
    roiNum = length(roiMasks);
    for i=1:roiNum
        outputDataPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
        dataFileName = [outputDataPath sharedInst.shuttleVideo.name '_' filename];
    
        ewdparam = [];
        if sharedInst.exportEwd
            ewdparam = [sharedInst.ewdRadius / sharedInst.mmPerPixel];
        end

        % output text data
        saveTrackingResultText(dataFileName, keep_data, end_row, flyNum, img_h, img_w, roiMasks{i}, ewdparam);
    end
    time = toc;
    disp(['done!     t =' num2str(time) 's']);
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
    radius = sharedInst.dwdRadius;
    adjacentRadius = sharedInst.adjacentRadius;

    % calc local density of ewd
    hFig = [];
    lastMax = 0;
    for mm=radius:5:radius % start and end value is just for debug
        r = mm / sharedInst.mmPerPixel;
        ar = adjacentRadius / sharedInst.mmPerPixel;
        [means, results] = calcLocalDensityDwdAllFly(Q_loc_estimateX, Q_loc_estimateY, sharedInst.roiMaskImage, r, ar);

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
    out = sortrows(cells, 2, 'descend');
    orderstr = [];
    for i=1:flyNum
        orderstr = [orderstr ' ' num2str(cell2mat(out(i,1)))];
    end
    disp(['ewd order index =' orderstr]);

    % add result to axes & show in axes
    cname = 'aggr_dwd_result';
    addResult2Axes(handles, means, cname, handles.popupmenu8);
    addResult2Axes(handles, results, [cname '_tracking'], handles.popupmenu8);
    result = means;
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    result = results;
    save([sharedInst.confPath 'multi/' cname '_tracking.mat'], 'result');
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
    out = sortrows(cells, 2, 'descend');
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
    if id1 <= 0
        return;
    end

    % swap data
    startRow = startFrame - sharedInst.startFrame + 1;
    endRow = (endFrame - sharedInst.startFrame) / sharedInst.frameSteps + 1;

    for i=1:8
        tmp = sharedInst.keep_data{i}(startRow:endRow,id1);
        sharedInst.keep_data{i}(startRow:endRow,id1) = sharedInst.keep_data{i}(startRow:endRow,id2);
        sharedInst.keep_data{i}(startRow:endRow,id2) = tmp;
    end

    sharedInst.isModified = true;
    set(handles.pushbutton15, 'Enable', 'on');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
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

    % merge data (id2) into (id1), and remove (id2)
    idx = find(~isnan(sharedInst.keep_data{1}(:,id2)));
    startRow = idx(1);
    endRow = idx(end);

    for i=1:8
        sharedInst.keep_data{i}(startRow:endRow,id1) = sharedInst.keep_data{i}(startRow:endRow,id2);
        sharedInst.keep_data{i}(:,id2) = [];
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
        redImage = uint8(double(redImage).*(imcomplement(map*0.1)));
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
    if strcmp(sharedInst.axesType1,'aggr_ewd_result_tracking') || strcmp(sharedInst.axesType1,'aggr_dwd_result_tracking')
        major = sharedInst.mean_blobmajor;
        minor = major / 5 * 2;
        pos = [-major/2 -minor/2 major minor];
        % get ewd result all fly
        data = getappdata(handles.figure1, sharedInst.axesType1);
        ewdmin = min(min(data));
        ewdmax = max(max(data));
        fy = Q_loc_estimateY(t,:);
        fx = Q_loc_estimateX(t,:);
        for i=1:length(fx)
            if ~isnan(fy(i)) && ~isnan(fx(i)) && ~isnan(data(t,i))
                idx = floor((data(t,i) - ewdmin) / (ewdmax - ewdmin) * 100 * 1.5);
                if idx <= 0, idx = 1; end
                if idx > size(sharedInst.ewdColors,1), idx = size(sharedInst.ewdColors,1); end
                col = sharedInst.ewdColors(idx,:);
                g = hgtransform();
                r = rectangle('Parent',g,'Position',pos,'Curvature',[1 1],'FaceColor',col,'EdgeColor',col/2);
                g.Matrix = makehgtform('translate',[fy(i) fx(i) 0],'zrotate',-angle(t,i)/180*pi);
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
                    text(tmY(end),tmX(end),num_txt, 'Color','red')
                    % quiver(Y{t}(11:12),X{t}(11:12),keep_direction_sorted{t}(1,11:12)',keep_direction_sorted{t}(2,11:12)', 'r', 'MaxHeadSize',1, 'LineWidth',1)  %arrow
                end
            end
        end
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
