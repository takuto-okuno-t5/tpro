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

% Last Modified by GUIDE v2.5 08-Aug-2017 19:13:06

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
    load(strcat(confPath,'multi/track_',filename,'.mat'));
    
    % load annotation file
    annoFileName = [confPath 'multi/annotation_' filename '.mat'];
    if exist(annoFileName, 'file')
        load(annoFileName);
    else
        annotation = zeros(size(keep_data{1},1), size(keep_data{1},2));
    end
    
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
    sharedInst.stepPlay = 1;
    sharedInst.showDetectResult = 1;
    sharedInst.showNumber = 1;
    sharedInst.listFly = 1;
    sharedInst.lineMode = 1; % tail
    sharedInst.lineLength = 19;
    sharedInst.backMode = 1; % movie
    sharedInst.isModified = 0;
    sharedInst.annoStart = 0;
    sharedInst.annoKey = -1;
    sharedInst.mmPerPixel = records{9};

    sharedInst.roiNum = records{10};
    sharedInst.gaussH = records{13};
    sharedInst.gaussSigma = records{14};
    sharedInst.binaryTh = records{8} * 100;
    sharedInst.binaryAreaPixel = records{15};
    sharedInst.blobSeparateRate = records{17};

    contents = cellstr(get(handles.popupmenu4,'String'));
    sharedInst.axesType1 = contents{get(handles.popupmenu4,'Value')};
    contents = cellstr(get(handles.popupmenu5,'String'));
    sharedInst.axesType2 = contents{get(handles.popupmenu5,'Value')};

    sharedInst.X = X;
    sharedInst.Y = Y;
    sharedInst.keep_direction_sorted = keep_direction_sorted;
    sharedInst.keep_ecc_sorted = keep_ecc_sorted;
    sharedInst.keep_angle_sorted = keep_angle_sorted;
    sharedInst.keep_areas = keep_areas;
    sharedInst.keep_data = keep_data;
    sharedInst.annotation = annotation;

    % fix old parameters
    if sharedInst.mmPerPixel <= 0
        sharedInst.mmPerPixel = 0.1;
    end

    sharedInst.originalImage = [];

    set(handles.text4, 'String', sharedInst.shuttleVideo.NumberOfFrames);
    set(handles.text6, 'String', sharedInst.shuttleVideo.FrameRate);
    set(handles.slider1, 'Min', 1, 'Max', sharedInst.maxFrame, 'Value', sharedInst.startFrame);
    set(handles.edit1, 'String', sharedInst.frameNum);
    set(handles.edit3, 'String', sharedInst.mmPerPixel);
    set(handles.checkbox1, 'Value', sharedInst.showNumber);
    set(handles.checkbox2, 'Value', sharedInst.showDetectResult);

    set(handles.pushbutton3, 'Enable', 'off')
    set(handles.pushbutton6, 'Enable', 'off');
    set(handles.edit2, 'Enable', 'on')
    
    set(hObject, 'name', ['Annotation : ', sharedInst.shuttleVideo.name]); % set window title
    
    % set fly list box
    flyNum = size(keep_data{1}, 2);
    listItems = [];
    for i = 1:flyNum
        listItems = [listItems;{i}];
    end
    set(handles.popupmenu3,'String',listItems);

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
    
    % load annotation label
    loadAnnotationLabel(handles);
    
    % calc velocity data
    calcVelocitys(handles, keep_data);

    % show long params
    showLongAxes(handles.axes2, handles, sharedInst.listFly, sharedInst.axesType1, false);
    showLongAxes(handles.axes5, handles, sharedInst.listFly, sharedInst.axesType2, true);
    showLongAxesTimeLine(handles, sharedInst.startFrame, sharedInst.listFly);

    % show first frame
    showFrameInAxes(hObject, handles, sharedInst.startFrame);
    
    % UIWAIT makes startEndDialog wait for user response (see UIRESUME)
    %uiwait(handles.figure1); % wait for finishing dialog
end

