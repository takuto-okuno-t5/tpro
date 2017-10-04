function varargout = inputSwapIdsDialog(varargin)
% INPUTSWAPIDSDIALOG MATLAB code for inputSwapIdsDialog.fig
%      INPUTSWAPIDSDIALOG, by itself, creates a new INPUTSWAPIDSDIALOG or raises the existing
%      singleton*.
%
%      H = INPUTSWAPIDSDIALOG returns the handle to a new INPUTSWAPIDSDIALOG or the handle to
%      the existing singleton*.
%
%      INPUTSWAPIDSDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUTSWAPIDSDIALOG.M with the given input arguments.
%
%      INPUTSWAPIDSDIALOG('Property','Value',...) creates a new INPUTSWAPIDSDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inputSwapIdsDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inputSwapIdsDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inputSwapIdsDialog

% Last Modified by GUIDE v2.5 06-Sep-2017 15:23:01

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @inputSwapIdsDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @inputSwapIdsDialog_OutputFcn, ...
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

% --- Executes just before inputSwapIdsDialog is made visible.
function inputSwapIdsDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to inputSwapIdsDialog (see VARARGIN)

    % Choose default command line output for inputSwapIdsDialog
    handles.output = hObject;
    handles.id1 = str2num(char(varargin{1}(1)));
    handles.id2 = str2num(char(varargin{1}(2)));
    handles.startFrame = str2num(char(varargin{1}(3)));
    handles.endFrame = str2num(char(varargin{1}(4)));
    handles.minFrame = handles.startFrame;
    handles.maxFrame = handles.endFrame;
    handles.maxId = handles.id2;

    set(handles.edit3, 'String', handles.id1);
    set(handles.edit4, 'String', handles.id2);
    set(handles.edit1, 'String', handles.startFrame);
    set(handles.edit2, 'String', handles.endFrame);

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes inputSwapIdsDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = inputSwapIdsDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    varargout{2} = handles.id1;
    varargout{3} = handles.id2;
    varargout{4} = handles.startFrame;
    varargout{5} = handles.endFrame;
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.id1 = -1;
    guidata(hObject, handles);  % Update handles structure
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.id1 = -1;
    guidata(hObject, handles);  % Update handles structure
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.figure1);
end


function edit1_Callback(hObject, eventdata, handles)
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    num = str2num(get(handles.edit1, 'String'));
    if isempty(num)
        set(handles.edit1, 'String', 1);
    else
        if num < handles.minFrame || num > handles.endFrame
            set(handles.edit1, 'String', handles.startFrame);
        else
            handles.startFrame = num;
        end
    end
    guidata(hObject, handles);  % Update handles structure
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
    num = str2num(get(handles.edit3, 'String'));
    if isempty(num)
        set(handles.edit3, 'String', 1);
    else
        if num < 0 || num == handles.id2
            set(handles.edit3, 'String', handles.id1);
        else
            handles.id1 = num;
        end
    end
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


function edit4_Callback(hObject, eventdata, handles)
    % hObject    handle to edit4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    num = str2num(get(handles.edit4, 'String'));
    if isempty(num)
        set(handles.edit4, 'String', 1);
    else
        if num < 0 || num == handles.id1 || num > handles.maxId
            set(handles.edit4, 'String', handles.id2);
        else
            handles.id2 = num;
        end
    end
    guidata(hObject, handles);  % Update handles structure
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
