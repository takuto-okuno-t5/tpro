function varargout = annotationDialog(varargin)
% ANNOTATIONDIALOG MATLAB code for annotationDialog.fig
%      ANNOTATIONDIALOG, by itself, creates a new ANNOTATIONDIALOG or raises the existing
%      singleton*.
%
%      H = ANNOTATIONDIALOG returns the handle to a new ANNOTATIONDIALOG or the handle to
%      the existing singleton*.
%
%      ANNOTATIONDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATIONDIALOG.M with the given input arguments.
%
%      ANNOTATIONDIALOG('Property','Value',...) creates a new ANNOTATIONDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before annotationDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to annotationDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help annotationDialog

% Last Modified by GUIDE v2.5 22-Jun-2017 19:39:17

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 0;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @annotationDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @annotationDialog_OutputFcn, ...
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


% --- Executes just before annotationDialog is made visible.
function annotationDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to annotationDialog (see VARARGIN)

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
    inputListFile = './input_videos.mat';
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
    load(strcat(confPath,'multi/track_',filename,'.mat'));

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
    sharedInst.stepTime = 0.1;
    sharedInst.showDetectResult = 1;
    sharedInst.showNumber = 1;
    sharedInst.listFly = 1;
    sharedInst.lineMode = 1; % tail
    sharedInst.lineLength = 19;
    sharedInst.backMode = 1; % movie
    
    contents = cellstr(get(handles.popupmenu4,'String'));
    sharedInst.axesType1 = contents{get(handles.popupmenu4,'Value')};
    contents = cellstr(get(handles.popupmenu4,'String'));
    sharedInst.axesType2 = contents{get(handles.popupmenu4,'Value')};

    sharedInst.X = X;
    sharedInst.Y = Y;
    sharedInst.keep_direction_sorted = keep_direction_sorted;
    sharedInst.keep_ecc_sorted = keep_ecc_sorted;
    sharedInst.keep_angle_sorted = keep_angle_sorted;
    sharedInst.keep_areas = keep_areas;
    sharedInst.keep_data = keep_data;

    % calc velocity
    endLow = size(keep_data{3},1);
    vxy = zeros(size(keep_data{3},1), size(keep_data{3},2));
    for i = 1:endLow
        vxy(i,:) = sqrt( keep_data{3}(i,:).^2 +  keep_data{4}(i,:).^2  );
    end
    sharedInst.vxy = vxy;
    
    sharedInst.originalImage = [];

    set(handles.text4, 'String', sharedInst.shuttleVideo.NumberOfFrames);
    set(handles.text6, 'String', sharedInst.shuttleVideo.FrameRate);
    set(handles.slider1, 'Min', 1, 'Max', sharedInst.maxFrame, 'Value', sharedInst.startFrame);
    set(handles.edit1, 'String', sharedInst.frameNum);
    set(handles.checkbox1, 'Value', sharedInst.showNumber);
    set(handles.checkbox2, 'Value', sharedInst.showDetectResult);

    set(handles.pushbutton3, 'Enable', 'off')
    set(handles.edit2, 'Enable', 'on')
    
    set(hObject, 'name', ['Annotation : ', sharedInst.shuttleVideo.name]); % set window title
    
    % set fly list box
    flyNum = size(keep_data{1}, 2);
    listItem = [];
    for i = 1:flyNum
        listItem = [listItem;{i}];
    end
    set(handles.popupmenu3,'String',listItem);

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
    roiFileName = strcat(sharedInst.confPath,'roi.png');
    if exist(roiFileName, 'file')
        img = imread(roiFileName);
        sharedInst.roiMaskImage = im2double(img);
    else
        sharedInst.roiMaskImage = [];
    end

    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure

    % show first frame
    showFrameInAxes(hObject, handles, sharedInst.startFrame);
    
    % UIWAIT makes startEndDialog wait for user response (see UIRESUME)
    %uiwait(handles.figure1); % wait for finishing dialog
end


