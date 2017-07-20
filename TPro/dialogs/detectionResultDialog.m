function varargout = detectionResultDialog(varargin)
% DETECTIONRESULTDIALOG MATLAB code for detectionResultDialog.fig
%      DETECTIONRESULTDIALOG, by itself, creates a new DETECTIONRESULTDIALOG or raises the existing
%      singleton*.
%
%      H = DETECTIONRESULTDIALOG returns the handle to a new DETECTIONRESULTDIALOG or the handle to
%      the existing singleton*.
%
%      DETECTIONRESULTDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETECTIONRESULTDIALOG.M with the given input arguments.
%
%      DETECTIONRESULTDIALOG('Property','Value',...) creates a new DETECTIONRESULTDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before detectionResultDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to detectionResultDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help detectionResultDialog

% Last Modified by GUIDE v2.5 20-Jul-2017 02:00:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @detectionResultDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @detectionResultDialog_OutputFcn, ...
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

% --- Executes just before detectionResultDialog is made visible.
function detectionResultDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to detectionResultDialog (see VARARGIN)

    % Choose default command line output for detectionResultDialog
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

    % initialize GUI
    sharedInst = struct; % allocate shared instance
    sharedInst.videoPath = videoPath;
    sharedInst.confPath = [videoPath videoFiles{rowNum} '_tpro/'];
    sharedInst.confFileName = confFileName;
    sharedInst.shuttleVideo = TProVideoReader(videoPath, records{2});
    sharedInst.rowNum = rowNum;
    sharedInst.startFrame = records{4};
    sharedInst.endFrame = records{5};
    sharedInst.maxFrame = sharedInst.shuttleVideo.NumberOfFrames;
    sharedInst.frameSteps = records{16};
    sharedInst.fpsNum = records{7};
    sharedInst.frameNum = sharedInst.startFrame;
    sharedInst.stepTime = 0.03;
    sharedInst.showDetectResult = 1;
    sharedInst.showIndexNumber = 0;
    sharedInst.backMode = 1; % movie
    sharedInst.mmPerPixel = records{9};
    sharedInst.roiNum = records{10};
    sharedInst.currentROI = 0;
    sharedInst.axesType1 = 'count';

    % fix old parameters
    if sharedInst.mmPerPixel <= 0
        sharedInst.mmPerPixel = 0.1;
    end
    
    sharedInst.X = X;
    sharedInst.Y = Y;

    sharedInst.originalImage = [];

    set(handles.text5, 'String', sharedInst.shuttleVideo.NumberOfFrames);
    set(handles.text7, 'String', sharedInst.shuttleVideo.FrameRate);
    set(handles.slider1, 'Min', 1, 'Max', sharedInst.maxFrame, 'Value', sharedInst.startFrame);
    set(handles.edit1, 'String', sharedInst.frameNum);
    set(handles.checkbox2, 'Value', sharedInst.showDetectResult);

    set(handles.pushbutton3, 'Enable', 'off')
    
    set(hObject, 'name', ['Detection result for ', sharedInst.shuttleVideo.name]); % set window title

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
    else
        sharedInst.bgImage = [];
        sharedInst.bgImageDouble = [];
        sharedInst.bgImageMean = [];
    end

    % load roi image file
    roiMaskImage = [];
    roiMasks = {};
    roiX = {};
    roiY = {};
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
            % load ROI points
            roiMatName = strrep(roiFileName, '.png', '.mat');
            if exist(roiMatName, 'file')
                pts = load(roiMatName);
                roiX = [roiX, pts.roiX];
                roiY = [roiY, pts.roiY];
            else
                roiX = [roiX, zeros(0,1)];
                roiY = [roiY, zeros(0,1)];
            end
        end
    end
    sharedInst.roiMaskImage = roiMaskImage;
    sharedInst.roiMasks = roiMasks;    
    sharedInst.roiX = roiX;
    sharedInst.roiY = roiY;

    % set ROI list box
    listItem = {'all'};
    for i = 1:sharedInst.roiNum
        listItem = [listItem;{['ROI-' num2str(i)]}];
    end
    set(handles.popupmenu3,'String',listItem);

    % count each ROI fly number
    img_h = size(roiMaskImage,1);
    img_w = size(roiMaskImage,2);
    xsize = size(X, 2);
    flyCounts = zeros(xsize,1);
    for i=1:sharedInst.roiNum
        roiCount = zeros(xsize,1);
        % cook raw data before saving
        for row_count = 1:xsize
            fy = X{row_count}(:);
            fx = Y{row_count}(:);
            flyNum = length(fx);
            count = 0;
            for j = 1:flyNum
                y = round(fy(j));
                x = round(fx(j));
                if (y <= img_h) && (x <= img_w) && ~isnan(y) && ~isnan(x) && x >= 1 && y >= 1 && roiMasks{i}(y,x) > 0
                    count = count + 1;
                end
            end
            flyCounts(row_count) = flyNum;
            roiCount(row_count) = count;
        end
        setappdata(handles.figure1,['count_' num2str(i)],roiCount); % set axes data
    end
    setappdata(handles.figure1,'count_0',flyCounts); % set axes data
    
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
    
    % show long params
    showLongAxes(handles.axes2, handles, sharedInst.startFrame, sharedInst.axesType1, sharedInst.currentROI);
    
    % show first frame
    showFrameInAxes(hObject, handles, sharedInst.startFrame);
