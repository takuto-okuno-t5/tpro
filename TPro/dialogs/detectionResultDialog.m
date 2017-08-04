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

% Last Modified by GUIDE v2.5 02-Aug-2017 13:47:05

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
    sharedInst.showIndexNumber = 0;
    sharedInst.backMode = 1; % movie
    sharedInst.mmPerPixel = records{9};
    sharedInst.roiNum = records{10};
    sharedInst.currentROI = 0;
    sharedInst.axesType1 = 'count';
    sharedInst.isModified = false;
    sharedInst.editMode = 1; % select / add mode
    sharedInst.showPixelScanOneFrame = false;

    % fix old parameters
    if sharedInst.mmPerPixel <= 0
        sharedInst.mmPerPixel = 0.1;
    end
    
    sharedInst.X = X;
    sharedInst.Y = Y;
    sharedInst.keep_angle_sorted = keep_angle_sorted;
    sharedInst.keep_direction_sorted = keep_direction_sorted;
    sharedInst.keep_areas = keep_areas;
    sharedInst.keep_ecc_sorted = keep_ecc_sorted;
    sharedInst.selectX = [];
    sharedInst.selectY = [];
    sharedInst.selectFrame = 0;

    sharedInst.originalImage = [];

    set(handles.text5, 'String', sharedInst.shuttleVideo.NumberOfFrames);
    set(handles.text7, 'String', sharedInst.shuttleVideo.FrameRate);
    set(handles.slider1, 'Min', 1, 'Max', sharedInst.maxFrame, 'Value', sharedInst.startFrame);
    set(handles.edit1, 'String', sharedInst.frameNum);
    set(handles.checkbox2, 'Value', sharedInst.showDetectResult);

    set(handles.pushbutton3, 'Enable', 'off');
    set(handles.pushbutton6, 'Enable', 'off');

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
    countFliesEachROI(handles, X, Y, sharedInst.roiNum, roiMasks, roiMaskImage);

    % load last time data
    resultNames = {'aggr_voronoi_result', 'aggr_ewd_result', 'aggr_pdbscan_result', 'aggr_md_result', 'aggr_hwmd_result', 'aggr_grid_result'};
    for i=1:length(resultNames)
        fname = [sharedInst.confPath 'multi/' resultNames{i} '.mat'];
        if exist(fname, 'file')
            load(fname);
            setappdata(handles.figure1,resultNames{i},result);
            addResult2Axes(handles, result, resultNames{i}, handles.popupmenu4);
        end
    end
    set(handles.popupmenu4,'Value',1);

    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
    
    % show long params
    showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI);
    
    % show first frame
    showFrameInAxes(hObject, handles, sharedInst.startFrame);
end

