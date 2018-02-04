function varargout = findAnnotationDialog(varargin)
% FINDANNOTATIONDIALOG MATLAB code for findAnnotationDialog.fig
%      FINDANNOTATIONDIALOG, by itself, creates a new FINDANNOTATIONDIALOG or raises the existing
%      singleton*.
%
%      H = FINDANNOTATIONDIALOG returns the handle to a new FINDANNOTATIONDIALOG or the handle to
%      the existing singleton*.
%
%      FINDANNOTATIONDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINDANNOTATIONDIALOG.M with the given input arguments.
%
%      FINDANNOTATIONDIALOG('Property','Value',...) creates a new FINDANNOTATIONDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before findAnnotationDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to findAnnotationDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help findAnnotationDialog

% Last Modified by GUIDE v2.5 04-Feb-2018 02:05:22

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @findAnnotationDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @findAnnotationDialog_OutputFcn, ...
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


% --- Executes just before findAnnotationDialog is made visible.
function findAnnotationDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to findAnnotationDialog (see VARARGIN)

    % Choose default command line output for findAnnotationDialog
    handles.output = hObject;
    handles.operation = 0;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes findAnnotationDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = findAnnotationDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    varargout{2} = handles.operation;
    varargout{3} = num2str(1);
    contents = cellstr(get(handles.popupmenu2,'String'));
    varargout{4} = contents{get(handles.popupmenu2,'Value')};
    contents = cellstr(get(handles.popupmenu1,'String'));
    varargout{5} = contents{get(handles.popupmenu1,'Value')};
    varargout{6} = get(handles.edit1, 'String');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.operation = 0;
    guidata(hObject, handles);  % Update handles structure
    uiresume(handles.figure1);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.operation = 0;
    guidata(hObject, handles);  % Update handles structure
    uiresume(handles.figure1);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.operation = 1;
    guidata(hObject, handles);  % Update handles structure
    uiresume(handles.figure1);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.operation = 2;
    guidata(hObject, handles);  % Update handles structure
    uiresume(handles.figure1);
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
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
