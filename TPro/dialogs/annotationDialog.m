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

% Last Modified by GUIDE v2.5 04-Feb-2018 02:09:29

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
    load(strcat(confPath,'multi/detect_',filename,'keep_count.mat'));
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
    sharedInst.findType = 0;

    sharedInst.roiNum = records{10};
    sharedInst.gaussH = records{13};
    sharedInst.gaussSigma = records{14};
    sharedInst.binaryTh = records{8} * 100;
    sharedInst.binaryAreaPixel = records{15};
    sharedInst.blobSeparateRate = records{17};
    sharedInst.ignoreEccTh = getVideoConfigValue(records, 43, 0.75);

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
    if exist('keep_mean_blobmajor', 'var')
        sharedInst.wingLength = nanmean(keep_mean_blobmajor) * 0.6;
    end

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
        sharedInst.bgImageDouble = single(bgImage);
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
        sharedInst.roiMaskImage = im2single(img);
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
    showLongAxesTimeLine(handles.axes7, handles, sharedInst.startFrame, sharedInst.listFly);

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
    updownVxy = calcDifferential(bin);
    updownVxy(isnan(updownVxy)) = 0;
    sharedInst.updownVxy = updownVxy;
    sharedInst.dir = calcDir(keep_data{5}, keep_data{6});
    sharedInst.sideways = calcSideways(keep_data{2}, keep_data{1}, keep_data{8});
    sharedInst.sidewaysVelocity = calcSidewaysVelocity(sharedInst.vxy, sharedInst.sideways);
    sharedInst.av = abs(calcAngularVelocity(keep_data{8}));
    sharedInst.ecc = keep_data{7};
    if length(keep_data) > 8
        %beJumpLv = readTproConfig('beJumpLv', 63);
        %[headAngle, keep_data] = fixHeadAndWingAngle(sharedInst.vxy, sharedInst.ecc, sharedInst.dir, keep_data, beJumpLv, sharedInst.ignoreEccTh, sharedInst.fpsNum, sharedInst.startFrame);
        %sharedInst.dir = headAngle;
        %sharedInst.keep_data = keep_data;
        sharedInst.rWingAngle = 180 - mod(sharedInst.dir + 360 - angleAxis2def(keep_data{9}), 360);
        sharedInst.lWingAngle = mod(sharedInst.dir + 360 - angleAxis2def(keep_data{10}), 360) - 180;
        sharedInst.rWingAngleV = [nan(1,size(keep_data{1},2)); diff(sharedInst.rWingAngle)];
        sharedInst.lWingAngleV = [nan(1,size(keep_data{1},2)); diff(sharedInst.lWingAngle)];
    else
        sharedInst.rWingAngle = nan(size(keep_data{1},1), size(keep_data{1},2));
        sharedInst.lWingAngle = nan(size(keep_data{1},1), size(keep_data{1},2));
        sharedInst.rWingAngleV = sharedInst.rWingAngle;
        sharedInst.lWingAngleV = sharedInst.lWingAngle;
    end
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
        case 'n' % find next
            if sharedInst.findType == 1
                findAxesValueNext(handles, eventdata, sharedInst.findAxes, sharedInst.findCondition, sharedInst.findValue);
            end
        case 'p' % find prev
            if sharedInst.findType == 1
                findAxesValuePrev(handles, eventdata, sharedInst.findAxes, sharedInst.findCondition, sharedInst.findValue);
            end
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
    showLongAxesTimeLine(handles.axes7, handles, t, listFly);
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
    showLongAxesTimeLine(handles.axes7, handles, t, listFly);
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
    data = getAxesData(handles, sharedInst.axesType1);
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
    data = getAxesData(handles, sharedInst.axesType2);
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

function data = getAxesData(handles, axesType)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    % get data
    switch axesType
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
    case 'body angle'
        data = sharedInst.keep_data{8};
    case 'angle velocity'
        data = sharedInst.av;
    case 'circularity'
        data = sharedInst.keep_data{7};
    case 'head angle'
        data = sharedInst.dir;
    case 'right wing angle'
        data = sharedInst.rWingAngle;
    case 'left wing angle'
        data = sharedInst.lWingAngle;
    case 'right wing angle v'
        data = sharedInst.rWingAngleV;
    case 'left wing angle v'
        data = sharedInst.lWingAngleV;
    otherwise
        data = getappdata(handles.figure1, axesType);
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
    showLongAxesTimeLine(handles.axes7, handles, sharedInst.startFrame, sharedInst.listFly);

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
    trapezoidNNCluster(handles, @addClusteringResult2Axes);
