function varargout = preImageFilterDialog(varargin)
% PREIMAGEFILTERDIALOG MATLAB code for preImageFilterDialog.fig
%      PREIMAGEFILTERDIALOG, by itself, creates a new PREIMAGEFILTERDIALOG or raises the existing
%      singleton*.
%
%      H = PREIMAGEFILTERDIALOG returns the handle to a new PREIMAGEFILTERDIALOG or the handle to
%      the existing singleton*.
%
%      PREIMAGEFILTERDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREIMAGEFILTERDIALOG.M with the given input arguments.
%
%      PREIMAGEFILTERDIALOG('Property','Value',...) creates a new PREIMAGEFILTERDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preImageFilterDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preImageFilterDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preImageFilterDialog

% Last Modified by GUIDE v2.5 31-Dec-2017 23:58:59

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @preImageFilterDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @preImageFilterDialog_OutputFcn, ...
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

% --- Executes just before preImageFilterDialog is made visible.
function preImageFilterDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to preImageFilterDialog (see VARARGIN)

    % Choose default command line output for preImageFilterDialog
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    c = varargin{1};
    r = str2num(c{1});
    g = str2num(c{2});
    b = str2num(c{3});
    cmin = str2num(c{4});
    cmax = str2num(c{5});
    rad = str2num(c{6});
    amo = str2num(c{7});
    inv = str2num(c{8});

    % init value
    set(handles.edit1, 'String', r);
    set(handles.edit2, 'String', g);
    set(handles.edit3, 'String', b);
    set(handles.edit4, 'String', cmin);
    set(handles.edit5, 'String', cmax);
    set(handles.edit6, 'String', rad);
    set(handles.edit7, 'String', amo);
    set(handles.checkbox1, 'value', inv);
    guidata(hObject, handles);  % Update handles structure

    % UIWAIT makes preImageFilterDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = preImageFilterDialog_OutputFcn(hObject, eventdata, handles) 
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
    varargout{6} = get(handles.edit5, 'String');
    varargout{7} = get(handles.edit6, 'String');
    varargout{8} = get(handles.edit7, 'String');
    varargout{9} = num2str(get(handles.checkbox1, 'value'));
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
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    set(handles.edit1, 'String', '');
    uiresume(handles.figure1);
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


function edit4_Callback(hObject, eventdata, handles)
    % hObject    handle to edit4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    num = str2num(get(handles.edit4, 'String'));
    if isempty(num)
        set(handles.edit4, 'String', 0);
    elseif num < 0 || num > 1
        set(handles.edit4, 'String', 0);
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


function edit5_Callback(hObject, eventdata, handles)
    % hObject    handle to edit5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    num = str2num(get(handles.edit5, 'String'));
    if isempty(num)
        set(handles.edit5, 'String', 1);
    elseif num < 0 || num > 1
        set(handles.edit5, 'String', 1);
    end
    guidata(hObject, handles);  % Update handles structure
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


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
