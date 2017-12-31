function varargout = trackingOptionDialog(varargin)
% TRACKINGOPTIONDIALOG MATLAB code for trackingOptionDialog.fig
%      TRACKINGOPTIONDIALOG, by itself, creates a new TRACKINGOPTIONDIALOG or raises the existing
%      singleton*.
%
%      H = TRACKINGOPTIONDIALOG returns the handle to a new TRACKINGOPTIONDIALOG or the handle to
%      the existing singleton*.
%
%      TRACKINGOPTIONDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKINGOPTIONDIALOG.M with the given input arguments.
%
%      TRACKINGOPTIONDIALOG('Property','Value',...) creates a new TRACKINGOPTIONDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackingOptionDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackingOptionDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackingOptionDialog

% Last Modified by GUIDE v2.5 01-Jan-2018 00:53:37

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @trackingOptionDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @trackingOptionDialog_OutputFcn, ...
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

% --- Executes just before trackingOptionDialog is made visible.
function trackingOptionDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to trackingOptionDialog (see VARARGIN)

    % Choose default command line output for trackingOptionDialog
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    c = varargin{1};
    rejDist = str2num(c{1});
    fixedTrackNum = str2num(c{2});
    fixedTrackDir = str2num(c{3});

    % init value
    set(handles.edit1, 'String', rejDist);
    set(handles.checkbox1, 'value', fixedTrackNum);
    set(handles.checkbox2, 'value', fixedTrackDir);

    % UIWAIT makes trackingOptionDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = trackingOptionDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    varargout{2} = get(handles.edit1, 'String');
    varargout{3} = num2str(get(handles.checkbox1, 'value'));
    varargout{4} = num2str(get(handles.checkbox2, 'value'));
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