% --- Outputs from this function are returned to the command line.
function varargout = annotationDialog_OutputFcn(hObject, eventdata, handles) 
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

    % Hint: delete(hObject) closes the figure
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
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if size(eventdata.Modifier,2) > 0 && strcmp(eventdata.Modifier{:}, 'control')
        if strcmp(eventdata.Key, 'rightarrow')
            if sharedInst.frameNum < sharedInst.maxFrame
                pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
                set(handles.slider1, 'value', sharedInst.frameNum + sharedInst.frameSteps*10);
                slider1_Callback(handles.slider1, eventdata, handles)
            end
        elseif strcmp(eventdata.Key, 'leftarrow')
            if sharedInst.frameNum > 1
                pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
                set(handles.slider1, 'value', sharedInst.frameNum - sharedInst.frameSteps*10);
                slider1_Callback(handles.slider1, eventdata, handles)
            end
        end
    elseif strcmp(eventdata.Key, 'rightarrow')
        pushbutton4_Callback(hObject, eventdata, handles);
    elseif strcmp(eventdata.Key, 'leftarrow')
        pushbutton5_Callback(hObject, eventdata, handles);
    elseif strcmp(eventdata.Key, 'uparrow')
        pushbutton2_Callback(hObject, eventdata, handles);
    elseif strcmp(eventdata.Key, 'downarrow')
        pushbutton3_Callback(hObject, eventdata, handles);
    end
end

function figure1_KeyReleaseFcn(hObject, eventdata, handles)
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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

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

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.lineMode = 1;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.edit2, 'Enable', 'off')
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.lineMode = 2;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.edit2, 'Enable', 'on')
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

function edit2_Callback(hObject, eventdata, handles)
    % hObject    handle to edit2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    num = str2num(get(handles.edit2, 'String'));
    if isempty(num)
        set(handles.edit2, 'String', sharedInst.lineLength);
    else
        if num < 1 || num > sharedInst.endFrame
            set(handles.edit1, 'String', sharedInst.lineLength);
        else
            sharedInst.lineLength = num;
        end
    end
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
end

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
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.listFly = str2num(contents{get(hObject,'Value')});
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
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

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.backMode = get(hObject,'Value');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
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


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    contents = cellstr(get(hObject,'String'));
    contents{get(hObject,'Value')};
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

% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    contents = cellstr(get(hObject,'String'));
    contents{get(hObject,'Value')};
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% utility functions

%% show frame function
function showFrameInAxes(hObject, handles, frameNum)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if ~isempty(sharedInst.originalImage) && (ndims(sharedInst.originalImage) > 1) % check cache
        img = sharedInst.originalImage;
    else
        img = TProRead(sharedInst.shuttleVideo, frameNum);
        sharedInst.originalImage = img;
    end
    
    % show original image
    axes(handles.axes1); % set drawing area
    cla;
    if sharedInst.backMode == 1
        imshow(img);
    elseif sharedInst.backMode == 2
        imshow(sharedInst.bgImage);
    end
    
    % show detection result
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};
    flyNum = size(Q_loc_estimateX, 2);
    flameMax = size(Q_loc_estimateX, 1);
    listFly = sharedInst.listFly;
    fy = Q_loc_estimateY(t,listFly);
    fx = Q_loc_estimateX(t,listFly);
    
    if t > size(sharedInst.X,2) || t < 1
        return;
    end

    % show detection result
    hold on;
    if sharedInst.showDetectResult
        plot(sharedInst.Y{t}(:),sharedInst.X{t}(:),'or', 'color', [0.7 0.3 0.3]); % the actual detecting
        plot(fy,fx,'or'); % the actual detecting
    end

    active_num = 0;
    for fn = 1:flyNum
        if ~isnan(Q_loc_estimateX(t,fn))
            active_num = active_num + 1;
        end
        if listFly ~= fn
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
            plot(tmY, tmX, ':', 'markersize', 1, 'color', 'b', 'linewidth', 1)  % rodent 1 instead of Cz

            % show number
            if sharedInst.showNumber
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
                if t + sharedInst.lineLength < size(Q_loc_estimateX,1)
                    ed = sharedInst.lineLength
                else
                    ed = size(Q_loc_estimateX,1) - t;
                end
                while (isnan(Q_loc_estimateX(t-st,fn)) || Q_loc_estimateX(t-st,fn) == 0) && st > 0
                    st = st - 1;
                end
                tmX = Q_loc_estimateX(t-st:t+ed,fn);
                tmY = Q_loc_estimateY(t-st:t+ed,fn);
                plot(tmY, tmX, ':', 'markersize', 1, 'color', 'b', 'linewidth', 1)  % rodent 1 instead of Cz

                % show number
                if sharedInst.showNumber
                    num_txt = ['  ', num2str(fn)];
                    text(fy,fx,num_txt, 'Color','red')
                end
            end
        end
    end
    hold off;