function calcVelocitys(handles, keep_data)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.vxy = calcVxy(keep_data{3}, keep_data{4}) * sharedInst.fpsNum * sharedInst.mmPerPixel;
    sharedInst.accVxy = calcDifferential2(sharedInst.vxy);
    bin = calcBinarize(sharedInst.accVxy, 0);
    sharedInst.updownVxy = calcDifferential(bin);
    sharedInst.dir = calcDir(keep_data{5}, keep_data{6});
    sharedInst.sideways = calcSideways(keep_data{2}, keep_data{1}, keep_data{8});
    sharedInst.sidewaysVelocity = calcSidewaysVelocity(sharedInst.vxy, sharedInst.sideways);
    sharedInst.av = abs(calcAngularVelocity(keep_data{8}));
    sharedInst.ecc = keep_data{7};
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
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

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.isModified
        selection = questdlg('Do you save annotation data before closing window?',...
                             'Confirmation',...
                             'Yes','No','Cancel','Yes');
        switch selection
        case 'Cancel'
            return;
        case 'Yes'
            pushbutton6_Callback(handles.pushbutton6, eventdata, handles);
        case 'No'
            % nothing todo
        end
    end

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
    else
        switch eventdata.Key
        case 'rightarrow'
            pushbutton4_Callback(hObject, eventdata, handles);
        case 'leftarrow'
        	pushbutton5_Callback(hObject, eventdata, handles);
        case 'uparrow'
            pushbutton2_Callback(hObject, eventdata, handles);
        case 'downarrow'
            pushbutton3_Callback(hObject, eventdata, handles);
        case {'1','2','3','4','5','6','7','8','9','0', ...
              'numpad1','numpad2','numpad3','numpad4','numpad5', ...
              'numpad6','numpad7','numpad8','numpad9','numpad0', ...
              'delete','escape','return'}
            recodeAnnotation(handles, eventdata.Key);
        end
    end
end

function figure1_KeyReleaseFcn(hObject, eventdata, handles)
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if gca == handles.axes2 || gca == handles.axes4 || gca == handles.axes5 || gca == handles.axes6 || gca == handles.axes7
        sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
        cp = get(gca,'CurrentPoint');
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.startFrame + cp(1));
        slider1_Callback(handles.slider1, eventdata, handles)
    end
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
            frameNum = frameNum + sharedInst.frameSteps * sharedInst.stepPlay;
            
            set(handles.slider1, 'value', frameNum);
            slider1_Callback(handles.slider1, eventdata, handles)
            pause(0.1);
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
    sharedInst.stepPlay = str2num(contents{get(hObject,'Value')});
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

    showLongAxes(handles.axes2, handles, sharedInst.listFly, sharedInst.axesType1, false);
    showLongAxes(handles.axes5, handles, sharedInst.listFly, sharedInst.axesType2, true);
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
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.axesType1 = contents{get(hObject,'Value')};
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    listFly = sharedInst.listFly;
    showLongAxes(handles.axes2, handles, listFly, sharedInst.axesType1, false);
    showLongAxesTimeLine(handles, t, listFly);
    showShortAxes(handles.axes4, handles, t, listFly, sharedInst.axesType1, false);
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
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.axesType2 = contents{get(hObject,'Value')};
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    listFly = sharedInst.listFly;
    showLongAxes(handles.axes5, handles, listFly, sharedInst.axesType2, true);
    showLongAxesTimeLine(handles, t, listFly);
    showShortAxes(handles.axes6, handles, t, listFly, sharedInst.axesType2, true);
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

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared    
    annotation = sharedInst.annotation;
    filename = [sprintf('%05d',sharedInst.startFrame) '_' sprintf('%05d',sharedInst.endFrame)];
    annoFileName = [sharedInst.confPath 'multi/annotation_' filename '.mat'];
    save(annoFileName, 'annotation');
    sharedInst.isModified = 0;
    
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.pushbutton6, 'Enable', 'off');
end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton7 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    dlg = labelConfigDialog({});
    delete(dlg);
    pause(0.1);
    loadAnnotationLabel(handles);
end

% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % show file select modal
    [fileName, path, filterIndex] = uigetfile( {  ...
        '*.csv',  'CSV File (*.csv)'}, ...
        'Pick a file', ...
        'MultiSelect', 'off', '.');

    try
        csvTable = readtable([path fileName],'ReadVariableNames',false);
        records = table2cell(csvTable);
    catch e
        errordlg('please select a csv file.', 'Error');
        return;
    end
    
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    frameNum = size(sharedInst.annotation,1);
    flyNum = size(sharedInst.annotation,2);
    
    if (size(records,1)+2) ~= frameNum || size(records,2) ~= flyNum
        errordlg('input csv does not have appropriate frame or fly number.', 'Error');
        return;
    end

    mat = cell2mat(records);
    mat = [mat; zeros(1,flyNum); zeros(1,flyNum)];
    sharedInst.annotation = mat;
    sharedInst.isModified = 1;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.pushbutton6, 'Enable', 'on');
    h = msgbox({'import csv file successfully!'});
end

% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % show file select modal
    [fileName, path, filterIndex] = uiputfile( {  ...
        '*.csv',  'CSV File (*.csv)'}, ...
        'Export as', '.');

    outputFileName = [path fileName];
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared    
    frameNum = size(sharedInst.annotation,1);
    mat = sharedInst.annotation;
    mat(frameNum,:) = [];
    mat(frameNum-1,:) = []; % remove last 2 rows, these are just empty.

    try
        T = array2table(mat);
        writetable(T,outputFileName,'WriteVariableNames',false);
    catch e
        errordlg('can not export a csv file.', 'Error');
        return;
    end
