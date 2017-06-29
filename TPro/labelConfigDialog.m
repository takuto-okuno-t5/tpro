function varargout = labelConfigDialog(varargin)
    % LABELCONFIGDIALOG MATLAB code for labelConfigDialog.fig
    %      LABELCONFIGDIALOG, by itself, creates a new LABELCONFIGDIALOG or raises the existing
    %      singleton*.
    %
    %      H = LABELCONFIGDIALOG returns the handle to a new LABELCONFIGDIALOG or the handle to
    %      the existing singleton*.
    %
    %      LABELCONFIGDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in LABELCONFIGDIALOG.M with the given input arguments.
    %
    %      LABELCONFIGDIALOG('Property','Value',...) creates a new LABELCONFIGDIALOG or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before labelConfigDialog_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to labelConfigDialog_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help labelConfigDialog

    % Last Modified by GUIDE v2.5 29-Jun-2017 20:40:08

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @labelConfigDialog_OpeningFcn, ...
                       'gui_OutputFcn',  @labelConfigDialog_OutputFcn, ...
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

% --- Executes just before labelConfigDialog is made visible.
function labelConfigDialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to labelConfigDialog (see VARARGIN)

    % Choose default command line output for labelConfigDialog
    handles.output = hObject;
    guidata(hObject, handles);
    
    % load annotation label
    labelFileName = 'annotation_label.csv';
    annoLabel = [];
    if exist(labelFileName, 'file')
        labelTable = readtable(labelFileName,'ReadVariableNames',false);
        labels = table2cell(labelTable);
        annoLabel = cell(max(cell2mat(labels(:,1))),2);
        for i=1:size(annoLabel,1)
            n = labels{i,1};
            annoLabel{n,1} = labels{i,2};
            annoLabel{n,2} = labels{i,3};
        end
    end
    handles.uitable1.Data = annoLabel;
    handles.uitable1.ColumnName = {'  label','allocated key'};
    handles.uitable1.ColumnEditable = true;

    % initialize GUI
    sharedInst = struct; % allocate shared instance
    sharedInst.annoLabel = annoLabel;
    sharedInst.isModified = 0;
    sharedInst.isSaved = 0;
    sharedInst.selectedRow = 0;

    % set gui status
    set(handles.pushbutton2, 'Enable', 'off');
    set(handles.pushbutton4, 'Enable', 'off');
    set(handles.uitable1,'ColumnWidth', {150,77});
    
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    guidata(hObject, handles);  % Update handles structure
    
    % UIWAIT makes labelConfigDialog wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = labelConfigDialog_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if sharedInst.isModified
        selection = questdlg('Do you save label configuration before closing window?',...
                             'Confirmation',...
                             'Yes','No','Cancel','Yes');
        switch selection
        case 'Cancel'
            return;
        case 'Yes'
            pushbutton2_Callback(handles.pushbutton2, eventdata, handles);
        case 'No'
            % nothing todo
        end
    end
    uiresume(handles.figure1);
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    hFig = ancestor(hObject, 'figure');
    figure1_CloseRequestFcn(hFig, eventdata, handles);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    labelFileName = 'annotation_label.csv';
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.isModified = 0;
    sharedInst.isSaved = 1;
    sz = size(sharedInst.annoLabel,1);
    annoLabel = [cell(sz,1) sharedInst.annoLabel];
    for i = 1:sz
        annoLabel(i,1) = {i};
    end
    T = array2table(annoLabel);
    writetable(T,labelFileName,'WriteVariableNames',false);
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    set(handles.pushbutton2, 'Enable', 'off');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    annoLabel = sharedInst.annoLabel;
    sharedInst.annoLabel = [annoLabel; {'new label', NaN}];
    sharedInst.isModified = 1;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    set(handles.pushbutton2, 'Enable', 'on');
    handles.uitable1.Data = sharedInst.annoLabel;
    guidata(hObject, handles);  % Update handles structure
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton4 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    annoLabel = sharedInst.annoLabel;
    annoLabel(sharedInst.selectedRow,:) = [];
    sharedInst.annoLabel = annoLabel;
    sharedInst.isModified = 1;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance

    set(handles.pushbutton2, 'Enable', 'on');
    handles.uitable1.Data = sharedInst.annoLabel;
    guidata(hObject, handles);  % Update handles structure
end


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
    % hObject    handle to uitable1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
    %	Indices: row and column indices of the cell(s) currently selecteds
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    if size(eventdata.Indices,1) > 0
        sharedInst.selectedRow = eventdata.Indices(1,1);
    end
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
    
    set(handles.pushbutton4, 'Enable', 'on');
    guidata(hObject, handles);  % Update handles structure
end

% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
    % hObject    handle to uitable1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
    %	Indices: row and column indices of the cell(s) edited
    %	PreviousData: previous data for the cell(s) edited
    %	EditData: string(s) entered by the user
    %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
    %	Error: error string when failed to convert EditData to appropriate value for Data
    % handles    structure with handles and user data (see GUIDATA)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    row = eventdata.Indices(1,1);
    modified = 1;
    if eventdata.Indices(1,2) == 1
        sharedInst.annoLabel{row,1} = eventdata.NewData;
    else
        % check number
        for i=1:size(sharedInst.annoLabel,1)
            if i==row continue; end
            if sharedInst.annoLabel{i,2} == eventdata.NewData
                modified = 0;
            end
        end
        if eventdata.NewData > 9 || eventdata.NewData < 1
            modified = 0;
        end
        if modified
            sharedInst.annoLabel{row,2} = eventdata.NewData;
        end
    end
    if modified
        sharedInst.isModified = 1;
        setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance    
        set(handles.pushbutton2, 'Enable', 'on');
    end
    
    handles.uitable1.Data = sharedInst.annoLabel;
    guidata(hObject, handles);  % Update handles structure
end