function countFliesEachROI(handles, X, Y, roiNum, roiMasks, roiMaskImage)
    img_h = size(roiMaskImage,1);
    img_w = size(roiMaskImage,2);
    xsize = size(X, 2);
    flyCounts = zeros(xsize,1);
    for i=1:roiNum
        roiCount = zeros(xsize,1);
        % count flies by each ROI
        for row_count = 1:xsize
            fx = X{row_count}(:);
            fy = Y{row_count}(:);
            flyNum = length(fx);
            flyCounts(row_count) = flyNum;
            roiCount(row_count) = countRoiFly(fy,fx,img_h,img_w,flyNum,roiMasks{i});
        end
        setappdata(handles.figure1,['count_' num2str(i)],roiCount); % set axes data
    end
    setappdata(handles.figure1,'count_0',flyCounts); % set axes data
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
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.isModified
        selection = questdlg('Do you save detection data before closing window?',...
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
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    switch eventdata.Key
    case 'rightarrow'
        pushbutton4_Callback(hObject, eventdata, handles);
    case 'leftarrow'
        pushbutton5_Callback(hObject, eventdata, handles);
    case 'uparrow'
        pushbutton2_Callback(hObject, eventdata, handles);
    case 'downarrow'
        pushbutton3_Callback(hObject, eventdata, handles);
    case 'delete'
        if sharedInst.selectFrame == sharedInst.frameNum && ~isempty(sharedInst.selectX)
            for i=1:length(sharedInst.selectX)
                for j=1:length(sharedInst.X{t})
                    if sharedInst.X{t}(j) == sharedInst.selectX(i) && sharedInst.Y{t}(j) == sharedInst.selectY(i)
                        sharedInst.X{t}(j) = [];
                        sharedInst.Y{t}(j) = [];
                        break;
                    end
                end
            end
            flyCounts = getappdata(handles.figure1,'count_0');
            flyCounts(t) = length(sharedInst.X{t});
            setappdata(handles.figure1,'count_0',flyCounts);
            showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI);

            sharedInst.selectX = [];
            sharedInst.selectY = [];
            sharedInst.selectFrame = 0;
            sharedInst.isModified = true;
            set(handles.pushbutton6, 'Enable', 'on');
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            showFrameInAxes(hObject, handles, sharedInst.frameNum);
        end
    case {'a', 'insert'}
        sharedInst.editMode = 2;
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
        showFrameInAxes(hObject, handles, sharedInst.frameNum);
    case 's'
        sharedInst.editMode = 1;
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
        showFrameInAxes(hObject, handles, sharedInst.frameNum);
    case 'escape'
        sharedInst.editMode = 1;
        sharedInst.selectX = [];
        sharedInst.selectY = [];
        sharedInst.selectFrame = 0;
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
        showFrameInAxes(hObject, handles, sharedInst.frameNum);
    end
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    t = round((sharedInst.frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    if gca == handles.axes1
        cp = get(gca,'CurrentPoint');
        
        % select point
        if sharedInst.editMode == 1
            unselected = false;
            selected = false;
            A = [cp(1,2), cp(1,1)];
            if sharedInst.selectFrame ~= sharedInst.frameNum
                sharedInst.selectX = [];
                sharedInst.selectY = [];
            end
            if ~isempty(sharedInst.selectX)
                B = [sharedInst.selectX, sharedInst.selectY];
                distances = sqrt(sum(bsxfun(@minus, B, A).^2,2));
                [minDist,i] = min(distances);
                if minDist < 9
                    sharedInst.selectX(i) = [];
                    sharedInst.selectY(i) = [];
                    unselected = true;
                end
            end
            if ~unselected
                B = [sharedInst.X{t}(:), sharedInst.Y{t}(:)];                
                distances = sqrt(sum(bsxfun(@minus, B, A).^2,2));
                [minDist,i] = min(distances);
                if minDist < 9
                    sharedInst.selectX = [sharedInst.selectX; B(i,1)];
                    sharedInst.selectY = [sharedInst.selectY; B(i,2)];
                    sharedInst.selectFrame = sharedInst.frameNum;
                    selected = true;
                end
            end
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            % unselect all point
            if ~unselected && ~selected
                sharedInst.selectX = [];
                sharedInst.selectY = [];
                sharedInst.selectFrame = 0;
                setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
            end
        end
        % adding new point
        if sharedInst.editMode == 2
            sharedInst.X{t} = [sharedInst.X{t}(:); cp(1,2)];
            sharedInst.Y{t} = [sharedInst.Y{t}(:); cp(1,1)];
            sharedInst.isModified = true;
            set(handles.pushbutton6, 'Enable', 'on');
            setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

            flyCounts = getappdata(handles.figure1,'count_0');
            flyCounts(t) = flyCounts(t) + 1;
            setappdata(handles.figure1,'count_0',flyCounts);
        end
        % show frame and long axes
        showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI);
        showFrameInAxes(hObject, handles, sharedInst.frameNum);

    elseif gca == handles.axes2 || gca == handles.axes3
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
    showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI);
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

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    img_h = size(sharedInst.originalImage, 1);
    filename = [sprintf('%05d',sharedInst.startFrame) '_' sprintf('%05d',sharedInst.endFrame)];
    dataFileName = [sharedInst.confPath 'multi/detect_' filename '.mat'];

    % load and save detection & tracking
    X = sharedInst.X;
    Y = sharedInst.Y;
    keep_angle_sorted = sharedInst.keep_angle_sorted;
    keep_direction_sorted = sharedInst.keep_direction_sorted;
    keep_areas = sharedInst.keep_areas;
    keep_ecc_sorted = sharedInst.keep_ecc_sorted;
    save(dataFileName,  'X','Y', 'keep_direction_sorted', 'keep_ecc_sorted', 'keep_angle_sorted', 'keep_areas');
    % save keep_count
    keep_count = zeros(1,length(X));
    for i=1:length(X)
        keep_count(i) = length(X{i}(:));
    end
    dataFileName = [sharedInst.confPath 'multi/detect_' filename 'keep_count.mat'];
    save(dataFileName, 'keep_count');

    % save data as text
    for i=1:length(sharedInst.roiMasks)
        outputPath = [sharedInst.confPath 'detect_output/' filename '_roi' num2str(i) '/'];
        dataFileName = [outputPath sharedInst.shuttleVideo.name '_' filename];
        
        saveDetectionResultText(dataFileName, X, Y, i, img_h, sharedInst.roiMasks);
    end
    sharedInst.isModified = false;
    set(handles.pushbutton6, 'Enable', 'off');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
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
    
    showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI);
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
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
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
end

% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % calc local density of voronoi
    if isempty(sharedInst.roiX)
        roiX = [];
        roiY = [];
    else
        roiX = sharedInst.roiX{1};
        roiY = sharedInst.roiY{1};
    end
    result = calcLocalDensityVoronoi(sharedInst.X, sharedInst.Y, sharedInst.roiMaskImage, roiX, roiY);

    % show in plot
    plotWithNewFigure(handles, result, max(result), 0, []);
    
    % add result to axes & show in axes
    cname = 'aggr_voronoi_result';
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
end


% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_9 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % calc local density of ewd
    hFig = [];
    lastMax = 0;
    for mm=10:5:10
        r = mm / sharedInst.mmPerPixel;
        result = calcLocalDensityEwd(sharedInst.X, sharedInst.Y, sharedInst.roiMaskImage, r);

        % show in plot
        if lastMax < max(result)
            lastMax = max(result);
        end
        hFig = plotWithNewFigure(handles, result, lastMax, 0, hFig);
    end

    % add result to axes & show in axes
    cname = 'aggr_ewd_result';
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
end


% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_10 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % considering wall issue. near wall pixels have small density.
    % if pixel count is devided such density, near wall pixels becomes too strong
    % and aggregation index is affected too much. so, we should not use this.
    %{
    mm = 10;
    areaMapFile = [sharedInst.confPath 'multi/areamap_' num2str(mm) '.mat'];
    if exist(areaMapFile,'file')
        load(areaMapFile);
    end
    maxArea = max(max(areaMap));
    areaMap = maxArea ./ areaMap;
    areaMap(isinf(areaMap)) = 0;
%}
    areaMap = sharedInst.roiMaskImage;

    % calc local density of pixel density-based scan
    hFig = [];
    lastMax = 0;
    for mm=10:5:10
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
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
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
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)

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
function Untitled_20_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_20 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [fileName, path, filterIndex] = uigetfile( {  ...
        '*.mat',  'MAT File (*.mat)'}, ...
        'Pick a file', ...
        'MultiSelect', 'off', '.');

    if ~filterIndex
        return;
    end

    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    img_h = size(sharedInst.bgImage,1);

    [X, Y, keep_angle_sorted, keep_direction_sorted, keep_areas, keep_ecc_sorted] = loadCtraxMat(path, fileName, img_h);

    % update result
    sharedInst.X = X;
    sharedInst.Y = Y;
    sharedInst.keep_angle_sorted = keep_angle_sorted;
    sharedInst.keep_direction_sorted = keep_direction_sorted;
    sharedInst.keep_areas = keep_areas;
    sharedInst.keep_ecc_sorted = keep_ecc_sorted;

    % count each ROI fly number
    countFliesEachROI(handles, X, Y, sharedInst.roiNum, sharedInst.roiMasks, sharedInst.roiMaskImage);
    set(handles.popupmenu4,'Value',1);

    h = msgbox({'import ctrax output file successfully!'});

    % update gui
    sharedInst.isModified = true;
    set(handles.pushbutton6, 'Enable', 'on');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
    % show long params
    showLongAxes(handles.axes2, handles, sharedInst.axesType1, sharedInst.currentROI);
end

% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_11_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_11 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    frameNum = sharedInst.frameNum;
    t = round((frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    X = sharedInst.X{t}(:);
    Y = sharedInst.Y{t}(:);

    flyNum = length(X);
    img = sharedInst.roiMaskImage;
    img_h = size(img,1);
    img_w = size(img,2);
    [rr cc] = meshgrid(1:img_w, 1:img_h);

    roiIdx = find(sharedInst.roiMaskImage==1);
    roiLen = length(roiIdx);
    mm = 10;
    r = mm / sharedInst.mmPerPixel;

    % count pixel area
    % considering wall issue. near wall pixels have small density.
    % if pixel count is devided such density, near wall pixels becomes too strong
    % and aggregation index is affected too much. so, we should not use this.
    %{
    areaMapFile = [sharedInst.confPath 'multi/areamap_' num2str(mm) '.mat'];
    if exist(areaMapFile,'file')
        load(areaMapFile);
    else
        tic;
        areaMap = zeros(img_h,img_w);
        for i=1:roiLen
            j = roiIdx(i);
            cx1 = mod(j-1,img_h) + 1;
            cy1 = floor((j-1)/img_h) + 1;
            C = ((rr-cx1).^2 + (cc-cy1).^2) <= r^2;
            m = C .* img;
            areaMap(j) = length(find(m>0));
            if mod(i,100) == 0
                disp(['count pixel area : ' num2str(i)]);
            end
        end
        time = toc;
        disp(['count pixel area time=' num2str(time)]);
        save(areaMapFile, 'areaMap');
    end

    maxArea = max(max(areaMap));
%img0 = (areaMap ./ maxArea);
%img1 = double(sharedInst.bgImage) .* img0;
%imshow(uint8(img1));
    areaMap = maxArea ./ areaMap;
    areaMap(isinf(areaMap)) = 0;
    %}
    [map, counts] = calcLocalDensityPxScanFrame(Y, X, rr, cc, r, img_h, img_w);
    map(sharedInst.roiMaskImage==0) = -1;
%    map = map .* areaMap;

    roiTotal = sum(map(roiIdx));
    mMean = mean(map(roiIdx));
    map2 = map - mMean;
    map2 = map2 .* map2;
    total = sum(map2(roiIdx));
    score = total / roiLen;

    % show in plot
    barWithNewFigure(handles, counts, roiTotal*0.7, 0,  0, flyNum);
    
    sharedInst.showPixelScanOneFrame = true;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, frameNum);

    sharedInst.showPixelScanOneFrame = false;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    % show score
    set(handles.text9, 'String', score);
end

% --------------------------------------------------------------------
function Untitled_12_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_12 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % calc local density of Minimum Distance
    result = calcLocalDensityMd(sharedInst.X, sharedInst.Y, sharedInst.roiMaskImage);
    % show in plot
    plotWithNewFigure(handles, result, max(result), 0, []);
    
    % add result to axes & show in axes
    cname = 'aggr_md_result';
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
end

% --------------------------------------------------------------------
function Untitled_13_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_13 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % calc local density of Harmonically Weighted Mean Distance
    result = calcLocalDensityHwmd(sharedInst.X, sharedInst.Y, sharedInst.roiMaskImage);
    % show in plot
    plotWithNewFigure(handles, result, max(result), 0, []);

    % add result to axes & show in axes
    cname = 'aggr_hwmd_result';
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
end

% --------------------------------------------------------------------
function Untitled_14_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_13 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % calc local density of Harmonically Weighted Mean Distance
    w = 10 / sharedInst.mmPerPixel;
    h = 10 / sharedInst.mmPerPixel;
    result = calcLocalDensityGrid(sharedInst.X, sharedInst.Y, sharedInst.roiMaskImage, w, h);
    % show in plot
    plotWithNewFigure(handles, result, max(result), 0, []);
    
    % add result to axes & show in axes
    cname = 'aggr_grid_result';
    sharedInst.axesType1 = cname;
    addResult2Axes(handles, result, cname, handles.popupmenu4);
    save([sharedInst.confPath 'multi/' cname '.mat'], 'result');
    popupmenu4_Callback(handles.popupmenu4, eventdata, handles)
end

% --------------------------------------------------------------------
function Untitled_15_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_15 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    
    dotNum = 20;
    [X, Y] = calcRandomDots(sharedInst.roiMaskImage, sharedInst.startFrame, sharedInst.endFrame, dotNum);
    sharedInst.X = X;
    sharedInst.Y = Y;

    sharedInst.isModified = true;
    set(handles.pushbutton6, 'Enable', 'on');
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --------------------------------------------------------------------
function Untitled_19_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_19 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % calc local density of Harmonically Weighted Mean Distance
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    cname = [sharedInst.axesType1 '_' num2str(sharedInst.currentROI)];
    data = getappdata(handles.figure1, cname); % get data
    if isempty(data)
        data = getappdata(handles.figure1, sharedInst.axesType1);
    end

    % show in plot
    plotWithNewFigure(handles, data, max(data), 0, []);
end

% --------------------------------------------------------------------
function Untitled_18_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_18 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    cname = [sharedInst.axesType1 '_' num2str(sharedInst.currentROI)];
    data = getappdata(handles.figure1, cname); % get data
    if isempty(data)
        data = getappdata(handles.figure1, sharedInst.axesType1);
    end

    freq = getCountHistgram(data, 100);
    barWithNewFigure(handles, freq, max(freq), 0, 1, length(freq));
end

% --------------------------------------------------------------------
function Untitled_16_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_16 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.editMode = 1;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.frameNum);
end