end

% --------------------------------------------------------------------
function Untitled_20_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_20 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.annotation = trapezoidBehaviorClassifier(handles);
    sharedInst.isModified = 1;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.pushbutton6, 'Enable', 'on');
    % update short axes
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --------------------------------------------------------------------
function Untitled_21_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_21 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    frameNum = size(sharedInst.annotation,1);
    flyNum = size(sharedInst.annotation,2);
    
    sharedInst.annotation = zeros(frameNum, flyNum);
    sharedInst.isModified = 1;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.pushbutton6, 'Enable', 'on');
    % update short axes
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --------------------------------------------------------------------
function Untitled_22_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_22 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    trapezoidFindChase(handles, @addClusteringResult2Axes);
end

% --------------------------------------------------------------------
function Untitled_23_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_23 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    while true 
        [dlg, op, type, axesType, condition, value] = findAnnotationDialog({});
        if op > 0
            sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
            sharedInst.findType = str2num(type);
            sharedInst.findAxes = axesType;
            sharedInst.findCondition = condition;
            sharedInst.findValue = str2num(value);
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
        end
        switch(op)
        case 0
            delete(dlg);
            break;
        case 1
            findAxesValueNext(handles, eventdata, sharedInst.findAxes, condition, sharedInst.findValue)
        case 2
            findAxesValuePrev(handles, eventdata, sharedInst.findAxes, condition, sharedInst.findValue)
        end
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
        quiver(fy, fx, sharedInst.keep_data{5}(t,listFly), sharedInst.keep_data{6}(t,listFly), 0, 'r', 'MaxHeadSize',2, 'LineWidth',0.2)  %arrow

        % show wings
        if length(sharedInst.keep_data) > 8
            leftWingDir = angleToDirection(sharedInst.keep_data{10}(t,listFly), sharedInst.wingLength);
            rightWingDir = angleToDirection(sharedInst.keep_data{9}(t,listFly), sharedInst.wingLength);
            quiver(fy, fx, leftWingDir(:,1)', leftWingDir(:,2)', 0, 'y', 'MaxHeadSize',0, 'LineWidth',0.2)  %line
            quiver(fy, fx, rightWingDir(:,1)', rightWingDir(:,2)', 0, 'g', 'MaxHeadSize',0, 'LineWidth',0.2)  %line
        end
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
                text(double(Q_loc_estimateY(t,listFly)),double(Q_loc_estimateX(t,listFly)),num_txt, 'Color','red')
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
    showLongAxesTimeLine(handles.axes7, handles, t, listFly);

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
        case 'body angle'
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
        case 'head angle'
            yval = sharedInst.dir(:,listFly);
            ymin = 0;
            ymax = 360;
        case 'right wing angle'
            yval = sharedInst.rWingAngle(:,listFly);
            ymin = -30;
            ymax = 180;
        case 'left wing angle'
            yval = sharedInst.lWingAngle(:,listFly);
            ymin = -30;
            ymax = 180;
        case 'right wing angle v'
            yval = sharedInst.rWingAngleV(:,listFly);
            ymin = -90;
            ymax = 90;
        case 'left wing angle v'
            yval = sharedInst.lWingAngleV(:,listFly);
            ymin = -90;
            ymax = 90;
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
    text(10, double(ymax*0.9+ymin*0.1), type, 'Color',[.6 .6 1], 'FontWeight','bold')
    hold off;
end

