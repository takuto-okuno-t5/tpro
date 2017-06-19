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

    % Last Modified by GUIDE v2.5 19-Jun-2017 17:34:45

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
    sharedInst = sharedInstance(0); % get shared instance
    sharedInst.videoPath = videoPath;
    sharedInst.confPath = [videoPath videoFiles{rowNum} '_tpro/'];
    sharedInst.confFileName = confFileName;
    sharedInst.shuttleVideo = VideoReader(strcat(videoPath, records{2}));
    sharedInst.rowNum = rowNum;
    sharedInst.startFrame = records{4};
    sharedInst.endFrame = records{5};
    sharedInst.maxFrame = sharedInst.shuttleVideo.NumberOfFrames;
    sharedInst.frameSteps = records{16};
    sharedInst.frameNum = sharedInst.startFrame;
    sharedInst.stepTime = 0.03;
    sharedInst.showDetectResult = 1;
    sharedInst.showNumber = 1;
    sharedInst.listMode = 1; % all
    sharedInst.listFly = 1;
    sharedInst.lineMode = 2; % tail
    sharedInst.lineLength = 19;

    sharedInst.X = X;
    sharedInst.Y = Y;
    sharedInst.keep_direction_sorted = keep_direction_sorted;
    sharedInst.keep_ecc_sorted = keep_ecc_sorted;
    sharedInst.keep_angle_sorted = keep_angle_sorted;
    sharedInst.keep_areas = keep_areas;
    sharedInst.keep_data = keep_data;

    sharedInst.originalImage = [];

    set(handles.text4, 'String', sharedInst.shuttleVideo.NumberOfFrames);
    set(handles.text6, 'String', sharedInst.shuttleVideo.FrameRate);
    set(handles.slider1, 'Min', 1, 'Max', sharedInst.maxFrame, 'Value', sharedInst.startFrame);
    set(handles.edit1, 'String', sharedInst.frameNum);
    set(handles.checkbox1, 'Value', sharedInst.showNumber);
    set(handles.checkbox2, 'Value', sharedInst.showDetectResult);

    set(handles.pushbutton3, 'Enable', 'off')
    set(handles.popupmenu5, 'Enable', 'off')
    set(handles.edit3, 'Enable', 'on')
    
    set(hObject, 'name', ['Tracking result for ', sharedInst.shuttleVideo.name]); % set window title
    
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

    sharedInstance(sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure

    % show first frame
    showFrameInAxes(hObject, handles, sharedInst.startFrame);
    
    % UIWAIT makes startEndDialog wait for user response (see UIRESUME)
    %uiwait(handles.figure1); % wait for finishing dialog
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    delete(hObject);
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

    sharedInst = sharedInstance(0); % get shared
    sharedInst.frameNum = int64(get(hObject,'Value'));
    sharedInstance(sharedInst); % set shared instance
    
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
    end
end

function figure1_KeyReleaseFcn(hObject, eventdata, handles)
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared

    setappdata(hObject.Parent,'playing',1);
    set(handles.pushbutton2, 'Enable', 'off')
    set(handles.pushbutton3, 'Enable', 'on')
    set(handles.popupmenu2, 'Enable', 'off')
    
    playing = 1;
    frameNum = sharedInst.frameNum;
    while playing
        if frameNum < sharedInst.maxFrame
            frameNum = frameNum + 1;
            
            set(handles.slider1, 'value', frameNum);
            slider1_Callback(handles.slider1, eventdata, handles)
            pause(sharedInst.stepTime);
        else
            pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        end
        playing = getappdata(hObject.Parent,'playing');
    end
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    setappdata(hObject.Parent,'playing',0);
    set(handles.pushbutton2, 'Enable', 'on')
    set(handles.pushbutton3, 'Enable', 'off')
    set(handles.popupmenu2, 'Enable', 'on')
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    if sharedInst.frameNum < sharedInst.maxFrame
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.frameNum+1);
        slider1_Callback(handles.slider1, eventdata, handles)
    end
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    if sharedInst.frameNum > 1
        pushbutton3_Callback(handles.pushbutton3, eventdata, handles);
        set(handles.slider1, 'value', sharedInst.frameNum-1);
        slider1_Callback(handles.slider1, eventdata, handles)
    end
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.stepTime = str2num(contents{get(hObject,'Value')});
    sharedInstance(sharedInst); % set shared instance
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
    sharedInst = sharedInstance(0); % get shared
    sharedInst.showNumber = get(hObject,'Value');
    sharedInstance(sharedInst); % set shared instance
    showFrameInAxes(hObject, handles,sharedInst.frameNum);
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    % hObject    handle to checkbox2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.showDetectResult = get(hObject,'Value');
    sharedInstance(sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.listMode = 1;
    sharedInstance(sharedInst); % set shared instance
    set(handles.popupmenu5, 'Enable', 'off')
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.listMode = 2;
    sharedInstance(sharedInst); % set shared instance
    set(handles.popupmenu5, 'Enable', 'on')
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.lineMode = 1;
    sharedInstance(sharedInst); % set shared instance
    set(handles.edit3, 'Enable', 'off')
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.lineMode = 2;
    sharedInstance(sharedInst); % set shared instance
    set(handles.edit3, 'Enable', 'on')
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

function edit3_Callback(hObject, eventdata, handles)
    % hObject    handle to edit3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    num = str2num(get(handles.edit3, 'String'));
    if isempty(num)
        set(handles.edit3, 'String', sharedInst.lineLength);
    else
        if num < 1 || num > sharedInst.endFrame
            set(handles.edit1, 'String', sharedInst.lineLength);
        else
            sharedInst.lineLength = num;
        end
    end
    sharedInstance(sharedInst); % set shared instance
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
    sharedInst = sharedInstance(0); % get shared
    contents = cellstr(get(hObject,'String'));
    sharedInst.listFly = str2num(contents{get(hObject,'Value')});
    sharedInstance(sharedInst); % set shared instance
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% utility functions

%% working space local shared struct
function shared = sharedInstance(setData)
    persistent pStruct;
    if ~exist('pStruct', 'var') || isempty(pStruct)
        pStruct = struct;
    end
    if ~isempty(pStruct) && isstruct(setData)
        %clear pStruct;
        pStruct = setData;
    end
    shared = pStruct;
end

%% show frame function
function showFrameInAxes(hObject, handles, frameNum)
    axes(handles.axes1); % set drawing area

    sharedInst = sharedInstance(0); % get shared
    if ~isempty(sharedInst.originalImage) && (ndims(sharedInst.originalImage) > 1) % check cache
        img = sharedInst.originalImage;
    else
        img = read(sharedInst.shuttleVideo, frameNum);
        sharedInst.originalImage = img;
    end
    
    % show original image
    cla;
    imshow(img);
    
    % show detection result
    t = sharedInst.frameNum;
    Q_loc_estimateX = sharedInst.keep_data{1};
    Q_loc_estimateY = sharedInst.keep_data{2};
    flyNum = size(Q_loc_estimateX, 2);
    flameMax = size(Q_loc_estimateX, 1);
    listFly = sharedInst.listFly;
    
    if t > size(Q_loc_estimateX,1)
        return;
    end

    % show detection number
    MARKER_SIZE = [1 1]; %marker sizes
    C_LIST = ['r' 'b' 'g' 'c' 'm' 'y'];

    hold on;
    if sharedInst.showDetectResult
        if sharedInst.listMode == 1
            plot(sharedInst.Y{t}(:),sharedInst.X{t}(:),'or'); % the actual detecting
        else
            plot(Q_loc_estimateY(t,listFly),Q_loc_estimateX(t,listFly),'or'); % the actual detecting
        end
    end

    active_num = 0;
    for fn = 1:flyNum
        sz  = mod(fn,2)+1; %pick marker size
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
            plot(tmY, tmX, '-', 'markersize', MARKER_SIZE(sz), 'color', C_LIST(col), 'linewidth', 1)  % rodent 1 instead of Cz

            % show number
            if sharedInst.showNumber
                num_txt = ['  ', num2str(fn)];
                text(Q_loc_estimateY(t,listFly),Q_loc_estimateX(t,listFly),num_txt, 'Color','red')
            end            
        else
            % show tail lines
            if ~isnan(Q_loc_estimateX(t,fn))
                active_num = active_num + 1;

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
                plot(tmY, tmX, '-', 'markersize', MARKER_SIZE(sz), 'color', C_LIST(col), 'linewidth', 1)  % rodent 1 instead of Cz

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

    % show detected count
    set(handles.text8, 'String', active_num);
    guidata(hObject, handles);    % Update handles structure
end