% --------------------------------------------------------------------
function Untitled_17_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_17 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.editMode = 2;
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
    if sharedInst.backMode == 2
        img = sharedInst.bgImage;
    end

    t = round((frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    % show detection result
    if t > size(sharedInst.X,2) || t < 1
        % show original image
        cla;
        if sharedInst.backMode ~= 3
            imshow(img);
        end
        return;
    end

    X = sharedInst.X{t}(:);
    Y = sharedInst.Y{t}(:);
    fly_num = length(X);
    img_h = size(img,1);
    img_w = size(img,2);

    % show ROIs with color
    if strncmp(sharedInst.axesType1,'pi_roi_', 7)
        C = strsplit(sharedInst.axesType1, '_');
        % to color
        if ismatrix(img)
            img = cat(3,img,img,img);
        end

        redImage = img(:,:,2);
        redImage = uint8(double(redImage).*(imcomplement(sharedInst.roiMasks{str2num(C{3})}*0.1)));
        img(:,:,2) = redImage;
        blueImage = img(:,:,1);
        blueImage = uint8(double(blueImage).*(imcomplement(sharedInst.roiMasks{str2num(C{5})}*0.1)));
        img(:,:,1) = blueImage;
    end
    if strcmp(sharedInst.axesType1,'aggr_pdbscan_result') || sharedInst.showPixelScanOneFrame
        [rr cc] = meshgrid(1:img_w, 1:img_h);
        r = 10 / sharedInst.mmPerPixel;
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
    if strcmp(sharedInst.axesType1,'aggr_grid_result')
        mm = 10;
        w = mm / sharedInst.mmPerPixel;
        h = mm / sharedInst.mmPerPixel;
        gridAreas = getGridAreas(sharedInst.roiMaskImage, img_w, img_h, w, h);
        [result, gridDensity] = calcLocalDensityGridFrame(round(X), round(Y), gridAreas, img_w, img_h, w, h);
        map = zeros(img_h, img_w);
        for i=1:size(gridDensity,2)
            iEnd = min([i*h, img_h]);
            for j=1:size(gridDensity,1)
                jEnd = min([j*w, img_w]);
                map(((i-1)*h+1):iEnd, ((j-1)*w+1):jEnd) = gridDensity(j,i)*w*h*0.2;
            end
        end
        map(sharedInst.roiMaskImage==0) = 0;
        % to color
        if ismatrix(img)
            img = cat(3,img,img,img);
        end
        redImage = img(:,:,2);
        redImage = uint8(double(redImage).*(imcomplement(map)));
        img(:,:,2) = redImage;
    end

    % show original image
    cla;
    if sharedInst.backMode ~= 3
        imshow(img);
    end

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
        if ~isempty(sharedInst.selectX) && sharedInst.selectFrame == frameNum
            plot(sharedInst.selectY,sharedInst.selectX,'or','Color', [.3 1 .3]);
        end
%        keep_direction = sharedInst.keep_direction_sorted{t}(:,:);
%        quiver(Y, X, keep_direction(1,:)', keep_direction(2,:)', 0.3, 'r', 'MaxHeadSize',0.2, 'LineWidth',0.2)  %arrow
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
    % show edit mode
    if sharedInst.editMode > 0
        switch sharedInst.editMode
            case 1
                modeText = 'MODE: select   please click to select detection point.';
            case 2
                modeText = 'MODE: add      please click to add new detection point.';
        end
        text(6, 12, modeText, 'Color',[1 .4 .4])
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
function showLongAxes(hObject, handles, type, roi)
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
    % plot selected frame
    frameNum = sharedInst.selectFrame;
    if frameNum > 0 && ~isempty(sharedInst.selectX)
        t2 = round((frameNum - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
        plot([t2 t2], [ymin ymax], '-', 'markersize', 1, 'color', [.1 .7 .1], 'linewidth', 1)  % rodent 1 instead of Cz
    end
    % plot current time line
    plot([t t], [ymin ymax], ':', 'markersize', 1, 'color', 'r', 'linewidth', 1)  % rodent 1 instead of Cz
    xlim([1 size(yval,1)]);
    ylim([ymin ymax]);
    hold off;
end
