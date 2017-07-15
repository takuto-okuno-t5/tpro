function varargout = selectRoiWayDialog(varargin)
% SELECTROIWAYDIALOG MATLAB code for selectRoiWayDialog.fig
%      SELECTROIWAYDIALOG, by itself, creates a new SELECTROIWAYDIALOG or raises the existing
%      singleton*.
%
%      H = SELECTROIWAYDIALOG returns the handle to a new SELECTROIWAYDIALOG or the handle to
%      the existing singleton*.
%
%      SELECTROIWAYDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTROIWAYDIALOG.M with the given input arguments.
%
%      SELECTROIWAYDIALOG('Property','Value',...) creates a new SELECTROIWAYDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectRoiWayDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectRoiWayDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectRoiWayDialog

% Last Modified by GUIDE v2.5 03-Jul-2017 19:40:29

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @selectRoiWayDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @selectRoiWayDialog_OutputFcn, ...
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

% --- Executes just before selectRoiWayDialog is made visible.
function selectRoiWayDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to selectRoiWayDialog (see VARARGIN)

    % Choose default command line output for selectRoiWayDialog
    handles.output = hObject;
    handles.selectType = 1;
    guidata(hObject, handles);

    % UIWAIT makes selectRoiWayDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = selectRoiWayDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    varargout{2} = handles.selectType;
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.selectType = -1;
    guidata(hObject, handles);  % Update handles structure
    uiresume(handles.figure1);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.selectType = -1;
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


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.selectType = 1;
    guidata(hObject, handles);  % Update handles structure
end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to radiobutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.selectType = 2;
    guidata(hObject, handles);  % Update handles structure
end
