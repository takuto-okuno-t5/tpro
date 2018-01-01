function varargout = templateMatchingOptionDialog(varargin)
% TEMPLATEMATCHINGOPTIONDIALOG MATLAB code for templateMatchingOptionDialog.fig
%      TEMPLATEMATCHINGOPTIONDIALOG, by itself, creates a new TEMPLATEMATCHINGOPTIONDIALOG or raises the existing
%      singleton*.
%
%      H = TEMPLATEMATCHINGOPTIONDIALOG returns the handle to a new TEMPLATEMATCHINGOPTIONDIALOG or the handle to
%      the existing singleton*.
%
%      TEMPLATEMATCHINGOPTIONDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEMPLATEMATCHINGOPTIONDIALOG.M with the given input arguments.
%
%      TEMPLATEMATCHINGOPTIONDIALOG('Property','Value',...) creates a new TEMPLATEMATCHINGOPTIONDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before templateMatchingOptionDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to templateMatchingOptionDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help templateMatchingOptionDialog

% Last Modified by GUIDE v2.5 01-Jan-2018 20:56:43

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @templateMatchingOptionDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @templateMatchingOptionDialog_OutputFcn, ...
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

% --- Executes just before templateMatchingOptionDialog is made visible.
function templateMatchingOptionDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to templateMatchingOptionDialog (see VARARGIN)

    % Choose default command line output for templateMatchingOptionDialog
    handles.output = hObject;

    % Update handles structure
    c = varargin{1};
    handles.count = str2num(c{1});
    mTh = str2num(c{2});
    sepNum = str2num(c{3});
    sepTh = str2num(c{4});
    oTh = str2num(c{5});
    handles.confPath = c{6};
    handles.current = 1;
    guidata(hObject, handles);

    % init value
    set(handles.edit1, 'String', mTh);
    set(handles.edit2, 'String', sepNum);
    set(handles.edit3, 'String', sepTh);
    set(handles.edit4, 'String', oTh);

    showTemplateImage(handles);

    % UIWAIT makes templateMatchingOptionDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = templateMatchingOptionDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    varargout{2} = handles.count;
    varargout{3} = get(handles.edit1, 'String');
    varargout{4} = get(handles.edit2, 'String');
    varargout{5} = get(handles.edit3, 'String');
    varargout{6} = get(handles.edit4, 'String');
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

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % show selectRoiWayDialog
    [dlg, selectedType] = selectTemplateImageWayDialog({});
    delete(dlg);

    if selectedType < 0
        return;
    end
    
    % select fixed ROI image files or create new ROI images
    if selectedType == 2
        count = selectTemplateImageFiles(handles.confPath, handles.count);
    else
        %count = 1;
        errordlg('not supported now.', 'Error');
        return;
    end
    handles.count = handles.count + count;
    guidata(hObject, handles);
    showTemplateImage(handles);
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    for i=handles.current:handles.count
        fileName = [handles.confPath 'template' num2str(i+1) '.png'];
        if exist(fileName, 'file')
            try
                tmplImage = imread(fileName);
                if i == 1
                    outname = [handles.confPath 'template.png'];
                else
                    outname = [handles.confPath 'template' num2str(i) '.png'];
                end
                imwrite(tmplImage, outname);
            catch e
                errordlg(['failed to write a template image file : ' outname], 'Error');
                return;
            end
        end
    end
    if handles.current > 1
        handles.current = handles.current - 1;
    end
    handles.count = handles.count - 1;
    guidata(hObject, handles);
    showTemplateImage(handles);
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.current = mod(handles.current-1-1, handles.count) + 1;
    guidata(hObject, handles);
    showTemplateImage(handles);
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton6 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    handles.current = mod(handles.current-1+1, handles.count) + 1;
    guidata(hObject, handles);
    showTemplateImage(handles);
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

% ----------------------------------------------------------------------

function showTemplateImage(handles)
    axes(handles.axes1); % set drawing area
    cla;
    if handles.count > 0
        if (handles.current) == 1
            fileName = [handles.confPath 'template.png'];
        else
            fileName = [handles.confPath 'template' num2str(handles.current) '.png'];
        end
        img = imread(fileName);
        imshow(img);
    end
    if handles.count == 0
        set(handles.pushbutton4, 'Enable', 'off');
    else
        set(handles.pushbutton4, 'Enable', 'on');
    end
    if handles.current == 1
        set(handles.pushbutton5, 'Enable', 'off');
    else
        set(handles.pushbutton5, 'Enable', 'on');
    end
    if handles.count == 0 || handles.current == handles.count
        set(handles.pushbutton6, 'Enable', 'off');
    else
        set(handles.pushbutton6, 'Enable', 'on');
    end
end