end


% --------------------------------------------------------------------
function Untitled_16_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_16 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % show file select modal
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
    if ~isempty(str2num(cname(1)))
        cname = ['csv_' cname];
    end
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)

    h = msgbox({'import csv file successfully!'});
end

% --------------------------------------------------------------------
function Untitled_17_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_17 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % show file select modal
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
    if ~isempty(str2num(cname(1)))
        cname = ['csv_' cname];
    end
    addResult2Axes(handles, result, cname, handles.popupmenu5);
    popupmenu5_Callback(handles.popupmenu5, eventdata, handles)

    h = msgbox({'import csv file successfully!'});
end

% --------------------------------------------------------------------
function Untitled_18_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_18 (see GCBO)
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
    % get data
    switch sharedInst.axesType1
    case 'velocity'
        data = sharedInst.vxy;
    case 'x velocity'
        data = sharedInst.keep_data{4};
    case 'y velocity'
        data = sharedInst.keep_data{3};
    case 'sideways'
        data = sharedInst.sideways;
    case 'sideways velocity'
        data = sharedInst.sidewaysVelocity;
    case 'x'
        data = sharedInst.keep_data{2};
    case 'y'
        data = sharedInst.keep_data{1};
    case 'angle'
        data = sharedInst.keep_data{8};
    case 'angle velocity'
        data = sharedInst.av;
    case 'circularity'
        data = sharedInst.keep_data{7};
    otherwise
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
function Untitled_19_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_19 (see GCBO)
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
    % get data
    switch sharedInst.axesType2
    case 'velocity'
        data = sharedInst.vxy;
    case 'x velocity'
        data = sharedInst.keep_data{4};
    case 'y velocity'
        data = sharedInst.keep_data{3};
    case 'sideways'
        data = sharedInst.sideways;
    case 'sideways velocity'
        data = sharedInst.sidewaysVelocity;
    case 'x'
        data = sharedInst.keep_data{2};
    case 'y'
        data = sharedInst.keep_data{1};
    case 'angle'
        data = sharedInst.keep_data{8};
    case 'angle velocity'
        data = sharedInst.av;
    case 'circularity'
        data = sharedInst.keep_data{7};
    otherwise
        data = getappdata(handles.figure1, sharedInst.axesType2);
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
function Untitled_6_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure');
    figure1_CloseRequestFcn(hFig, eventdata, handles);
end

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
    % hObject    handle to File (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Edit_Callback(hObject, eventdata, handles)
    % hObject    handle to Edit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Play_Callback(hObject, eventdata, handles)
    % hObject    handle to Play (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pushbutton2_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_9 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pushbutton3_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_10 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pushbutton4_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_11_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_11 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pushbutton5_Callback(hObject, eventdata, handles);
end

% --------------------------------------------------------------------
function Untitled_13_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_13 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.frameNum < sharedInst.maxFrame
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.frameNum + sharedInst.frameSteps*10);
        slider1_Callback(handles.slider1, eventdata, handles)
    end
end

% --------------------------------------------------------------------
function Untitled_12_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_12 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.frameNum > 1
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.frameNum - sharedInst.frameSteps*10);
        slider1_Callback(handles.slider1, eventdata, handles)
    end
end

function edit3_Callback(hObject, eventdata, handles)
    % hObject    handle to edit3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    mmPerPixel = str2double(get(hObject,'String'));
    if isnan(mmPerPixel) || mmPerPixel <= 0
        set(hObject, 'String', sharedInst.mmPerPixel);
        return;
    end
    sharedInst.mmPerPixel = mmPerPixel;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
    
    % update configuration file
    saveConfigurationFile(handles);
    
    % calc velocity data
    calcVelocitys(handles, sharedInst.keep_data);

    % show long params
    showLongAxes(handles.axes2, handles, sharedInst.listFly, sharedInst.axesType1, false);
    showLongAxes(handles.axes5, handles, sharedInst.listFly, sharedInst.axesType2, true);
    showLongAxesTimeLine(handles, sharedInst.startFrame, sharedInst.listFly);

    % show first frame
    showFrameInAxes(hObject, handles, sharedInst.startFrame);
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


