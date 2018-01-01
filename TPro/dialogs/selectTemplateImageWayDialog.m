function varargout = selectTemplateImageWayDialog(varargin)
% SELECTTEMPLATEIMAGEWAYDIALOG MATLAB code for selectTemplateImageWayDialog.fig
%      SELECTTEMPLATEIMAGEWAYDIALOG, by itself, creates a new SELECTTEMPLATEIMAGEWAYDIALOG or raises the existing
%      singleton*.
%
%      H = SELECTTEMPLATEIMAGEWAYDIALOG returns the handle to a new SELECTTEMPLATEIMAGEWAYDIALOG or the handle to
%      the existing singleton*.
%
%      SELECTTEMPLATEIMAGEWAYDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTTEMPLATEIMAGEWAYDIALOG.M with the given input arguments.
%
%      SELECTTEMPLATEIMAGEWAYDIALOG('Property','Value',...) creates a new SELECTTEMPLATEIMAGEWAYDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectTemplateImageWayDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectTemplateImageWayDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectTemplateImageWayDialog

% Last Modified by GUIDE v2.5 02-Jan-2018 02:04:30

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @selectTemplateImageWayDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @selectTemplateImageWayDialog_OutputFcn, ...
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


% --- Executes just before selectTemplateImageWayDialog is made visible.
function selectTemplateImageWayDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to selectTemplateImageWayDialog (see VARARGIN)

    % Choose default command line output for selectTemplateImageWayDialog
    handles.output = hObject;

    % Update handles structure
    handles.selectType = 1;
    guidata(hObject, handles);

    % UIWAIT makes selectTemplateImageWayDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = selectTemplateImageWayDialog_OutputFcn(hObject, eventdata, handles) 
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

