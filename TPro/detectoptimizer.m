
function varargout = detectoptimizer(varargin)
    % DETECTOPTIMIZER MATLAB code for detectoptimizer.fig
    %      DETECTOPTIMIZER, by itself, creates a new DETECTOPTIMIZER or raises the existing
    %      singleton*.
    %
    %      H = DETECTOPTIMIZER returns the handle to a new DETECTOPTIMIZER or the handle to
    %      the existing singleton*.
    %
    %      DETECTOPTIMIZER('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in DETECTOPTIMIZER.M with the given input arguments.
    %
    %      DETECTOPTIMIZER('Property','Value',...) creates a new DETECTOPTIMIZER or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before detectoptimizer_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to detectoptimizer_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help detectoptimizer

    % Last Modified by GUIDE v2.5 13-May-2017 03:13:11

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @detectoptimizer_OpeningFcn, ...
                       'gui_OutputFcn',  @detectoptimizer_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT

% --- Executes just before detectoptimizer is made visible.
function detectoptimizer_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to detectoptimizer (see VARARGIN)

    % Choose default command line output for detectoptimizer
    handles.output = hObject;
    guidata(hObject, handles);    % Update handles structure

    % UIWAIT makes detectoptimizer wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

    % load config file
    configFile = dir('./input/input_video_control.xlsx');
    if ~isempty(configFile)
        [num,txt,raw] = xlsread('./input/input_video_control.xlsx');
    else
        disp('please put input xlsx files into the folder')
        return
    end

    % load environment value
    if size(varargin, 1) > 0
        rowNum = int64(str2num(char(varargin{1}(1))));
        handles.isArgin = true;
    else
        rowNum = 1;
        handles.isArgin = false;
    end
    if isempty(rowNum), rowNum = 1; end

    % initialize GUI
    sharedInst = sharedInstance(0); % get shared instance
    sharedInst.shuttleVideo = VideoReader(strcat('../input_share/', char(txt(rowNum+1,2))));
    sharedInst.rowNum = rowNum;
    sharedInst.imageMode = 1;
    sharedInst.showDetectResult = 1;
    sharedInst.showDirection = 1;
    sharedInst.showIndexNumber = 0;
    sharedInst.startFrame = num(rowNum, 4);
    sharedInst.endFrame = num(rowNum, 5);
    sharedInst.maxFrame = sharedInst.shuttleVideo.NumberOfFrames;
    sharedInst.frameSteps = num(rowNum, 16);
    sharedInst.frameNum = sharedInst.startFrame;
    sharedInst.gaussH = num(rowNum,13);
    sharedInst.gaussSigma = num(rowNum,14);
    sharedInst.binaryTh = num(rowNum,8) * 100;
    sharedInst.binaryAreaPixel = num(rowNum,15);
    sharedInst.blobSeparateRate = num(rowNum,17);
    sharedInst.isModified = false;

    sharedInst.originalImage = [];
    sharedInst.step2Image = [];
    sharedInst.step3Image = [];
    sharedInst.step4Image = [];
    sharedInst.detectedPointX = [];
    sharedInst.detectedPointY = [];

    set(handles.text9, 'String', sharedInst.shuttleVideo.NumberOfFrames);
    set(handles.text11, 'String', sharedInst.shuttleVideo.FrameRate);
    set(handles.slider1, 'Min', 1, 'Max', sharedInst.maxFrame, 'Value', sharedInst.startFrame);
    set(handles.checkbox1, 'Value', sharedInst.showDetectResult);
    set(handles.pushbutton4, 'Enable', 'off')
    set(handles.edit1, 'String', sharedInst.startFrame);
    set(handles.edit2, 'String', sharedInst.endFrame);
    set(handles.edit3, 'String', sharedInst.frameSteps);
    set(handles.edit4, 'String', sharedInst.frameNum);

    set(hObject, 'name', ['Detection Optimizer for ', sharedInst.shuttleVideo.name]); % set window title

    % initialize spinner
    pos = getpixelposition(handles.text2, true);
    spinnerModel = javax.swing.SpinnerNumberModel(sharedInst.gaussH, 0, 100, 1);
    handles.jhSpinner1 = addLabeledSpinner(spinnerModel, [pos(1)+46,pos(2)-4,60,20], @spinner_Callback1);

    pos = getpixelposition(handles.text3, true);
    spinnerModel = javax.swing.SpinnerNumberModel(sharedInst.gaussSigma, 0, 20, 1);
    handles.jhSpinner2 = addLabeledSpinner(spinnerModel, [pos(1)+40,pos(2)-4,60,20], @spinner_Callback2);

    pos = getpixelposition(handles.text4, true);
    spinnerModel = javax.swing.SpinnerNumberModel(sharedInst.binaryTh, 0, 100, 5);
    handles.jhSpinner3 = addLabeledSpinner(spinnerModel, [pos(1)+90,pos(2)-4,60,20], @spinner_Callback3);

    pos = getpixelposition(handles.text5, true);
    spinnerModel = javax.swing.SpinnerNumberModel(sharedInst.binaryAreaPixel, 0, 500, 1);
    handles.jhSpinner4 = addLabeledSpinner(spinnerModel, [pos(1)+70,pos(2)-4,60,20], @spinner_Callback4);

    % load background image
    videoName = sharedInst.shuttleVideo.name;
    bgImageFile = strcat('./bg_output/',videoName,'/',videoName,'bg.png');
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
    roiFileName = strcat('./roi/',videoName,'/',videoName,'_roi.png');
    if exist(roiFileName, 'file')
        img = imread(roiFileName);
        sharedInst.roiMaskImage = im2double(img);
    else
        sharedInst.roiMaskImage = [];
    end
    
    sharedInstance(sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure

    % show first frame
    showFrameInAxes(hObject, handles, sharedInst.imageMode, sharedInst.startFrame);

    %% internal function to add a spinner
    function jhSpinner = addLabeledSpinner(model, pos, callbackFunc)
        % Set the spinner control
        jSpinner = com.mathworks.mwswing.MJSpinner(model);
        jhSpinner = javacomponent(jSpinner, pos, handles.figure1);
        %jhSpinner.setToolTipText('<html>This spinner is editable, but only the<br/>preconfigured values can be entered')
        jEditor = javaObject('javax.swing.JSpinner$NumberEditor', jhSpinner, '#');
        jhSpinner.setEditor(jEditor);
        set(jhSpinner,'StateChangedCallback', callbackFunc);
    end

    function spinner_Callback1(jSpinner, jEventData)
        persistent pLock
        try
            % check lock
            if ~isempty(pLock),  return;  end
            pLock = 1;

            % get handles structure
            hFig = ancestor(hObject, 'figure');
            hdl = guidata(hFig);

            % get spinner data for the spinners
            sharedInst = sharedInstance(0); % get shared instance
            sharedInst.gaussH = jSpinner.getValue;
            sharedInst.step2Image = [];      % filter param is changed, so clear cache
            sharedInst.step3Image = [];
            sharedInst.step4Image = [];
            sharedInst.detectedPointX = [];
            sharedInst.detectedPointY = [];
            sharedInst.isModified = true;
            sharedInstance(sharedInst); % set shared instance
            set(hdl.pushbutton4, 'Enable', 'on');
            showFrameInAxes(hObject, hdl, sharedInst.imageMode, sharedInst.frameNum);
        catch
            % nothing to do
        end
        pLock = [];
    end

    function spinner_Callback2(jSpinner, jEventData)
        persistent pLock
        try
            % check lock
            if ~isempty(pLock),  return;  end
            pLock = 1;

            % get handles structure
            hFig = ancestor(hObject, 'figure');
            hdl = guidata(hFig);

            % get spinner data for the spinners
            sharedInst = sharedInstance(0); % get shared instance
            sharedInst.gaussSigma = jSpinner.getValue;
            sharedInst.step2Image = [];      % filter param is changed, so clear cache
            sharedInst.step3Image = [];
            sharedInst.step4Image = [];
            sharedInst.detectedPointX = [];
            sharedInst.detectedPointY = [];
            sharedInst.isModified = true;
            sharedInstance(sharedInst); % set shared instance
            set(hdl.pushbutton4, 'Enable', 'on');
            showFrameInAxes(hObject, hdl, sharedInst.imageMode, sharedInst.frameNum);
        catch
            % nothing to do
        end
        pLock = [];
    end

    function spinner_Callback3(jSpinner, jEventData)
        persistent pLock
        try
            % check lock
            if ~isempty(pLock),  return;  end
            pLock = 1;

            % get handles structure
            hFig = ancestor(hObject, 'figure');
            hdl = guidata(hFig);

            % get spinner data for the spinners
            sharedInst = sharedInstance(0); % get shared instance
            sharedInst.binaryTh = jSpinner.getValue;
            sharedInst.step2Image = [];      % filter param is changed, so clear cache
            sharedInst.step3Image = [];
            sharedInst.step4Image = [];
            sharedInst.detectedPointX = [];
            sharedInst.detectedPointY = [];
            sharedInst.isModified = true;
            sharedInstance(sharedInst); % set shared instance
            set(hdl.pushbutton4, 'Enable', 'on');
            showFrameInAxes(hObject, hdl, sharedInst.imageMode, sharedInst.frameNum);
        catch
            % nothing to do
        end
        pLock = [];
    end

    function spinner_Callback4(jSpinner, jEventData)
        persistent pLock
        try
            % check lock
            if ~isempty(pLock),  return;  end
            pLock = 1;

            % get handles structure
            hFig = ancestor(hObject, 'figure');
            hdl = guidata(hFig);

            % get spinner data for the spinners
            sharedInst = sharedInstance(0); % get shared instance
            sharedInst.binaryAreaPixel = jSpinner.getValue;
            sharedInst.step2Image = [];      % filter param is changed, so clear cache
            sharedInst.step3Image = [];
            sharedInst.step4Image = [];
            sharedInst.detectedPointX = [];
            sharedInst.detectedPointY = [];
            sharedInst.isModified = true;
            sharedInstance(sharedInst); % set shared instance
            set(hdl.pushbutton4, 'Enable', 'on');
            showFrameInAxes(hObject, hdl, sharedInst.imageMode, sharedInst.frameNum);
        catch
            % nothing to do
        end
        pLock = [];
    end

    % UIWAIT makes startEndDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1); % wait for finishing dialog
end

%% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    sharedInst = sharedInstance(0); % get shared
    if sharedInst.isModified
        selection = questdlg('Do you save configuration before closing Detection Optimizer before?',...
                             'Confirmation',...
                             'Yes','No','Cancel','Yes');
        switch selection
        case 'Cancel'
            return;
        case 'Yes'
            saveExcelConfigurationFile(handles);
        case 'No'
            % nothing todo
        end
    end
    uiresume(handles.figure1);
end

%% --- Outputs from this function are returned to the command line.
function varargout = detectoptimizer_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;

    if ~handles.isArgin
        delete(hObject); % only delete when it launched directly.
    end
end

%% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    sharedInst = sharedInstance(0); % get shared
    sharedInst.frameNum = int64(get(hObject,'Value'));
    sharedInst.originalImage = [];      % frame is changed, so clear cache
    sharedInst.step2Image = [];
    sharedInst.step3Image = [];
    sharedInst.step4Image = [];
    sharedInst.detectedPointX = [];
    sharedInst.detectedPointY = [];
    sharedInstance(sharedInst); % set shared instance

    set(handles.edit4, 'String', sharedInst.frameNum);
    guidata(hObject, handles);    % Update handles structure
    showFrameInAxes(hObject, handles, sharedInst.imageMode, sharedInst.frameNum);
end

%% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

%% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.imageMode = 1;
    sharedInstance(sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.imageMode, sharedInst.frameNum);
end

%% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.imageMode = 2;
    sharedInstance(sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.imageMode, sharedInst.frameNum);
end

%% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.imageMode = 3;
    sharedInstance(sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.imageMode, sharedInst.frameNum);
end

%% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.imageMode = 4;
    sharedInstance(sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.imageMode, sharedInst.frameNum);
end

%% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
    % hObject    handle to checkbox1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.showDetectResult = get(hObject,'Value');
    sharedInstance(sharedInst); % set shared instance
    if ~sharedInst.showDetectResult
        set(handles.text16, 'String', '--');
        guidata(hObject, handles);    % Update handles structure
    end
    showFrameInAxes(hObject, handles, sharedInst.imageMode, sharedInst.frameNum);
end

%% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    % hObject    handle to checkbox2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    sharedInst.showDirection = get(hObject,'Value');
    if ~sharedInst.showDirection
        sharedInst.detectedDirection = [];
    else
        sharedInst.detectedPointX = []; % because it is necessary to calcurate direction again
    end
    sharedInstance(sharedInst); % set shared instance
    showFrameInAxes(hObject, handles, sharedInst.imageMode, sharedInst.frameNum);
end

%% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    if ~isempty(sharedInst.bgImage)
        imshow(sharedInst.bgImage);
    end
end

%% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    if ~isempty(sharedInst.roiMaskImage)
        imshow(sharedInst.roiMaskImage);
    end
end

%% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % save excel setting data
    saveExcelConfigurationFile(handles);
end

%% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure');
    figure1_CloseRequestFcn(hFig, eventdata, handles);
end

%%
function edit1_Callback(hObject, eventdata, handles)
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    num = str2num(get(handles.edit1, 'String'));
    if isempty(num)
        set(handles.edit1, 'String', sharedInst.startFrame);
    else
        if num < 1 || num > sharedInst.endFrame
            set(handles.edit1, 'String', sharedInst.startFrame);
        else
            sharedInst.startFrame = num;
            sharedInst.isModified = true;
            set(handles.pushbutton4, 'Enable', 'on');
        end
    end
    sharedInstance(sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
end

%% --- Executes during object creation, after setting all properties.
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

%%
function edit2_Callback(hObject, eventdata, handles)
    % hObject    handle to edit2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    num = str2num(get(handles.edit2, 'String'));
    if isempty(num)
        set(handles.edit2, 'String', sharedInst.endFrame);
    else
        if num < sharedInst.startFrame || num > sharedInst.maxFrame
            set(handles.edit2, 'String', sharedInst.endFrame);
        else
            sharedInst.endFrame = num;
            sharedInst.isModified = true;
            set(handles.pushbutton4, 'Enable', 'on');
        end
    end
    sharedInstance(sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
end

%% --- Executes during object creation, after setting all properties.
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

%%
function edit3_Callback(hObject, eventdata, handles)
    % hObject    handle to edit3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    num = str2num(get(handles.edit3, 'String'));
    if isempty(num)
        set(handles.edit3, 'String', sharedInst.frameSteps);
    else
        if num < 1 || num > (sharedInst.endFrame - sharedInst.startFrame)
            set(handles.edit3, 'String', sharedInst.frameSteps);
        else
            sharedInst.frameSteps = num;
            sharedInst.isModified = true;
            set(handles.pushbutton4, 'Enable', 'on');
        end
    end
    sharedInstance(sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
end

%% --- Executes during object creation, after setting all properties.
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

%%
function edit4_Callback(hObject, eventdata, handles)
    % hObject    handle to edit4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    frame = str2double(get(hObject,'String'));
    set(handles.slider1, 'value', frame);
    slider1_Callback(handles.slider1, eventdata, handles)
end

%% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on key release with focus on figure1 and none of its controls.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
    %	Key: name of the key that was released, in lower case
    %	Character: character interpretation of the key(s) that was released
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    if strcmp(eventdata.Key, 'rightarrow')
        if sharedInst.frameNum < sharedInst.maxFrame
            set(handles.slider1, 'value', sharedInst.frameNum+1);
            slider1_Callback(handles.slider1, eventdata, handles)
        end
    elseif strcmp(eventdata.Key, 'leftarrow')
        if sharedInst.frameNum > 1
            set(handles.slider1, 'value', sharedInst.frameNum-1);
            slider1_Callback(handles.slider1, eventdata, handles)
        end
    end
end

%% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = sharedInstance(0); % get shared
    boxSize = findFlyImageBoxSize(sharedInst.startFrame, sharedInst.endFrame);
    
%outputFlyImageFiles(200,300,boxSize);
%return;

    figure;
    blobNumber = size(sharedInst.detectedPointY,1);
    for i = 1:blobNumber
        switch sharedInst.imageMode
            case 1
                image = sharedInst.originalImage;
            case 2
                image = sharedInst.step2Image;
            case 3
                image = sharedInst.step3Image;
            case 4
                image = sharedInst.step4Image;
        end
        trimmedImage = getOneFlyBoxImage(image, sharedInst.detectedPointX, sharedInst.detectedPointY, sharedInst.detectedDirection, boxSize, i);

        subplot(8, 8, i);
        imshow(trimmedImage);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% filter and detect functions

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

%% image calcuration 
function outimage = applyBackgroundSub(img)
    sharedInst = sharedInstance(0); % get shared
    grayImg = rgb2gray(img);
    if ~isempty(sharedInst.bgImageMean)
        grayImg = grayImg + (sharedInst.bgImageMean - mean(mean(grayImg)));
        grayImageDouble = double(grayImg);
        img = sharedInst.bgImageDouble - grayImageDouble;
        img = uint8(img);
        img = imcomplement(img);
    else
        img = grayImg;
    end
    outimage = img;
end

%%
function outimage = applyFilterAndRoi(img)
    % apply gaussian filter
    sharedInst = sharedInstance(0); % get shared
    img = PD_blobfilter(img, sharedInst.gaussH, sharedInst.gaussSigma);

    % apply ROI
    if ~isempty(sharedInst.roiMaskImage)
        img = img .* sharedInst.roiMaskImage;
    end
    outimage = img;
end

%%
function outimage = applyBinarizeAndAreaMin(img)
    sharedInst = sharedInstance(0); % get shared
    img = im2bw(img, sharedInst.binaryTh / 100);
    outimage = bwareaopen(img, sharedInst.binaryAreaPixel);   % delete blob that has area less than 50
end

%% show frame function
function showFrameInAxes(hObject, handles, imageMode, frameNum)
    axes(handles.axes1); % set drawing area

    sharedInst = sharedInstance(0); % get shared
    if ~isempty(sharedInst.originalImage) && (ndims(sharedInst.originalImage) > 1) % check cache
        img = sharedInst.originalImage;
    else
        img = read(sharedInst.shuttleVideo, frameNum);
        sharedInst.originalImage = img;
    end
    % show original image
    if imageMode == 1
        sharedInstance(sharedInst); % update shared
        if sharedInst.showDetectResult
            showDetectResultInAxes(hObject, handles, img);
        else
            imshow(img);
        end
        return;
    end
    
    % background substraction
    if ~isempty(sharedInst.step2Image) && (ndims(sharedInst.step2Image) > 1) % check cache
        img = sharedInst.step2Image;
    else
        img = applyBackgroundSub(img);
        sharedInst.step2Image = img;
    end
    if imageMode == 2
        sharedInstance(sharedInst); % update shared
        if sharedInst.showDetectResult
            showDetectResultInAxes(hObject, handles, img);
        else
            imshow(img);
        end
        return;
    end
    
    % filter and Roi
    if ~isempty(sharedInst.step3Image) && (ndims(sharedInst.step3Image) > 1) % check cache
        img = sharedInst.step3Image;
    else
        img = applyFilterAndRoi(img);
        sharedInst.step3Image = img;
    end
    if imageMode == 3
        sharedInstance(sharedInst); % update shared
        if sharedInst.showDetectResult
            showDetectResultInAxes(hObject, handles, img);
        else
            imshow(img);
        end
        return;
    end

    % binarize
    if ~isempty(sharedInst.step4Image) && (ndims(sharedInst.step4Image) > 1) % check cache
        img = sharedInst.step4Image;
    else
        img = applyBinarizeAndAreaMin(img);
        sharedInst.step4Image = img;
    end
    
    sharedInstance(sharedInst); % update shared
    if sharedInst.showDetectResult
        showDetectResultInAxes(hObject, handles, img);
    else
        imshow(img);
    end
end

%% get image which includes index text
function [ numbersImage ] = getNumberDrawnImage(img, detectedPointX, detectedPointY)
    if ~islogical(img)
        num = size(detectedPointX);
        for i = 1:num
            position = [detectedPointX(i)+4 detectedPointY(i)-24];
            img = insertText(img, position, i, 'FontSize',18, 'TextColor','red', 'BoxOpacity',0);
        end
    end
    numbersImage = img;
end

%% show result
function showDetectResultInAxes(hObject, handles, frameImage)
    sharedInst = sharedInstance(0); % get shared
    % check cache first. if it exists, just plot
    if ~isempty(sharedInst.detectedPointX)
        if sharedInst.showIndexNumber
            frameImage = getNumberDrawnImage(frameImage, sharedInst.detectedPointX, sharedInst.detectedPointY);
        end
        imshow(frameImage);

        hold on;
        plot(sharedInst.detectedPointX(:), sharedInst.detectedPointY(:), 'or'); % the updated actual tracking

        if sharedInst.showDirection && ~isempty(sharedInst.detectedDirection)
            quiver(sharedInst.detectedPointX(:), sharedInst.detectedPointY(:), sharedInst.detectedDirection(1,:)', sharedInst.detectedDirection(2,:)', 0.3, 'r', 'MaxHeadSize',0.2, 'LineWidth',0.2)  %arrow
        end
        return;
    end

    % check if image is already calclated. if not, calclate it.
    if isempty(sharedInst.step4Image)
        img = sharedInst.originalImage;
        if ~isempty(sharedInst.step2Image) && (ndims(sharedInst.step2Image) > 1) % check cache
            img = sharedInst.step2Image;
        else
            img = applyBackgroundSub(img);
            sharedInst.step2Image = img;
        end
        
        if ~isempty(sharedInst.step3Image) && (ndims(sharedInst.step3Image) > 1) % check cache
            img = sharedInst.step3Image;
        else
            img = applyFilterAndRoi(img);
            sharedInst.step3Image = img;
        end

        if isempty(sharedInst.step4Image)
            img = applyBinarizeAndAreaMin(img);
            sharedInst.step4Image = img;
        end
        sharedInstance(sharedInst); % update shared
    end
    
    [ blobPointX, blobPointY, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center(sharedInst.step3Image, sharedInst.step4Image, sharedInst.binaryTh, sharedInst.blobSeparateRate);

    % draw image
    if sharedInst.showIndexNumber
        frameImage = getNumberDrawnImage(frameImage, blobPointX, blobPointY);
    end
    imshow(frameImage);

    % show detection result    
    hold on;
    plot(blobPointX(:), blobPointY(:), 'or'); % the updated actual tracking

    % calc and draw direction
    if sharedInst.showDirection
        keep_direction = PD_direction(blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient);
        quiver(blobPointX(:), blobPointY(:), keep_direction(1,:)', keep_direction(2,:)', 0.3, 'r', 'MaxHeadSize',0.2, 'LineWidth',0.2)  %arrow
    end
    
    % store in cache
    sharedInst.detectedPointX = blobPointX;
    sharedInst.detectedPointY = blobPointY;
    sharedInst.detectedDirection = keep_direction;
    sharedInstance(sharedInst); % update shared

    % update gui
    set(handles.text16, 'String', size(blobPointX,1));
    guidata(hObject, handles);  % Update handles structure
end

%%
function saveExcelConfigurationFile(handles)
    %% save excel configuration file
    sharedInst = sharedInstance(0); % get shared
    name = sharedInst.shuttleVideo.Name;
    frameNum = sharedInst.shuttleVideo.NumberOfFrames;
    frameRate = sharedInst.shuttleVideo.FrameRate;

    B = {'1', name, '', num2str(sharedInst.startFrame), num2str(sharedInst.endFrame), frameNum, frameRate, ...
        num2str(sharedInst.binaryTh / 100), '0', '1', '200', '0', ...
        num2str(sharedInst.gaussH), num2str(sharedInst.gaussSigma), num2str(sharedInst.binaryAreaPixel), ...
        num2str(sharedInst.frameSteps), '0.5'};

    outputFileName = './input/input_video_control.xlsx';
    status = xlswrite(outputFileName,B,1,['A',num2str(sharedInst.rowNum+1)]);
    if status 
        sharedInst.isModified = false;
        set(handles.pushbutton4, 'Enable', 'off');
    end
    sharedInstance(sharedInst); % update shared
end

%
function [ blobPointX, blobPointY, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center(blob_img, blob_img_logical, blob_threshold, blobSeparateRate)
    H = vision.BlobAnalysis;
    H.MaximumCount = 100;
    H.MajorAxisLengthOutputPort = 1;
    H.MinorAxisLengthOutputPort = 1;
    H.OrientationOutputPort = 1;
    H.EccentricityOutputPort = 1;

    [origAreas, origCenterPoints, origBoxes, origMajorAxis, origMinorAxis, origOrient, origEcc] = step(H, blob_img_logical);

    labeledImage = bwlabel(blob_img_logical);   % label the image

    blobAvgSize = mean(origAreas);
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

                blob_img_trimmed2 = im2bw(blob_img_trimmed, blob_threshold2);
                [trimmedAreas, trimmedCenterPoints, trimmedBoxes, trimmedMajorAxis, trimmedMinorAxis, trimmedOrient, trimmedEcc] = step(H, blob_img_trimmed2);

                if expect_num == size(trimmedAreas, 1) % change from <= to == 20161015
                    x_choose = trimmedCenterPoints(1:expect_num,1);
                    y_choose = trimmedCenterPoints(1:expect_num,2);    % choose expect_num according to area (large)
                    blobPointX = [blobPointX ; x_choose + double(rect(1))];
                    blobPointY = [blobPointY ; y_choose + double(rect(2))];
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
            blobPointX = [blobPointX ; origCenterPoints(i,1)];
            blobPointY = [blobPointY ; origCenterPoints(i,2)];
            blobAreas = [blobAreas ; origAreas(i)];
            blobCenterPoints = [blobCenterPoints ; origCenterPoints(i,:)];
            blobBoxes = [blobBoxes ; origBoxes(i,:)];
            blobMajorAxis = [blobMajorAxis ; origMajorAxis(i)];
            blobMinorAxis = [blobMinorAxis ; origMinorAxis(i)];
            blobOrient = [blobOrient ; origOrient(i)];
            blobEcc = [blobEcc ; origEcc(i)];
        end
    end
end

%%
function [ outputImage ] = PD_blobfilter( image, h, sigma )
    %   h & sigma : the bigger, the larger the blob can be found
    %   example : >>subplot(121); imagesc(h) >>subplot(122); mesh(h)
    %   >>colormap(jet)

    %   laplacian of a gaussian (LOG) template
    logKernel = fspecial('log', h, sigma);
    %   2d convolution
    outputImage = conv2(image, logKernel, 'same');
end

%%

function boxSize = findFlyImageBoxSize(startFrame, endFrame)
    sharedInst = sharedInstance(0); % get shared

    step = int64((endFrame - startFrame) / 12);
    count = 0;
    sumMajorAxis = 0;
    for frameNum = startFrame+step:step:endFrame-step % just use middle flames of movie
        img = read(sharedInst.shuttleVideo, frameNum);
        step2Image = applyBackgroundSub(img);
        step3Image = applyFilterAndRoi(step2Image);
        step4Image = applyBinarizeAndAreaMin(step3Image);

        [ blobPointX, blobPointY, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center(step3Image, step4Image, sharedInst.binaryTh, sharedInst.blobSeparateRate);
        sumMajorAxis = sumMajorAxis + mean(blobMajorAxis);
        count = count + 1;
    end
    meanMajorAxis = sumMajorAxis / count;
    boxSize = int64((meanMajorAxis * 1.5) / 8) * 8;
end

%%
function outputFlyImageFiles(startFrame, endFrame, boxSize)
    sharedInst = sharedInstance(0); % get shared

    % create output directory
    path = strcat('./detect_flies/', sharedInst.shuttleVideo.name);
    mkdir(path);

    for frameNum = startFrame:endFrame
        img = read(sharedInst.shuttleVideo, frameNum);
        step2Image = applyBackgroundSub(img);
        step3Image = applyFilterAndRoi(step2Image);
        step4Image = applyBinarizeAndAreaMin(step3Image);

        [ blobPointX, blobPointY, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center(step3Image, step4Image, sharedInst.binaryTh, sharedInst.blobSeparateRate);
        flyDirection = PD_direction(blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient);

        blobNumber = size(blobPointY,1);
        for i = 1:blobNumber
            trimmedImage = getOneFlyBoxImage(step2Image, blobPointX, blobPointY, flyDirection, boxSize, i);
            filename = [sprintf('%05d_%02d', frameNum,i) '.png'];
            imwrite(trimmedImage, strcat(path,'/',filename));
            pause(0.001);
        end
        disp(strcat('output fly images >', num2str(100*(frameNum-startFrame)/(endFrame-startFrame+1)), '%', '     detect : ', num2str(blobNumber)));
        pause(0.001);
    end
end

%%
function trimmedImage = getOneFlyBoxImage(image, pointX, pointY, direction, boxSize, i)
    trimSize = boxSize * 1.5;
    rect = [pointX(i)-(trimSize/2) pointY(i)-(trimSize/2) trimSize trimSize];
    trimmedImage = imcrop(image, rect);

    % rotate image
    if isempty(direction) || direction(1,i) == 0
        angle = 0;
    else
        rt = direction(2,i) / direction(1,i);
        angle = atan(rt) * 180 / pi;

        if direction(1,i) >= 0
            angle = angle + 90;
        else
            angle = angle + 270;
        end
    end
    rotatedImage = imrotate(trimmedImage, angle, 'crop', 'bilinear');

    % trim again
    rect = [(trimSize-boxSize)/2 (trimSize-boxSize)/2 boxSize boxSize];
    trimmedImage = imcrop(rotatedImage, rect);
    [x,y,col] = size(trimmedImage);
    if x > boxSize
        if col == 3
            trimmedImage(:,boxSize+1,:) = [];
            trimmedImage(boxSize+1,:,:) = [];
        else
            trimmedImage(:,boxSize+1) = [];
            trimmedImage(boxSize+1,:) = [];
        end
    end
end

%%
function [ color1, color2 ] = getTopAndBottomColors(image, len, cosph, sinph, cx, cy, r)
    dx = len * cosph;
    dy = len * sinph;
    x1 = int64(cx+dx); y1 = int64(cy+dy);
    x2 = int64(cx-dx); y2 = int64(cy-dy);
    ymax = size(image,1);
    if (y1-r)<1 y1 = r+1; end
    if (y2-r)<1 y2 = r+1; end
    if (y1+r)>ymax y1 = ymax-r; end
    if (y2+r)>ymax y2 = ymax-r; end
    colBox1 = image(y1-r:y1+r, x1-r:x1+r);
    colBox2 = image(y2-r:y2+r, x2-r:x2+r);
    area = ((r*2+1) * (r*2+1));
    color1 = sum(sum(colBox1)) / area;
    color2 = sum(sum(colBox2)) / area;
end

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
end

%%
function [ keep_direction ] = PD_direction(blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient)
    sharedInst = sharedInstance(0); % get shared

    % init
    areaNumber = size(blobAreas, 1);
    keep_direction = zeros(2, areaNumber); % allocate memory
    
    % constant hidden params
    TH_OVER_HEAD_COLOR = 245;
    TH_WING_COLOR_MAX = 232;
    TH_WING_COLOR_MIN = 195;
    TH_HEAD_WING_DIFF_COLOR = 15; % between head and wing
    TH_WING_BG_DIFF_COLOR = 25;   % between wing and background

    % find direction for every blobs
    for i = 1:areaNumber
        % pre calculation
        cx = blobCenterPoints(i,1);
        cy = blobCenterPoints(i,2);
        ph = -blobOrient(i);
        cosph =  cos(ph);
        sinph =  sin(ph);
        len = blobMajorAxis(i) * 0.35;
        vec = [len*cosph; len*sinph];

        % get head and tail colors
        [ c1, c2 ] = getTopAndBottomColors(sharedInst.step2Image, len, cosph, sinph, cx, cy, 2);
        
        % get over head and over tail (maybe wing) colors
        [ c3, c4 ] = getTopAndBottomColors(sharedInst.step2Image, blobMajorAxis(i) * 0.6, cosph, sinph, cx, cy, 2);

        % 1st step. find head and wing on long axis line (just check 4 points' color) 
        [ vec, found ] = check4PointsColorsOnBody(vec, c1, c2, c3, c4, TH_OVER_HEAD_COLOR, TH_WING_COLOR_MAX, TH_WING_COLOR_MIN);

        if ~found
            % 1st step - check one more points
            [ c1a, c2a ] = getTopAndBottomColors(sharedInst.step2Image, blobMajorAxis(i) * 0.4, cosph, sinph, cx, cy, 1);
            [ c3a, c4a ] = getTopAndBottomColors(sharedInst.step2Image, blobMajorAxis(i) * 0.5, cosph, sinph, cx, cy, 1);
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
                [ c5, c6 ] = getTopAndBottomColors(sharedInst.step2Image, blobMajorAxis(i) * 0.45, cosph2, sinph2, cx, cy, 2);
                if abs(c5 - c6) > TH_WING_BG_DIFF_COLOR
                    % wing should connected body and over-wing should white
                    % because some time miss-detects next side body.
                    [ c7, c8 ] = getTopAndBottomColors(sharedInst.step2Image, blobMajorAxis(i) * 0.4, cosph2, sinph2, cx, cy, 2);
                    [ c9, c10 ] = getTopAndBottomColors(sharedInst.step2Image, blobMajorAxis(i) * 0.6, cosph2, sinph2, cx, cy, 2);
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
                [ c5, c6 ] = getTopAndBottomColors(sharedInst.step2Image, blobMajorAxis(i) * j, cosph, sinph, cx, cy, 2);
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
    end
end
