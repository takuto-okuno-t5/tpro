function varargout = startEndDialog(varargin)
% STARTENDDIALOG MATLAB code for startEndDialog.fig
%      STARTENDDIALOG, by itself, creates a new STARTENDDIALOG or raises the existing
%      singleton*.
%
%      H = STARTENDDIALOG returns the handle to a new STARTENDDIALOG or the handle to
%      the existing singleton*.
%
%      STARTENDDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STARTENDDIALOG.M with the given input arguments.
%
%      STARTENDDIALOG('Property','Value',...) creates a new STARTENDDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before startEndDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to startEndDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help startEndDialog

% Last Modified by GUIDE v2.5 24-May-2017 20:25:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @startEndDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @startEndDialog_OutputFcn, ...
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


% --- Executes just before startEndDialog is made visible.
function startEndDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to startEndDialog (see VARARGIN)

% Choose default command line output for startEndDialog
handles.output = hObject;
handles.startFrame = str2num(char(varargin{1}(1)));
handles.endFrame = str2num(char(varargin{1}(2)));
handles.name = char(varargin{1}(3));
handles.maxFrame = handles.endFrame;
handles.checkNum = 100;
if (handles.endFrame - handles.startFrame + 1) < handles.checkNum
    handles.checkNum = handles.endFrame - handles.startFrame + 1;
end

set(handles.edit1, 'String', handles.startFrame);
set(handles.edit2, 'String', handles.endFrame);
set(handles.edit3, 'String', handles.checkNum);

% set window title
set(hObject, 'name', handles.name); % set window title

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes startEndDialog wait for user response (see UIRESUME)
uiwait(handles.figure1); % wait for finishing dialog

% --- Outputs from this function are returned to the command line.
function varargout = startEndDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.startFrame;
varargout{3} = handles.endFrame;
varargout{4} = handles.checkNum;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.startFrame = -1;
guidata(hObject, handles);  % Update handles structure
uiresume(handles.figure1);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.startFrame = -1;
guidata(hObject, handles);  % Update handles structure
uiresume(handles.figure1);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num = str2num(get(handles.edit1, 'String'));
if isempty(num)
    set(handles.edit1, 'String', 1);
else
    if num < 1 || num > handles.endFrame
        set(handles.edit1, 'String', handles.startFrame);
    else
        handles.startFrame = num;
    end
end
guidata(hObject, handles);  % Update handles structure


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


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num = str2num(get(handles.edit2, 'String'));
if isempty(num)
    set(handles.edit2, 'String', handles.endFrame);
else
    if num < handles.startFrame || num > handles.maxFrame
        set(handles.edit2, 'String', handles.endFrame);
    else
        handles.endFrame = num;
    end
end
guidata(hObject, handles);  % Update handles structure


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


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
num = str2num(get(handles.edit3, 'String'));
if isempty(num)
    set(handles.edit3, 'String', handles.checkNum);
else
    if num < 1 || num > (handles.endFrame - handles.startFrame + 1)
        set(handles.edit3, 'String', handles.checkNum);
    else
        handles.checkNum = num;
    end
end
guidata(hObject, handles);  % Update handles structure


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
