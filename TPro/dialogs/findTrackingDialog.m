function varargout = findTrackingDialog(varargin)
% FINDTRACKINGDIALOG MATLAB code for findTrackingDialog.fig
%      FINDTRACKINGDIALOG, by itself, creates a new FINDTRACKINGDIALOG or raises the existing
%      singleton*.
%
%      H = FINDTRACKINGDIALOG returns the handle to a new FINDTRACKINGDIALOG or the handle to
%      the existing singleton*.
%
%      FINDTRACKINGDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINDTRACKINGDIALOG.M with the given input arguments.
%
%      FINDTRACKINGDIALOG('Property','Value',...) creates a new FINDTRACKINGDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before findTrackingDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to findTrackingDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help findTrackingDialog

% Last Modified by GUIDE v2.5 03-Jan-2018 15:49:42

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @findTrackingDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @findTrackingDialog_OutputFcn, ...
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

% --- Executes just before findTrackingDialog is made visible.
function findTrackingDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to findTrackingDialog (see VARARGIN)
    % Choose default command line output for findTrackingDialog
    handles.output = hObject;
    handles.operation = 0;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes findTrackingDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = findTrackingDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    varargout{2} = handles.operation;
    varargout{3} = num2str(1);
    contents = cellstr(get(handles.popupmenu1,'String'));
    varargout{4} = contents{get(handles.popupmenu1,'Value')};
    varargout{5} = get(handles.edit1, 'String');
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

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