end

% --- Outputs from this function are returned to the command line.
function varargout = detectionResultDialog_OutputFcn(hObject, eventdata, handles) 
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
    delete(hObject);
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
    %	Key: name of the key that was pressed, in lower case
    %	Character: character interpretation of the key(s) that was pressed
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
    % handles    structure with handles and user data (see GUIDATA)
    if strcmp(eventdata.Key, 'rightarrow')
        pushbutton4_Callback(hObject, eventdata, handles);
    elseif strcmp(eventdata.Key, 'leftarrow')
        pushbutton5_Callback(hObject, eventdata, handles);
    elseif strcmp(eventdata.Key, 'uparrow')
        pushbutton2_Callback(hObject, eventdata, handles);
    elseif strcmp(eventdata.Key, 'downarrow')
        pushbutton3_Callback(hObject, eventdata, handles);
    end
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if gca == handles.axes2 || gca == handles.axes3
        sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
        cp = get(gca,'CurrentPoint');
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.startFrame + cp(1));
        slider1_Callback(handles.slider1, eventdata, handles)
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
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    
    set(handles.edit1, 'String', sharedInst.frameNum);
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

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.stepTime = str2num(contents{get(hObject,'Value')});
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
end

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
end

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.backMode = get(hObject,'Value');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
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

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu3 (see GCBO)
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
    % show long params
    showLongAxes(handles.axes2, handles, sharedInst.frameNum, sharedInst.axesType1, sharedInst.currentROI);
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
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

% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % show long params
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.axesType1 = contents{get(hObject,'Value')};
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    showLongAxes(handles.axes2, handles, t, sharedInst.axesType1, sharedInst.currentROI);
    showFrameInAxes(hObject, handles, t);
end

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
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
end

% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % calc local density of veronoi
    result = calcLocalDensityVoronoi(sharedInst.X, sharedInst.Y, sharedInst.roiMasks, ...
        sharedInst.roiX, sharedInst.roiY, sharedInst.currentROI);
    % show in plot
    plotWithNewFigure(handles, result, max(result), 0);
    
    % add result to axes & show in axes
    cname = 'aggr_voronoi_result';
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
end


% calculate local density (voronoi)
function result = calcLocalDensityVoronoi(X, Y, roiMasks, roiX, roiY, currentROI)
    xsize = length(X);
    result = zeros(length(xsize),1);
    for row_count = 1:xsize
        % get detected points and roi points
        fy = Y{row_count}(:);
        fx = X{row_count}(:);
        flyCount = length(fy);
        for i=1:length(roiMasks)
            if currentROI == 0 || (currentROI > 0 && currentROI==i)
                if ~isempty(roiX)
                    fy = [fy; roiX{i}(:)];
                    fx = [fx; roiY{i}(:)];
                end
            end
        end
        
        DT = delaunayTriangulation(fy,fx);
        [V,R] = voronoiDiagram(DT);
