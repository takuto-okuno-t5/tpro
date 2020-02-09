function varargout = wingDetectionOptionDialog(varargin)
% WINGDETECTIONOPTIONDIALOG MATLAB code for wingDetectionOptionDialog.fig
%      WINGDETECTIONOPTIONDIALOG, by itself, creates a new WINGDETECTIONOPTIONDIALOG or raises the existing
%      singleton*.
%
%      H = WINGDETECTIONOPTIONDIALOG returns the handle to a new WINGDETECTIONOPTIONDIALOG or the handle to
%      the existing singleton*.
%
%      WINGDETECTIONOPTIONDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINGDETECTIONOPTIONDIALOG.M with the given input arguments.
%
%      WINGDETECTIONOPTIONDIALOG('Property','Value',...) creates a new WINGDETECTIONOPTIONDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wingDetectionOptionDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wingDetectionOptionDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wingDetectionOptionDialog

% Last Modified by GUIDE v2.5 09-Feb-2020 22:02:01

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @wingDetectionOptionDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @wingDetectionOptionDialog_OutputFcn, ...
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


% --- Executes just before wingDetectionOptionDialog is made visible.
function wingDetectionOptionDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to wingDetectionOptionDialog (see VARARGIN)

    % Choose default command line output for wingDetectionOptionDialog
    handles.output = hObject;

    % Update handles structure
    c = varargin{1};
    handles.wingColorMin = str2num(c{1});
    handles.wingColorMax = str2num(c{2});
    handles.rate = str2num(c{3});
    handles.step2Image = c{4};
    handles.detectedPointX = c{5};
    handles.detectedPointY = c{6};
    handles.blobAreas = c{7};
    handles.blobCenterPoints = c{8};
    handles.blobMajorAxis = c{9};
    handles.blobOrient = c{10};
    handles.blobEcc = c{11};
    handles.ignoreEccTh = str2num(c{12});
    handles.boxSize = int32(int32(nanmean(handles.blobMajorAxis) * 1.5) / 16) * 16 + 16;
    handles.flyId = 1;

    handles = recalcWings(hObject, handles);
    guidata(hObject, handles);

    % init value
    set(handles.edit1, 'String', handles.wingColorMin);
    set(handles.edit2, 'String', handles.wingColorMax);
    set(handles.edit3, 'String', handles.rate);
    set(handles.edit4, 'String', handles.ignoreEccTh);

    showAxisImage(handles);

    % UIWAIT makes wingDetectionOptionDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = wingDetectionOptionDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    varargout{2} = get(handles.edit1, 'String');
    varargout{3} = get(handles.edit2, 'String');
    varargout{4} = get(handles.edit3, 'String');
    varargout{5} = get(handles.edit4, 'String');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    set(handles.edit2, 'String', '');
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    set(handles.edit2, 'String', '');
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    flyCount = length(handles.detectedPointX);
    handles.flyId = mod(handles.flyId - 1 + flyCount - 1, flyCount) + 1;
    guidata(hObject, handles);
    showAxisImage(handles);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    flyCount = length(handles.detectedPointX);
    handles.flyId = mod(handles.flyId - 1 + flyCount + 1, flyCount) + 1;
    guidata(hObject, handles);
    showAxisImage(handles);
end


function edit1_Callback(hObject, eventdata, handles)
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.wingColorMin = str2num(get(hObject, 'String'));
    handles = recalcWings(hObject, handles);
    showAxisImage(handles);
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


function edit2_Callback(hObject, eventdata, handles)
    % hObject    handle to edit2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.wingColorMax = str2num(get(hObject, 'String'));
    handles = recalcWings(hObject, handles);
    showAxisImage(handles);
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


function edit3_Callback(hObject, eventdata, handles)
    % hObject    handle to edit3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.rate = str2num(get(hObject, 'String'));
    handles = recalcWings(hObject, handles);
    showAxisImage(handles);
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


function edit4_Callback(hObject, eventdata, handles)
    % hObject    handle to edit4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.ignoreEccTh = str2num(get(hObject, 'String'));
    handles = recalcWings(hObject, handles);
    showAxisImage(handles);
end

% --- Executes during object creation, after setting all properties.
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

% ----------------------------------------------------------------------

function handles = recalcWings(hObject, handles)
    handles.wingImage = applyWingFilter(handles.step2Image, handles.wingColorMin, handles.wingColorMax);

    redImage = uint8(single(handles.step2Image) + single(handles.wingImage.*0.6));
    handles.step2wingImg = cat(3, redImage, handles.step2Image, handles.step2Image);

    params = { handles.wingColorMin, handles.wingColorMax, handles.rate, 1, 10, handles.ignoreEccTh };
    [keep_direction, keep_angle, keep_wings] = PD_direction3(handles.step2Image, handles.blobAreas, handles.blobCenterPoints, handles.blobMajorAxis, handles.blobOrient, handles.blobEcc, params);
    handles.keep_direction = keep_direction;
    handles.keep_angle = keep_angle;
    handles.keep_wings = keep_wings;

    guidata(hObject, handles);
end

function showAxisImage(handles)
    axes(handles.axes1); % set drawing area
    cla;
    
    flyId = handles.flyId;
    trimSize = handles.boxSize;
    ptX = int32(handles.detectedPointX(flyId));
    ptY = int32(handles.detectedPointY(flyId));
    rect = [ptX-(trimSize/2) ptY-(trimSize/2) trimSize trimSize];
    img = imcrop(handles.step2wingImg, rect);
    imshow(img);

    hold on;
    % wing color pickup circle
    for i=1:3
        radius = handles.blobMajorAxis(flyId) * (handles.rate - 0.1 + 0.1*(i-1));
        circles(double(trimSize/2), double(trimSize/2), double(radius), 'facecolor', 'none', 'EdgeAlpha', 0.3, 'LineStyle', ':');
    end
    % head direction
    quiver(trimSize/2, trimSize/2, handles.keep_direction(1,flyId), handles.keep_direction(2,flyId), 0, 'r', 'MaxHeadSize',2, 'LineWidth',0.2)  %arrow
    % wing directions
    wingLength = handles.blobMajorAxis(flyId) * 0.7;
    leftWingDir = angleToDirection(handles.keep_wings(2,flyId), wingLength);
    rightWingDir = angleToDirection(handles.keep_wings(1,flyId), wingLength);
    quiver(trimSize/2, trimSize/2, leftWingDir(:,1), leftWingDir(:,2), 0, 'y', 'MaxHeadSize',0, 'LineWidth',0.2)  %line
    quiver(trimSize/2, trimSize/2, rightWingDir(:,1), rightWingDir(:,2), 0, 'g', 'MaxHeadSize',0, 'LineWidth',0.2)  %line
    hold off;

    set(handles.text7, 'String', ['fly=' num2str(handles.flyId)]);
end