% --------------------------------------------------------------------
function Untitled_14_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_14 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_15_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_15 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    trapezoidNNCluster(handles);
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
    
    if t > size(sharedInst.X,2) || t < 1 || t > size(Q_loc_estimateY,1)
        return;
    end
    fy = Q_loc_estimateY(t,listFly);
    fx = Q_loc_estimateX(t,listFly);

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
                    ed = sharedInst.lineLength;
                else
                    ed = size(Q_loc_estimateX,1) - t;
                end
                while (isnan(Q_loc_estimateX(t-st,fn)) || Q_loc_estimateX(t-st,fn) == 0) && st > 0
                    st = st - 1;
                end
                tmX = Q_loc_estimateX((t-st):(t+ed),fn);
                tmY = Q_loc_estimateY((t-st):(t+ed),fn);
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
    showLongAxesTimeLine(handles, t, listFly);

    % show short params
    axValue = showShortAxes(handles.axes4, handles, t, listFly, sharedInst.axesType1, false);
    axValue = showShortAxes(handles.axes6, handles, t, listFly, sharedInst.axesType2, true);

    % show statistics information
    set(handles.text15, 'String', [num2str(round(fy)) ',' num2str(round(fx))]);
    set(handles.text17, 'String', sharedInst.vxy(t,listFly));
    set(handles.text19, 'String', sharedInst.sidewaysVelocity(t,listFly));
    set(handles.text21, 'String', sharedInst.keep_data{8}(t,listFly));
    set(handles.text23, 'String', sharedInst.keep_data{7}(t,listFly));
    set(handles.text30, 'String', axValue);
    annoNum = sharedInst.annotation(t,listFly);
    if annoNum > 0
        if isempty(sharedInst.annoLabel)
            annoStr = num2str(annoNum);
        else
            annoStr = sharedInst.annoLabel{annoNum};
        end
    else
        annoStr = '--';
    end
    set(handles.text25, 'String', annoStr);
    
    % reset current axes (prevent miss click)
    axes(handles.axes1); % set drawing area
    
    % show detected count
    set(handles.text8, 'String', active_num);
    guidata(hObject, handles);    % Update handles structure
end

%% show long axis data function
function showLongAxes(hObject, handles, listFly, type, xtickOff)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    img_h = size(sharedInst.bgImage,1);
    img_w = size(sharedInst.bgImage,2);
    
    % get data
    switch type
        case 'velocity'
            yval = sharedInst.vxy(:,listFly);
            ymin = 0;
            ymax = max(yval);
            if ymax < 10
                ymax = 10;
            end
        case 'x velocity'
            yval = sharedInst.keep_data{4}(:,listFly);
            ymin = min(yval);
            ymax = max(yval);
        case 'y velocity'
            yval = sharedInst.keep_data{3}(:,listFly);
            ymin = min(yval);
            ymax = max(yval);
        case 'sideways'
            yval = sharedInst.sideways(:,listFly);
            ymin = 0;
            ymax = 1;
        case 'sideways velocity'
            yval = sharedInst.sidewaysVelocity(:,listFly);
            ymin = 0;
            ymax = max(yval);
            if ymax < 10
                ymax = 10;
            end            
        case 'x'
            yval = sharedInst.keep_data{2}(:,listFly);
            ymin = 0;
            ymax = img_w;
        case 'y'
            yval = sharedInst.keep_data{1}(:,listFly);
            ymin = 0;
            ymax = img_h;
        case 'angle'
            yval = sharedInst.keep_data{8}(:,listFly);
            ymin = -90;
            ymax = 90;
        case 'angle velocity'
            yval = sharedInst.av(:,listFly);
            ymin = -90;
            ymax = 90;
        case 'circularity'
            yval = sharedInst.keep_data{7}(:,listFly);
            ymin = 0;
            ymax = 1;
        case '--'
            yval = [];
            ymin = 0;
            ymax = 0;
        otherwise
            data = getappdata(handles.figure1, type); % get data
            if isnan(data)
                yval = [];
                ymin = 0;
                ymax = 0;
            else
                yval = data(:,listFly);
                ymin = min(yval);
                ymax = max(yval);
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
    if xtickOff
%        xticks(0); % from 2016b
    end
    type = strrep(type, '_', ' ');
    text(10, (ymax*0.9+ymin*0.1), type, 'Color',[.6 .6 1], 'FontWeight','bold')
    hold off;
end