%%
function showLongAxesTimeLine(hObject, handles, t, listFly)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    yval = sharedInst.vxy(:,listFly);
    ymin = 0;
    ymax = 1;

    hObject.Box = 'off';
    hObject.Color = 'None';
    hObject.FontSize = 1;
    hObject.XMinorTick = 'off';
    hObject.YMinorTick = 'off';
    hObject.XTick = [0];
    hObject.YTick = [0];
    axes(hObject); % set drawing area
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
        case 'body angle'
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
        case 'head angle'
            yval = sharedInst.dir((t-st):(t+ed),listFly);
            value = sharedInst.dir(t,listFly);
            ymin = 0;
            ymax = 360;
        case 'right wing angle'
            yval = sharedInst.rWingAngle((t-st):(t+ed),listFly);
            value = sharedInst.rWingAngle(t,listFly);
            ymin = -30;
            ymax = 180;
        case 'left wing angle'
            yval = sharedInst.lWingAngle((t-st):(t+ed),listFly);
            value = sharedInst.lWingAngle(t,listFly);
            ymin = -30;
            ymax = 180;
        case 'right wing angle v'
            yval = sharedInst.rWingAngleV((t-st):(t+ed),listFly);
            value = sharedInst.rWingAngleV(t,listFly);
            ymin = -90;
            ymax = 90;
        case 'left wing angle v'
            yval = sharedInst.lWingAngleV((t-st):(t+ed),listFly);
            value = sharedInst.lWingAngleV(t,listFly);
            ymin = -90;
            ymax = 90;
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
            xv = [single(t2)-0.5 single(t2)-0.5 single(t)+0.5 single(t)+0.5];
        else
            xv = [single(t)-0.5 single(t)-0.5 single(t2)+0.5 single(t2)+0.5];
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
    xv = [single(lastAnnoFrame)-0.5 single(lastAnnoFrame)-0.5 single(i)-0.5 single(i)-0.5];
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
    showLongAxesTimeLine(handles.axes7, handles, t, listFly);

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

%% show clustering result
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

%% find functions

function findAxesValueNext(handles, eventdata, axesType, condition, value)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    flyId = sharedInst.listFly;
    switch axesType
    case 'axes1'
        type = sharedInst.axesType1;
    case 'axes2'
        type = sharedInst.axesType2;
    end
    data = getAxesData(handles, type);
    if ~isempty(data)
        isFound = false;
        for i=(t+1):size(data,1)
            if ~isempty(flyId) && flyId > 0 && size(data,1)~=1 && size(data,2)~=1
                yval = data(i,flyId);
            elseif ~isempty(flyId) && flyId == 0 && size(data,2)~=1
                yval = nanmean(data(i,:));
            else
                yval = data(i);
            end
            switch condition
            case 'bigger'
                if yval >= value
                    isFound = true;
                end
            case 'equal'
                if yval == value
                    isFound = true;
                end
            case 'smaller'
                if yval <= value
                    isFound = true;
                end
            end
            if isFound
                break;
            end
        end
        frame = (i-1)*sharedInst.frameSteps + sharedInst.startFrame;
        if isFound && ~isempty(frame) && frame <= sharedInst.endFrame
            set(handles.slider1, 'value', frame);
            slider1_Callback(handles.slider1, eventdata, handles)
        else
            axes(handles.axes1); % set drawing area
            text(6, 30, 'can not find a frame.', 'Color',[1 .2 .2])
        end
    end
end

function findAxesValuePrev(handles, eventdata, axesType, condition, value)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    flyId = sharedInst.listFly;
    switch axesType
    case 'axes1'
        type = sharedInst.axesType1;
    case 'axes2'
        type = sharedInst.axesType2;
    end
    data = getAxesData(handles, type);
    if ~isempty(data)
        isFound = false;
        for i=(t-1):-1:1
            if ~isempty(flyId) && flyId > 0 && size(data,1)~=1 && size(data,2)~=1
                yval = data(i,flyId);
            elseif ~isempty(flyId) && flyId == 0 && size(data,2)~=1
                yval = nanmean(data(i,:));
            else
                yval = data(i);
            end
            switch condition
            case 'bigger'
                if yval >= value
                    isFound = true;
                end
            case 'equal'
                if yval == value
                    isFound = true;
                end
            case 'smaller'
                if yval <= value
                    isFound = true;
                end
            end
            if isFound
                break;
            end
        end
        frame = (i-1)*sharedInst.frameSteps + sharedInst.startFrame;
        if isFound && ~isempty(frame) && frame >= 1
            set(handles.slider1, 'value', frame);
            slider1_Callback(handles.slider1, eventdata, handles)
        else
            axes(handles.axes1); % set drawing area
            text(6, 30, 'can not find a frame.', 'Color',[1 .2 .2])
        end
    end
end
