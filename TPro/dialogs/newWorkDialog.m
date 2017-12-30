function varargout = newWorkDialog(varargin)
% NEWWORKDIALOG MATLAB code for newWorkDialog.fig
%      NEWWORKDIALOG, by itself, creates a new NEWWORKDIALOG or raises the existing
%      singleton*.
%
%      H = NEWWORKDIALOG returns the handle to a new NEWWORKDIALOG or the handle to
%      the existing singleton*.
%
%      NEWWORKDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWWORKDIALOG.M with the given input arguments.
%
%      NEWWORKDIALOG('Property','Value',...) creates a new NEWWORKDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before newWorkDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to newWorkDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help newWorkDialog

% Last Modified by GUIDE v2.5 03-Aug-2017 15:31:48

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @newWorkDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @newWorkDialog_OutputFcn, ...
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

% --- Executes just before newWorkDialog is made visible.
function newWorkDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to newWorkDialog (see VARARGIN)

    % Choose default command line output for newWorkDialog
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % load environment value
    if size(varargin, 1) > 0
        c = varargin{1};
        projectName = c{1};
        path = c{2};
        frames = str2num(c{3});
        fps = str2num(c{4});
        handles.isArgin = true;
    else
        projectName = '';
        path = '';
        frames = 1000;
        fps = 30;
        handles.isArgin = false;
    end

    % init value
    set(handles.edit1, 'String', projectName);
    set(handles.edit2, 'String', path);
    set(handles.edit3, 'String', fps);
    set(handles.edit6, 'String', frames);
    set(handles.edit7, 'String', [path projectName '.mat']);
    if ~isempty(projectName)
        set(handles.edit1, 'Enable', 'off');
        set(handles.edit2, 'Enable', 'off');
        set(handles.edit6, 'Enable', 'off');
        set(handles.edit7, 'Enable', 'off');
        set(handles.pushbutton2, 'Enable', 'off');
        set(handles.pushbutton5, 'Enable', 'off');
    end
    guidata(hObject, handles);  % Update handles structure

    setappdata(handles.figure1,'projectName',projectName); % set project name
    setappdata(handles.figure1,'path',path); % set project name

    checkOKButton(handles);

    % UIWAIT makes newWorkDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

function checkOKButton(handles)
    projectName =  get(handles.edit1, 'String');
    path =  get(handles.edit2, 'String');
    if ~isempty(projectName) && ~isempty(path)
        set(handles.pushbutton4, 'Enable', 'on');
    else
        set(handles.pushbutton4, 'Enable', 'off');
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = newWorkDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    varargout{2} = get(handles.edit1, 'String');
    varargout{3} = get(handles.edit2, 'String');
    varargout{4} = get(handles.edit8, 'String');
    varargout{5} = get(handles.edit9, 'String');
    varargout{6} = get(handles.edit6, 'String');
    varargout{7} = get(handles.edit3, 'String');
    varargout{8} = get(handles.edit4, 'String');
    varargout{9} = get(handles.edit5, 'String');
    varargout{10} = get(handles.edit7, 'String');

    if ~handles.isArgin
        delete(hObject); % only delete when it launched directly.
    end
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    set(handles.edit1, 'String', '');
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    set(handles.edit1, 'String', '');
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    path = getappdata(handles.figure1,'path'); % get project name

    [fileNames, videoPath, filterIndex] = uigetfile( {  ...
        '*.mat',  'MAT File (*.mat)'}, ...
        'Pick a file', ...
        'MultiSelect', 'off', path);

    if ~filterIndex
        return;
    end
    set(handles.edit7, 'String', [videoPath fileNames]);
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    path = getappdata(handles.figure1,'path'); % get project name

    [fileNames, videoPath, filterIndex] = uigetfile( {  ...
        '*.png',  'PNG File (*.png)'}, ...
        'Pick a file', ...
        'MultiSelect', 'off', path);

    if ~filterIndex
        return;
    end
    set(handles.edit8, 'String', [videoPath fileNames]);
end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton7 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    path = getappdata(handles.figure1,'path'); % get project name

    [fileNames, videoPath, filterIndex] = uigetfile( {  ...
        '*.png',  'PNG Files (*.png)'}, ...
        'Pick a file', ...
        'MultiSelect', 'on', path);

    if ~filterIndex
        return;
    end

    if ischar(fileNames)
        fileCount = 1;
    else
        fileCount = size(fileNames,2);
    end

    % process all selected files
    videoFiles = [];
    for i = 1:fileCount
        if fileCount > 1
            fileName = fileNames{i};
        else
            fileName = fileNames;
        end
        videoFiles = [videoFiles ';' [videoPath fileName]];
    end
    videoFiles = videoFiles(2:end); % remove first ';'
    set(handles.edit9, 'String', videoFiles);
end



function edit1_Callback(hObject, eventdata, handles)
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    checkOKButton(handles);
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
    checkOKButton(handles);
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


function edit5_Callback(hObject, eventdata, handles)
    % hObject    handle to edit5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function edit6_Callback(hObject, eventdata, handles)
    % hObject    handle to edit6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


function edit7_Callback(hObject, eventdata, handles)
    % hObject    handle to edit7 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit7 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function edit8_Callback(hObject, eventdata, handles)
    % hObject    handle to edit8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit8 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function edit9_Callback(hObject, eventdata, handles)
    % hObject    handle to edit9 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to edit9 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