%        sharedInst.V{row_count} = V;
%        sharedInst.R{row_count} = R;
        area = zeros(flyCount,1);
        for j=1:flyCount
            poly = V(R{j},:);
            area(j) = polyarea(poly(:,1),poly(:,2));
        end
        totalArea = nansum(area);
        result(row_count) = 1 / (totalArea / flyCount);
%        sharedInst.vArea{row_count} = area;
    end
end

function addResult2Axes(handles, result, itemName, popupmenu)
    listItems = cellstr(get(popupmenu,'String'));
    added = sum(strcmp(itemName, listItems));
    if added == 0
        listItems = [listItems;{itemName}];
        set(popupmenu,'String',listItems);
    end
    setappdata(handles.figure1,itemName,result); % update shared

    % update axes
    idx = 0;
    for i=1:length(listItems)
        if strcmp(listItems{i},itemName)
            idx = i; break;
        end
    end
    if idx > 0
        set(popupmenu,'Value',idx);
    end
end

% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_9 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % calc local density of veronoi
    r = 10 / sharedInst.mmPerPixel;
    result = calcLocalDensityEwd(sharedInst.X, sharedInst.Y, sharedInst.roiMasks, sharedInst.currentROI, r);
    % show in plot
    plotWithNewFigure(handles, result, max(result), 0);

    % add result to axes & show in axes
    cname = 'aggr_ewd_result';
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
end

% ----- calculate local density (frame) -----
function result = calcLocalDensityEwdFrame(x, y, r)
    xlen = length(x);
    ewd = zeros(xlen,1);
    ewd(:) = NaN;

    r2 = r*r;
    rev_pI_r = 1 / (pi * r2);
    % calc local_dencity
    for i=1:xlen
        local_dencity = 0;
        if isnan(x(i))
            ewd(i) = NaN;
        else
            for j=1:xlen
                if i~=j && ~isnan(x(j))
                    dx = x(i) - x(j);
                    dy = y(i) - y(j);
                    fr = exp(-(dx*dx + dy*dy)/r2);
                    local_dencity = local_dencity + fr;
                end
            end
            ewd(i) = rev_pI_r * local_dencity;
        end
    end
    result = nanmean(ewd);
end