function showLongAxesTimeLine(handles, t, listFly)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    yval = sharedInst.vxy(:,listFly);
    ymin = 0;
    ymax = 1;

    handles.axes7.Box = 'off';
    handles.axes7.Color = 'None';
    handles.axes7.FontSize = 1;
    handles.axes7.XMinorTick = 'off';
    handles.axes7.YMinorTick = 'off';
    handles.axes7.XTick = [0];
    handles.axes7.YTick = [0];
    axes(handles.axes7); % set drawing area
    cla;
    hold on;
    % plot recoding annotation
    if sharedInst.annoStart > 0
        t2 = round((sharedInst.annoStart - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
        if t >= t2
            xv = [t2-0.5 t2-0.5 t+0.5 t+0.5];
        else
            xv = [t-0.5 t-0.5 t2+0.5 t2+0.5];
        end
        yv = [ymin ymax ymax ymin];
        p = patch(xv,yv,'red','FaceAlpha',.2,'EdgeColor','none');
    end
    % plot current time line
    plot([t t], [ymin ymax], ':', 'markersize', 1, 'color', 'r', 'linewidth', 1)  % rodent 1 instead of Cz
    xlim([1 size(yval,1)]);
    ylim([ymin ymax]);
    hold off;
end

%% show short axis data function
function value = showShortAxes(hObject, handles, t, listFly, type, xtickOff)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    img_h = size(sharedInst.bgImage,1);
    img_w = size(sharedInst.bgImage,2);

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
    
    % get data
    switch type
        case 'velocity'
            yval = sharedInst.vxy((t-st):(t+ed),listFly);
            value = sharedInst.vxy(t,listFly);
            ymin = 0;
            ymax = max(yval);
            if ymax < 10
                ymax = 10;
            end
        case 'x velocity'
            yval = sharedInst.keep_data{4}((t-st):(t+ed),listFly);
            value = sharedInst.keep_data{4}(t,listFly);
            ymin = min(yval);
            ymax = max(yval);
        case 'y velocity'
            yval = sharedInst.keep_data{3}((t-st):(t+ed),listFly);
            value = sharedInst.keep_data{3}(t,listFly);
            ymin = min(yval);
            ymax = max(yval);
        case 'sideways'
            yval = sharedInst.sideways((t-st):(t+ed),listFly);
            value = sharedInst.sideways(t,listFly);
            ymin = 0;
            ymax = 1;
        case 'sideways velocity'
            yval = sharedInst.sidewaysVelocity((t-st):(t+ed),listFly);
            value = sharedInst.sidewaysVelocity(t,listFly);
            ymin = 0;
            ymax = max(yval);
            if ymax < 10
                ymax = 10;
            end            
        case 'x'
            yval = sharedInst.keep_data{2}((t-st):(t+ed),listFly);
            value = sharedInst.keep_data{2}(t,listFly);
            ymin = 0;
            ymax = img_w;
        case 'y'
            yval = sharedInst.keep_data{1}((t-st):(t+ed),listFly);
            value = sharedInst.keep_data{1}(t,listFly);
            ymin = 0;
            ymax = img_h;
        case 'angle'
            yval = sharedInst.keep_data{8}((t-st):(t+ed),listFly);
            value = sharedInst.keep_data{8}(t,listFly);
            ymin = -90;
            ymax = 90;
        case 'angle velocity'
            yval = sharedInst.av((t-st):(t+ed),listFly);
            value = sharedInst.av(t,listFly);
            ymin = -90;
            ymax = 90;
        case 'circularity'
            yval = sharedInst.keep_data{7}((t-st):(t+ed),listFly);
            value = sharedInst.keep_data{7}(t,listFly);
            ymin = 0;
            ymax = 1;
        case '--'
            yval = [];
            value = 0;
            ymin = 0;
            ymax = 0;
        otherwise
            data = getappdata(handles.figure1, type); % get data
            if isnan(data)
                yval = [];
                value = 0;
                ymin = 0;
                ymax = 0;
            else
                yval = data((t-st):(t+ed),listFly);
                value = data(t,listFly);
                ymin = min(yval);
                ymax = max(yval);
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
    plot((t-st):(t+ed), yval, 'linewidth', 1.5, 'Color', [.6 .6 1]);
    xlim([t-st t+ed]);
    ylim([ymin ymax]);
    hObject.Box = 'off';
    hObject.Color = [0 .05 .1];
    hObject.FontSize = 8;
    if xtickOff
%        xticks(0); % from 2016b
    end
    % plot recoded annotation
    lastAnno = 0;
    lastAnnoFrame = t-st;
    for i=(t-st):(t+ed)
        if sharedInst.annotation(i,listFly) > 0
            if lastAnno == 0
                % set start
                lastAnno = sharedInst.annotation(i,listFly);
                lastAnnoFrame = i;
            elseif lastAnno ~= sharedInst.annotation(i,listFly)
                plotAnnotationBlock(ymin,ymax,lastAnnoFrame,i,lastAnno);
                lastAnno = sharedInst.annotation(i,listFly);
                lastAnnoFrame = i;
            end
        else
            if lastAnno > 0
                plotAnnotationBlock(ymin,ymax,lastAnnoFrame,i,lastAnno);
            end
            lastAnno = 0;
            lastAnnoFrame = 0;
        end
    end
    if lastAnno > 0
        plotAnnotationBlock(ymin,ymax,lastAnnoFrame,i,lastAnno);
    end
    % plot recoding annotation
    if sharedInst.annoStart > 0
        t2 = round((sharedInst.annoStart - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
        if t >= t2
            xv = [double(t2)-0.5 double(t2)-0.5 double(t)+0.5 double(t)+0.5];
        else
            xv = [double(t)-0.5 double(t)-0.5 double(t2)+0.5 double(t2)+0.5];
        end
        yv = [ymin ymax ymax ymin];
        patch(xv,yv,'red','FaceAlpha',.3,'EdgeColor','none');
    end
    % plot center line
    plot([t t], [ymin ymax], ':', 'markersize', 1.5, 'color', 'r', 'linewidth', 1.5)  % rodent 1 instead of Cz
    type = strrep(type, '_', ' ');
    text(double(t-st+1), double(ymax*0.9+ymin*0.1), type, 'Color', [.6 .6 1], 'FontWeight','bold')
    hold off;
end

function plotAnnotationBlock(ymin, ymax, lastAnnoFrame, i, annoNum)
    xv = [double(lastAnnoFrame)-0.5 double(lastAnnoFrame)-0.5 double(i)-0.5 double(i)-0.5];
    yv = [ymin ymax ymax ymin];
    CLIST = {[1 0 0] [1 1 0] [1 0 1] [0 1 1] [0 1 0] [0 0 1] [1 1 1] [1 .5 .1] [.1 .5 1]};
    cnum = mod(annoNum-1, length(CLIST)) + 1;
    patch(xv,yv,CLIST{cnum},'FaceAlpha',.2,'EdgeColor','none');
end

function recodeAnnotation(handles, key)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    tStart = round((sharedInst.annoStart - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    listFly = sharedInst.listFly;
    
    key = char(strrep({key},'numpad',''));
    recordText = '--';
    switch key
    case 'delete'
        if sharedInst.annoStart > 0
            sharedInst.annoStart = 0;
            sharedInst.annoKey = -1;
        else
            sharedInst.annotation(t, listFly) = 0;
            sharedInst.isModified = 1;
            set(handles.pushbutton6, 'Enable', 'on');
        end
    case 'escape'
        if sharedInst.annoStart > 0
            sharedInst.annoStart = 0;
            sharedInst.annoKey = -1;
        end
    case 'return'
        if sharedInst.annoStart > 0
            annoNum = getAnnotationNum(handles);
            if sharedInst.annoStart <= sharedInst.frameNum
                sharedInst.annotation(tStart:t, listFly) = annoNum;
            else
                sharedInst.annotation(t:tStart, listFly) = annoNum;
            end
            sharedInst.annoStart = 0;
            sharedInst.annoKey = -1;
        end
    otherwise
        if isnumeric(str2num(key))
            if sharedInst.annoStart > 0
                annoNum = getAnnotationNum(handles);
                if sharedInst.annoStart <= sharedInst.frameNum
                    sharedInst.annotation(tStart:t, listFly) = annoNum;
                else
                    sharedInst.annotation(t:tStart, listFly) = annoNum;
                end
                
                if sharedInst.annoKey == str2num(key)
                    sharedInst.annoStart = 0;
                    sharedInst.annoKey = -1;
                else
                    sharedInst.annoStart = sharedInst.frameNum;
                    sharedInst.annoKey = str2num(key);
                    recordText = sharedInst.annoLabel{annoNum};
                end
            else
                sharedInst.annoStart = sharedInst.frameNum;
                sharedInst.annoKey = str2num(key);
                if isempty(sharedInst.annoLabel)
                    recordText = key;
                else
                    if sharedInst.annoKey == 0 || sharedInst.annoKeyMap(sharedInst.annoKey) == 0
                        recordText = 'unknown';
                    else
                        annoNum = sharedInst.annoKeyMap(sharedInst.annoKey);
                        recordText = sharedInst.annoLabel{annoNum};
                    end
                end
            end
            sharedInst.isModified = 1;
            set(handles.pushbutton6, 'Enable', 'on');
        end            
    end
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.text27, 'String', recordText);

    % show long params
    showLongAxesTimeLine(handles, t, listFly);

    % show short params
    showShortAxes(handles.axes4, handles, t, listFly, sharedInst.axesType1, false);
    showShortAxes(handles.axes6, handles, t, listFly, sharedInst.axesType2, true);
end

function annoNum = getAnnotationNum(handles)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if isempty(sharedInst.annoLabel)
        annoNum = sharedInst.annoKey;
    else
        if sharedInst.annoKey == 0
            annoNum = 0;
        else
            annoNum = sharedInst.annoKeyMap(sharedInst.annoKey);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% behavior classifiers

function result = trapezoidThBehaviorClassifier(handles)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    frame_num = size(sharedInst.vxy, 1);
    fly_num = size(sharedInst.vxy, 2);
    result = zeros(frame_num,fly_num);
end

function result = trapezoidNNCluster(handles)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % show nnClusteringStartDialog
    [dlg, flyIDs, numClusters, type1, type2] = nnClusteringStartDialog({});
    delete(dlg);
    if numClusters < 0
        return;
    end
    type3 = 'none'; % TODO: currently dummy
    
    % ----- clustering loop -----
    i = 0;
    while true
        switch type1
        case 'velocity'
            v1str = 'v';
        end
        switch type2
        case 'acceralation'
            v2str = 'acc';
        case 'circularity'
            v2str = 'cir';
        case 'angle_velocity'
            v2str = 'av';
        case 'sideways'
            v2str = 'side';
        case 'sideways_velocity'
            v2str = 'sv';
        end
            
        i = i + 1;
        cname = [v1str '_' v2str '_nn_clustering' num2str(i)];
        % show wait dialog
        hWaitBar = waitbar(0,'processing ...','Name',['clustering ', sharedInst.shuttleVideo.name]);
        if i==1
            % get cells of TrapezoidList {flynum, beginframe, endframe, 0, maxvalue, slope}
            t = getTrapezoidList(handles, type1, type2, type3, flyIDs);
        else
            t = getTrapezoidListInCluster(handles, t, clustered, type1, type2, type3, clusterIDs);
        end
        updateWaitbar(0.2, hWaitBar);
        
        clustered = calcClasteringAndPlot(handles, t, numClusters, type1, type2, type3, cname);
        updateWaitbar(0.5, hWaitBar);

        result = saveClusteredCsvAndShow(handles, t, clustered, type1, type2, type3, [cname '.txt']);
        updateWaitbar(0.8, hWaitBar);

        % add clustering result to axes
        addClusteringResult2Axes(handles, result, [cname '_result']);

        % delete dialog bar
        delete(hWaitBar);
        
        % show nnClusteringContinueDialog
        [dlg, clusterIDs, numClusters, type1, type2] = nnClusteringContinueDialog({});
        delete(dlg);
        if numClusters < 0
            break;
        end
    end
end

function updateWaitbar(rate, handle)
    waitbar(rate, handle, [num2str(int64(100*rate)) ' %']);
end

function t2 = getTrapezoidListInCluster(handles, t, clustered, type1, type2, type3, indexes)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    spikeNum = 0;
    for j = 1:size(indexes,2)
        spikeNum = spikeNum + sum(clustered==indexes(j));
    end
    
    t2 = cell(spikeNum,1);
    k = 1;
    for j = 1:size(clustered,1)
        c = clustered(j);
        if sum(c==indexes) > 0
            t5 = t{j}(1,:);
            fn = t5(1);
            fstart = t5(2);
            fend = t5(3);
            % clustering value 1
            switch type1
            case 'velocity'
                vxy = sharedInst.vxy(fstart:fend, fn);
                f2 = max(vxy);
                f1 = min(vxy);
                v1 = f2;
            end
            % clustering value 2
            switch type2
            case 'acceralation'
                v2 = abs((f2 - f1) / (fend - fstart));
            case 'circularity'
                v2 = (1 - min(sharedInst.ecc(fstart:fend, fn))) * 100;
            case 'angle_velocity'
                v2 = max(sharedInst.av(fstart:fend, fn));
            case 'sideways'
                v2 = max(sharedInst.sideways(fstart:fend, fn)) * 100;
            case 'sideways_velocity'
                v2 = max(sharedInst.sidewaysVelocity(fstart:fend, fn));
            end
            % clustering value 3
            v3 = 0;

            t2{k} = [fn fstart fend t5(4) v1 v2 v3];
            k = k + 1;
        end
    end    
end

function clustered = calcClasteringAndPlot(handles, t, numCluster, type1, type2, type3, cname)
    % clastering
    tsize = size(t,1);
    points = zeros(tsize,3);
    x = zeros(tsize,1);
    y = zeros(tsize,1);
    z = zeros(tsize,1);
    for j = 1:tsize
        points(j,:) = [t{j}(1,5) t{j}(1,6) t{j}(1,7)];
        x(j) = t{j}(1,5);
        y(j) = t{j}(1,6);
        z(j) = t{j}(1,7);
    end
    try
        dist = pdist(points);
        tree = linkage(dist,'average');
        c = cophenet(tree,dist)
    catch e
        errordlg(e.message, 'Error');
        throw(e);
    end
%    clustered = cluster(tree,'cutoff',1.2);
%    clustered = cluster(tree,'maxclust',50);

    % plot Scatter
    f = figure;
    set(f, 'name', [cname, ' scatter']); % set window title
    scatter(x,y);

    % plot dendrogram
    f = figure;
    set(f, 'name', [cname, ' dendrogram']); % set window title
    [h,clustered,outperm] = dendrogram(tree, numCluster);
    ax = gca; % current axes
    ax.FontSize = 6;
end

function result = saveClusteredCsvAndShow(handles, t, clustered, type1, type2, type3, filename)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    frame_num = size(sharedInst.vxy, 1);
    fly_num = size(sharedInst.vxy, 2);
    tsize = size(t,1);

    result = zeros(frame_num,fly_num);
    t2 = cell(tsize,8);
    for j = 1:tsize
        t3 = t{j}(1,:);
        t2(j,:) = {t3(1) t3(2) t3(3) t3(4) t3(5) t3(6) t3(7) clustered(j)};
        result(t3(2):t3(3), t3(1)) = clustered(j);
    end
    T = cell2table(t2);
    header = {'FlyNo', 'StartFrame', 'EndFrame', 'Dmy', type1, type2, type3, 'Cluster'};
    T.Properties.VariableNames = header;

    clusterFileName = [sharedInst.confPath 'output/' filename];
    writetable(T,clusterFileName, 'delimiter', '\t');
    winopen(clusterFileName);
end

function addClusteringResult2Axes(handles, result, itemName)
    listItems = cellstr(get(handles.popupmenu4,'String'));
    added = sum(strcmp(itemName, listItems));
    if added == 0
        listItems = [listItems;{itemName}];
        set(handles.popupmenu4,'String',listItems);
        set(handles.popupmenu5,'String',listItems);
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
        set(handles.popupmenu5,'Value',idx);
        popupmenu5_Callback(handles.popupmenu5,0,handles);
    end
end

function list = getTrapezoidList(handles, type1, type2, type3, flyIDs)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    frame_num = size(sharedInst.vxy, 1);
    fly_num = size(sharedInst.vxy, 2);
    
    % count spike number
    spikeNum = sum(sum(sharedInst.updownVxy~=0)) - fly_num;
%    spikeNum = sum(updown(:,1)~=0) - 1;
    list = cell(spikeNum,1);
    
    j = 1;
    for fn = 1:fly_num
        if length(flyIDs) > 0 && sum(flyIDs==fn) == 0
            continue;
        end
        spikes = find(sharedInst.updownVxy(:,fn) ~= 0);
        for i = 1:(length(spikes)-1)
            % clustering value 1
            switch type1
            case 'velocity'
                f1 = sharedInst.vxy(spikes(i), fn);
                f2 = sharedInst.vxy(spikes(i+1), fn);
                v1 = max([f1 f2]);
            end
            % clustering value 2
            switch type2
            case 'acceralation'
                v2 = abs((f2 - f1) / (spikes(i+1) - spikes(i)));
            case 'circularity'
                v2 = (1 - min(sharedInst.ecc(spikes(i):spikes(i+1), fn))) * 100;
            case 'angle_velocity'
                v2 = max(sharedInst.av(spikes(i):spikes(i+1), fn));
            case 'sideways'
                v2 = max(sharedInst.sideways(spikes(i):spikes(i+1), fn)) * 100;
            case 'sideways_velocity'
                v2 = max(sharedInst.sidewaysVelocity(spikes(i):spikes(i+1), fn));
            end
            % clustering value 3
            v3 = 0;
            
            if ~isnan(v2)
                list{j} = [fn, spikes(i), spikes(i+1), 0, v1, v2, v3];
                j = j + 1;
            end
        end
    end
    if j < spikeNum
        list(j:spikeNum) = [];
    end
end

function list = getNearestNeighbor(trapezoids, hierarchy)
    MAX_DIST = 9999;
    sz = length(trapezoids);
    mat = zeros(sz,sz) + MAX_DIST;
    list = cell(floor(sz/2),1);
    x = zeros(floor(sz/2),1);
    y = zeros(floor(sz/2),1);

    % get distance matrix
    for i=1:(sz-1)
        for j=(i+1):sz
            dx = trapezoids{i}(1,5) - trapezoids{j}(1,5);
            dy = trapezoids{i}(1,6) - trapezoids{j}(1,6);
            mat(i,j) = sqrt(dx*dx + dy*dy);
        end
    end
    % get pairs
    for j = 1:floor(sz/2)
        mat_min = min(min(mat));
        if mat_min == MAX_DIST 
          break;
        end
        min_pair = find(mat==mat_min);
        p = rem(min_pair(1), sz);
        q = floor(min_pair(1) / sz) + 1;
        if trapezoids{p}(1,5) > trapezoids{q}(1,5)
            maxvalue = trapezoids{p}(1,5);
            slope = trapezoids{p}(1,6);
        else
            maxvalue = trapezoids{q}(1,5);
            slope = trapezoids{q}(1,6);
        end
        list{j} = [trapezoids{p}(1,1), p, q, mat(min_pair(1)), maxvalue, slope];
        x(j) = maxvalue;
        y(j) = slope;
        mat(p,:) = MAX_DIST;
        mat(q,:) = MAX_DIST;
        mat(:,p) = MAX_DIST;
        mat(:,q) = MAX_DIST;
    end
    if j < floor(sz/2)
        list(j:spikeNum) = [];
    end
%    T = cell2table(list);
%    writetable(T,['testout' num2str(hierarchy) '.csv'],'WriteVariableNames',false);
end