%{
velocity
x velocity
y velocity
sideways velocity
x
y
angle
angle velocity
circularity
%}
    % show closing up fly
    boxsize = 128;
    rect = [fy-boxsize/2 fx-boxsize/2 boxsize boxsize];
    img_trimmed = imcrop(img, rect);
    axes(handles.axes3); % set drawing area
    cla;
    imshow(img_trimmed);
    % plot center line
    hold on;
    plot([0 boxsize], [boxsize/2 boxsize/2], ':', 'markersize', 1, 'color', 'w', 'linewidth', 0.5)  % rodent 1 instead of Cz
    plot([boxsize/2 boxsize/2], [0 boxsize], ':', 'markersize', 1, 'color', 'w', 'linewidth', 0.5)  % rodent 1 instead of Cz
    hold off;
    
    % show long params
    showLongAxes(handles.axes2, handles, t, listFly, sharedInst.axesType1, false);
    showLongAxes(handles.axes5, handles, t, listFly, sharedInst.axesType2, true);

    % show short params
    showShortAxes(handles.axes4, handles, t, listFly, sharedInst.axesType1, false);
    showShortAxes(handles.axes6, handles, t, listFly, sharedInst.axesType2, true);

    % show detected count
    set(handles.text8, 'String', active_num);
    guidata(hObject, handles);    % Update handles structure
end

%% show long axis data function
function showLongAxes(hObject, handles, t, listFly, type, xtickOff)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    velocity = sharedInst.vxy(:,listFly);
    ymax = max(velocity);
    if ymax < 10
        ymax = 10;
    end
    axes(hObject); % set drawing area
    cla;
    plot(1:size(velocity,1), velocity);
    xlim([1 size(velocity,1)]);
    ylim([0 ymax]);
    hObject.Box = 'off';
    hObject.Color = [0 .1 .2];
    hObject.FontSize = 8;
    hObject.XMinorTick = 'off';
%    hObject.TightInset = hObject.TightInset / 2;
    if xtickOff
        xticks(0);
    end
    % plot current time line
    hold on;
    plot([t t], [0 ymax], ':', 'markersize', 1, 'color', 'r', 'linewidth', 0.5)  % rodent 1 instead of Cz
    hold off;
end

%% show short axis data function
function showShortAxes(hObject, handles, t, listFly, type, xtickOff)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    ax4Len = 25;
    dataLen = size(sharedInst.keep_data{1},1);
    if t < ax4Len + 2
        st = t-1;
    else
        st = ax4Len;
    end
    if t + ax4Len < dataLen
        ed = ax4Len;
    else
        ed = dataLen - t;
    end
    velocity = sharedInst.vxy(t-st:t+ed,listFly);
    ymax = max(velocity)*1.5;
    if ymax < 10
        ymax = 10;
    end
    
    axes(hObject); % set drawing area
    cla;
    plot(t-st:t+ed, velocity);
    xlim([t-st t+ed]);
    ylim([0 ymax]);
    hObject.Box = 'off';
    hObject.Color = [0 .1 .2];
    hObject.FontSize = 8;
    if xtickOff
        xticks(0);
    end
    % plot center line
    hold on;
    plot([t t], [0 ymax], ':', 'markersize', 1, 'color', 'r', 'linewidth', 0.5)  % rodent 1 instead of Cz
    hold off;
end

%% TPro Video file (or image folder) reader
function videoStructs = TProVideoReader(videoPath, fileName)
    if isdir([videoPath fileName])
        videoStructs = struct;
        videoStructs.Name = fileName;
        videoStructs.name = fileName;
        videoStructs.FrameRate = 30; % not sure. just set 30
        listing = dir([videoPath fileName]);
        files = cell(size(listing,1)-2,1);
        for i = 1:(size(listing,1)-2) % not include '.' and '..'
            files{i} = listing(i+2).name;
        end
        files = sort(files);
        videoStructs.files = files;
        videoStructs.videoPath = videoPath;
        videoStructs.NumberOfFrames = size(files,1);
    else
        videoStructs = VideoReader([videoPath fileName]);
    end
end

%%
function img = TProRead(videoStructs, frameNum)
    if isfield(videoStructs, 'files')
        try
            filename = [videoStructs.videoPath videoStructs.Name '/' char(videoStructs.files(frameNum))];
            img = imread(filename);
        catch e
            errordlg(['failed to read image file : ' videoStructs.files(frameNum)], 'Error');
        end
    else
        img = read(videoStructs,frameNum);
    end
end