% calculate local density (EWD)
function result = calcLocalDensityEwd(X, Y, roiMasks, currentROI, r)
    xsize = length(X);
    result = zeros(length(xsize),1);
    for row_count = 1:xsize
        % get detected points and roi points
        fy = X{row_count}(:);
        fx = Y{row_count}(:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;

        result(row_count) = calcLocalDensityEwdFrame(fx,fy,r);
    end
end

%%
function plotWithNewFigure(handles, yval, ymax, ymin)
    figure;
    hold on;
    plot(1:length(yval), yval);
    xlim([1 length(yval)]);
    ylim([ymin ymax]);
    hold off;
    pause(0.1);
    axes(handles.axes1); % set back drawing area
end

% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
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
    
    % show original image
    cla;
    if sharedInst.backMode == 1
        imshow(img);
    elseif sharedInst.backMode == 2
        imshow(sharedInst.bgImage);
    end
    
    % show detection result
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;    
    if t > size(sharedInst.X,2) || t < 1
        return;
    end
    
    X = sharedInst.X{t}(:);
    Y = sharedInst.Y{t}(:);
    fly_num = length(X);
    currentMask = sharedInst.roiMaskImage;

    % check ROI
    if sharedInst.currentROI > 0
        currentMask = sharedInst.roiMasks{sharedInst.currentROI};
        for fn = fly_num:-1:1
            if isnan(Y(fn)) || isnan(X(fn)) || currentMask(round(X(fn)),round(Y(fn))) <= 0
                X(fn) = NaN;
                Y(fn) = NaN;
            end
        end
    end

    hold on;
    if sharedInst.showDetectResult
        plot(Y,X,'or'); % the actual detecting
    end
    % show number
    if sharedInst.showIndexNumber
        for i=1:size(X,1)
            num_txt = ['  ', num2str(i)];
            text(Y(i),X(i),num_txt, 'Color','red');
        end
    end
    if strcmp(sharedInst.axesType1,'aggr_voronoi_result')
        vY = Y;
        vX = X;
        for i=1:length(sharedInst.roiMasks)
            if sharedInst.currentROI == 0 || (sharedInst.currentROI > 0 && sharedInst.currentROI==i)
                if ~isempty(sharedInst.roiX)
                    vY = [vY;sharedInst.roiX{i}(:)];
                    vX = [vX;sharedInst.roiY{i}(:)];
                end
            end
        end
        if length(vY) > 2
            DT = delaunayTriangulation(vY,vX);
            voronoi(DT);
        end
    end
    hold off;

    % show long params
    showLongAxesTimeLine(handles, t);

    % reset current axes (prevent miss click)
    axes(handles.axes1); % set drawing area

    % show axes value
    cname = [sharedInst.axesType1 '_' num2str(sharedInst.currentROI)];
    data = getappdata(handles.figure1, cname); % get data
    if isempty(data)
        data = getappdata(handles.figure1, sharedInst.axesType1);
    end
    if ~isempty(data)
        set(handles.text9, 'String', data(t));
    end
    guidata(hObject, handles);    % Update handles structure
end

%% show long axis data function
function showLongAxes(hObject, handles, t, type, roi)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    
    % get data
    switch type
        case 'count'
            yval = getappdata(handles.figure1, [type '_' num2str(roi)]); % get data
            ymin = floor(min(yval) * 0.5);
            ymax = floor(max(yval) * 1.2);
            if ymax < 5
                ymax = 5;
            end
        otherwise
            data = getappdata(handles.figure1, [type '_' roi]); % get data
            if isempty(data)
                data = getappdata(handles.figure1, type);
            end
            if isempty(data) || isnan(data(1))
                yval = [];
                ymin = 0;
                ymax = 0;
            else
                yval = data(:);
                ymin = min(yval);
                ymax = max(yval);
                if 1 > ymin && ymin > 0
                    ymin = 0;
                end
            end
    end
    if ymin==ymax
        ymax = ymin + 1;
    end
    
    axes(hObject); % set drawing area
    cla;
    if isempty(yval)
        return; % noting to show
    end
    hold on;
    plot(1:size(yval,1), yval, 'Color', [.6 .6 1]);
    xlim([1 size(yval,1)]);
    ylim([ymin ymax]);
    hObject.Box = 'off';
    hObject.Color = [0 .05 .1];
    hObject.FontSize = 8;
    hObject.XMinorTick = 'off';
%    hObject.TightInset = hObject.TightInset / 2;
    % xtickOff
    % xticks(0); % from 2016b
    type = strrep(type, '_', ' ');
    text(10, (ymax*0.9+ymin*0.1), type, 'Color',[.6 .6 1], 'FontWeight','bold')
    hold off;
end

%%
function showLongAxesTimeLine(handles, t)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    yval = sharedInst.X(:);
    ymin = 0;
    ymax = 1;

    % plot current time line
    handles.axes3.Box = 'off';
    handles.axes3.Color = 'None';
    handles.axes3.FontSize = 1;
    handles.axes3.XMinorTick = 'off';
    handles.axes3.YMinorTick = 'off';
    handles.axes3.XTick = [0];
    handles.axes3.YTick = [0];
    axes(handles.axes3); % set drawing area
    cla;    
    hold on;
    plot([t t], [ymin ymax], ':', 'markersize', 1, 'color', 'r', 'linewidth', 1)  % rodent 1 instead of Cz
    xlim([1 size(yval,1)]);
    ylim([ymin ymax]);
    hold off;
end

