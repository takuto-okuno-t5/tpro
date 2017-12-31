function varargout = otherDetectionOptionDialog(varargin)
% OTHERDETECTIONOPTIONDIALOG MATLAB code for otherDetectionOptionDialog.fig
%      OTHERDETECTIONOPTIONDIALOG, by itself, creates a new OTHERDETECTIONOPTIONDIALOG or raises the existing
%      singleton*.
%
%      H = OTHERDETECTIONOPTIONDIALOG returns the handle to a new OTHERDETECTIONOPTIONDIALOG or the handle to
%      the existing singleton*.
%
%      OTHERDETECTIONOPTIONDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OTHERDETECTIONOPTIONDIALOG.M with the given input arguments.
%
%      OTHERDETECTIONOPTIONDIALOG('Property','Value',...) creates a new OTHERDETECTIONOPTIONDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before otherDetectionOptionDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to otherDetectionOptionDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help otherDetectionOptionDialog

% Last Modified by GUIDE v2.5 01-Jan-2018 02:06:02

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @otherDetectionOptionDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @otherDetectionOptionDialog_OutputFcn, ...
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


% --- Executes just before otherDetectionOptionDialog is made visible.
function otherDetectionOptionDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to otherDetectionOptionDialog (see VARARGIN)

    % Choose default command line output for otherDetectionOptionDialog
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    c = varargin{1};
    algo = c{1};
    maxSep = str2num(c{2});
    isSep = str2num(c{3});
    rectDel = str2num(c{4});
    maxBlob = str2num(c{5});
    keepNear = str2num(c{6});

    % init value
    if strcmp(algo, 'gaussian')
        set(handles.popupmenu1, 'Value', 2)
    else
        set(handles.popupmenu1, 'Value', 1)
    end
    set(handles.edit1, 'String', maxSep);
    set(handles.edit2, 'String', maxBlob);
    set(handles.checkbox1, 'value', isSep);
    set(handles.checkbox2, 'value', rectDel);
    set(handles.checkbox3, 'value', keepNear);

    % UIWAIT makes otherDetectionOptionDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = otherDetectionOptionDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    contents = cellstr(get(handles.popupmenu1,'String'));
    varargout{2} = contents{get(handles.popupmenu1,'Value')};
    varargout{3} = get(handles.edit1, 'String'); % max sep
    varargout{4} = num2str(get(handles.checkbox1, 'value')); % is sep
    varargout{5} = num2str(get(handles.checkbox2, 'value')); % rect
    varargout{6} = get(handles.edit2, 'String'); % max blob
    varargout{7} = num2str(get(handles.checkbox3, 'value')); % keep near
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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
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

