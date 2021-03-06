% TPro1.4 2017-04-22
% add total distance output
% add create movie button
% standard file name is now '%05d'

function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 03-Mar-2018 01:30:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_OpeningFcn, ...
    'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)
if exist('./io','dir')
    addpath('./io');
    addpath('./gui');
    addpath('./cmd');
    addpath('./calc');
    addpath('./util');
    addpath('./dialogs');
end

% get exe file full path
global exePath;
global exeName;
[exePath, exeName, ext] = exeFilename();
%disp(['tpro exepath : ' exePath]);

% init command line input
handles.addFileMode = false;
handles.movies = {};
handles.template = [];
handles.batch = [];
handles.path = [];
handles.rois = {};
handles.commandError = 0;
handles.autobackground = 0;
handles.autodetect = 0;
handles.autotracking = 0;
handles.autofinish = 0;
handles.autodcd = 0;
handles.tmpindex = 0;
handles.pi = [];
handles.export = [];
handles.analyseSrc = [];
handles.range = {};
handles.join = [];
handles.joinr = [];
handles.procOps = {};
handles.srcOps = {};
handles.bgOp = {};
handles.percentile = [];
handles.merge = {};
handles.maxFrame = 0; % for raster duration
handles.janeriaTrxPath = {};
handles.mergeMatData = {};
handles.extMatData = [];

% load command line input
i = 1;
while true
	if i > size(varargin, 2)
        break;
    end
    switch varargin{i}
        case {'-b','--batch'}
            handles.batch = varargin{i+1};
            i = i + 1;
        case {'-p','--path'}
            handles.path = varargin{i+1};
            i = i + 1;
        case {'-c','--conf'}
            handles.template = varargin{i+1};
            i = i + 1;
        case {'-r','--roi'}
            handles.rois = [handles.rois varargin{i+1}];
            i = i + 1;
        case {'-g','--background'}
            handles.autobackground = 1;
        case {'-d','--detect'}
            handles.autodetect = 1;
        case {'-t','--tracking'}
            handles.autotracking = 1;
        case {'-f','--finish'}
            handles.autofinish = 1;
        case {'--bgop'}
            handles.bgOp = {varargin{i+1} varargin{i+2} varargin{i+3}};
            i = i + 3;
        case {'--showcount'}
            handles.showcount = str2num(varargin{i+1});
            i = i + 1;
        case {'--dcd'}
            handles.autodcd = 1;
        case {'--dcdp'}
            handles.dcdpfile = varargin{i+1};
            i = i + 1;
        case {'--pi'}
            handles.pi = [handles.pi; [str2num(varargin{i+1}) str2num(varargin{i+2})]];
            i = i + 2;
        case {'--export','--piexport'}
            handles.export = varargin{i+1};
            i = i + 1;
        case {'--src'}
            handles.analyseSrc = varargin{i+1};
            i = i + 1;
        case {'--sop'}
            handles.srcOps = [handles.srcOps, varargin{i+1}];
            i = i + 1;
        case {'--range'}
            handles.range = {varargin{i+1} varargin{i+2}};
            i = i + 2;
        case {'--join'}
            handles.join = str2num(varargin{i+1});
            i = i + 1;
        case {'--joinr'}
            handles.joinr = str2num(varargin{i+1});
            i = i + 1;
        case {'--merge'}
            handles.merge = varargin{i+1};
            i = i + 1;
        case {'--percentile'}
            C = strsplit(varargin{i+1},'/');
            nums = [];
            for j=1:length(C)
                nums = [nums, str2num(C{j})];
            end
            handles.percentile = nums;
            i = i + 1;
        case {'--proc'}
            handles.procOps = [handles.procOps, varargin{i+1}];
            i = i + 1;
        case {'--maxframe'}
            handles.maxFrame = str2num(varargin{i+1});
            i = i + 1;
        case {'--jtrx'}
            handles.janeriaTrxPath = varargin{i+1};
            i = i + 1;
        case {'--tempindex'}
            handles.tmpindex = str2num(varargin{i+1});
            i = i + 1;
        case {'--mmerge'}
            handles.mergeMatData = 1;
        case {'--mext'}
            C = strsplit(varargin{i+1},'/');
            nums = [];
            for j=1:length(C)
                nums = [nums, str2num(C{j})];
            end
            handles.extMatData = nums;
            i = i + 1;
        case {'-h','--help'}
            disp(['usage: ' exeName ' [options] movies ...']);
            disp('  -b, --batch file    batch csv [file]');
            disp('  -p, --path path     movie [path] for batch process');
            disp('  -c, --conf file     detection and tracking configuration template [file]');
            disp('  -r, --roi file      ROI image [file]');
            disp('  -g, --background    force to start background detection');
            disp('  -d, --detect        force to start detection');
            disp('  -t, --tracking      force to start tracking');
            disp('  -f, --finish        force to finish tpro after processing');
            disp('  --bgop start end num  background detection option [start] and [end] frame. pick up frame [num]');
            disp('  --showcount 0|1     show detection result [0:off, 1:on]');
            disp('  --pi roi1 roi2      export PI of [roi1] vs [roi2] using detection data');
            disp('  --dcd               export DCD using detection or tracking data');
            disp('  --dcdp file         set dcd percentile map [file]');
            disp('  --src type          specify analysing data source (tracking data)');
            disp('                      [type] : x,y,vxy,dir,av,ecc,rwa,lwa,dcdcalc,dcd,gcalc,gtrack,group,gcount,becalc,be,chase, ...');
            disp('  --sop op            options for data source (tracking data)');
            disp('  --range start end   analysing range of source data from [start] to [end]');
            disp('  --proc op           process analysed data by [op] operation');
            disp('                      [op] : sum,mean,max,min,count==N,nancount, ...');
            disp('  --join 0|1          join columns of export data after proc [0:without, 1:with] header');
            disp('  --joinr 0|1         join rows of export data after proc [0:without, 1:with] header');
            disp('  --merge op          merge matrix of export data after proc by [op] operation');
            disp('  --percentile nums   percentile columns of export data after join. [nums] are percent');
            disp('  --export path       export analysed data files on [path]');
            disp('  --jtrx path         janeria trx data [path]');
            disp('  --mmerge            merge mat data');
            disp('  --mext nums         extract mat (tracking) data by index [nums]');
            disp('  --tempindex num     template index [num] (along with background detection)');
            disp('  -h, --help          show tpro command line help');
            i = size(varargin, 2);
            handles.commandError = 1;
        otherwise
            if strcmp(varargin{i}(1), '-')
                disp(['bad option : ' varargin{i}]);
                i = size(varargin, 2);
                handles.commandError = 1;
            else
                handles.movies = [handles.movies varargin{i}];
            end
    end
    i = i + 1;
end
guidata(hObject, handles);

% set window title
versionNumber = '1.5.4';
set(gcf, 'name', ['TPro version ', versionNumber]);
set(handles.text14, 'String', ['TPro ', versionNumber])
set(handles.text2, 'String', ['TPro', versionNumber])

% set initialized message
set(handles.text14, 'String','Welcome! Please click the buttons on the left to run')

% init gui parts
handles.uitable2.ColumnName = {'file name','path'};
handles.uitable2.ColumnWidth = {200,440};
handles.uitable2.RowName = [];

if exist('ui/drag_and_drop.png','file')
    axes(handles.axes1); % set drawing area
    imshow(imread('ui/drag_and_drop.png'));
    handles.axes1.Box = 'off';
    handles.axes1.Color = 'None';
    handles.axes1.FontSize = 1;
    handles.axes1.XMinorTick = 'off';
    handles.axes1.YMinorTick = 'off';
    handles.axes1.XTick = [0];
    handles.axes1.YTick = [0];
else
    handles.axes1.Visible = 'off';
end

initFileUITable(handles);
checkAllButtons(handles);
pause(0.01);

% initialize dndcontrol
dndcontrol.initJava();

jPanel = javaObjectEDT('javax.swing.JPanel');
bgcolor = get(gcf, 'Color');
jPanel.setBackground(java.awt.Color(bgcolor(1),bgcolor(2),bgcolor(3)));

% Add Scrollpane to figure
[~,hContainer] = javacomponent(jPanel,[],hObject);
set(hContainer,'Units','normalized','Position',[0 0 1 1]);
uistack(hContainer,'bottom');
%hObject.Children

% Set Drop callback functions
dndobj = dndcontrol(jPanel, hContainer);
dndobj.DropFileFcn = @onDropFile;
dndobj.DropStringFcn = @onDropFile;

% working with command line mode
runCommandLineMode(hObject, eventdata, handles);


%% 
function initFileUITable(handles)
[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    return;
end
% update uitable
handles.uitable2.Data = tebleItems;


%% Callback function
function onDropFile(hObject, eventdata)
videoPaths = {};
videoFiles = {};
switch eventdata.DropType
    case 'file'
        % process all dragged files
        for n = 1:numel(eventdata.Data)
            [path, name, ext] = fileparts(eventdata.Data{n});
            videoPaths = [videoPaths; [path '/']];
            videoFiles = [videoFiles; [name ext]];
        end
    case 'string'
        % nothing to do
end
% sort input files
videoFiles = sort(videoFiles);

% show starting message
hUIControl = hObject.hUIControl;
hFig = ancestor(hUIControl, 'figure');
handles = guidata(hFig);
set(handles.text14, 'String', 'creating configuration file (csv) ...');
disableAllButtons(handles);
pause(0.01);

tic;

% create config files if possible
[status, tebleItems, videoPaths, videoFiles] = openOrNewProject(videoPaths, videoFiles, handles.template, [], handles.addFileMode);

time = toc;

% show result message
if status
    set(handles.text14, 'String',strcat('creating configuration file (csv) ... done!     t =',num2str(time),'s'));
    set(handles.text9,'String','Ready','BackgroundColor','green');
else
    set(handles.text14, 'String',strcat('can not output configuration file (csv)'));
    set(handles.text9,'String','Failed','BackgroundColor','red');
end
checkAllButtons(handles);

% update uitable
handles.uitable2.Data = tebleItems;


%% TPro command line mode
function runCommandLineMode(hObject, eventdata, handles)
if handles.commandError > 0
    delete(hObject);
    return;
end
% start janeria trx file process
if length(handles.janeriaTrxPath) > 0
    cmdJaneriaTraxDataResult(handles);
    delete(hObject); % close window
    return;
end
% start batch process
if length(handles.batch) > 0
    % load batch file
    if ~exist(handles.batch, 'file')
        disp(['can not read batch file : ' handles.batch]);
        delete(hObject);
        return;
    end

    confTable = readtable(handles.batch);
    batches = table2cell(confTable);

    videoPaths = {};
    videoFiles = {};
    for i=1:size(batches,1)
        videoPaths = [videoPaths; [handles.path '/']];
        videoFiles = [videoFiles; batches{i,2}];
    end
    % do not rewrite input_control csv at only tracking or export
    if ~(handles.autobackground || handles.autodetect)
        batches = [];
    end

    % create config files if possible
    [status, tebleItems, videoPaths, videoFiles] = openOrNewProject(videoPaths, videoFiles, [], batches, false);
    if ~status
        disp('failed to create a configuration file');
        delete(hObject);
        return;
    end
    handles.uitable2.Data = tebleItems;
end
% start to load movie files
if length(handles.movies) > 0
    videoFiles = {};
    videoPaths = {};
    for i=1:length(handles.movies)
        [path, name, ext] = fileparts(handles.movies{i});
        if isempty(path)
            videoPaths = [videoPaths; './'];
        else
            videoPaths = [videoPaths; [path '/']];
        end
        videoFiles = [videoFiles; [name ext]];
    end
    % sort input files
    videoFiles = sort(videoFiles);

    % create config files if possible
    [status, tebleItems, videoPaths, videoFiles] = openOrNewProject(videoPaths, videoFiles, handles.template, [], false);
    if ~status
        disp('failed to create a configuration file');
        delete(hObject);
        return;
    end
    handles.uitable2.Data = tebleItems;
end
% create roi files
if length(handles.rois) > 0
    roiFiles = {};
    for i=1:length(handles.rois)
        roiFileName = handles.rois{i};
        if exist(roiFileName, 'file')
            roiImage = imread(roiFileName);
            clear roiImage;
        end
        roiFiles = [roiFiles; roiFileName];
    end

    for i=1:length(videoFiles)
        confPath = [videoPaths{i} '/' videoFiles{i} '_tpro/'];
        csvFileName = [confPath 'roi.csv'];
        confFileName = [confPath 'input_video_control.csv'];

        % save roi.csv
        T = array2table(roiFiles);
        writetable(T,csvFileName,'WriteVariableNames',false);

        % update ROI param in configuration
        confTable = readtable(confFileName);
        record = table2cell(confTable);
        record{10} = length(roiFiles);
        status = saveInputControlFile(confFileName, record);
        if ~status
            disp(['failed to save a configuration file : ' confFileName]);
            delete(hObject);
            return;
        end
    end
end
% update uitable
checkAllButtons(handles);
pause(0.01);

if handles.autobackground
    pushbutton2_Callback(handles.pushbutton2, eventdata, handles)
end
if handles.autodetect
    pushbutton4_Callback(handles.pushbutton4, eventdata, handles)
end
if handles.autotracking
    pushbutton5_Callback(handles.pushbutton5, eventdata, handles)
end
if ~isempty(handles.pi)
    cmdCalcPIAndExportResult(handles)
end
if handles.autodcd
    cmdCalcDcdAndExportResult(handles)
end
if ~isempty(handles.analyseSrc)
    cmdAnalyseDataAndExportResult(handles)
end
if ~isempty(handles.mergeMatData)
    cmdMatDataMerge(handles)
end
if ~isempty(handles.extMatData)
    cmdMatDataExtract(handles)
end
if handles.autofinish
    delete(hObject);
end


%% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


%% open or add file mode
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(hObject,'Value');
if val > 0
    handles.addFileMode = true;
    set(handles.pushbutton1,'String','Add movie files');
else
    handles.addFileMode = false;
    set(handles.pushbutton1,'String','Open movie files');
end
guidata(hObject, handles);

%% prepare--- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.text9,'String','Running','BackgroundColor','red');

addpath(genpath('../input_share'));

% show file select modal
[fileNames, videoPath, filterIndex] = uigetfile( {  ...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', ...
    'MultiSelect', 'on', '../input_share');

if ~filterIndex
    set(handles.text9,'String', 'Canceled', 'BackgroundColor', 'red');
    return;
end

% show starting message
set(handles.text14, 'String', 'creating configuration file (csv) ...');
disableAllButtons(handles);
pause(0.01);

tic;

if ischar(fileNames)
    fileCount = 1;
else
    fileCount = size(fileNames,2);
end

% process all selected files
videoPaths = {};
videoFiles = {};

for i = 1:fileCount
    if fileCount > 1
        fileName = fileNames{i};
    else
        fileName = fileNames;
    end
    videoFiles = [videoFiles; fileName];
    videoPaths = [videoPaths; videoPath];
end
% sort input files
videoFiles = sort(videoFiles);

% create config files if possible
[status, tebleItems, videoPaths, videoFiles] = openOrNewProject(videoPaths, videoFiles, handles.template, [], handles.addFileMode);

time = toc;

% show result message
if status 
    set(handles.text14, 'String',strcat('creating configuration file (csv) ... done!     t =',num2str(time),'s'));
    set(handles.text9, 'String','Ready','BackgroundColor','green');
else
    set(handles.text14, 'String',strcat('can not output configuration file (csv)'));
    set(handles.text9, 'String','Failed','BackgroundColor','red');
end
checkAllButtons(handles);
% update uitable
handles.uitable2.Data = tebleItems;


% bg--- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    errordlg('please select movies before operation.', 'Error');
    return;
end

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    C = checkConfigCompatibility(C);
    records = [records; C];
end

% show start text
set(handles.text14, 'String','detecting background ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

uniquePaths = unique(videoPaths);
for i=1:length(uniquePaths)
    addpath(uniquePaths{i});
end
bgAlgorithm = readTproConfig('bgAlgorithm', 'mode');

tic % start timer

% background detection for active movie
for data_th = 1:size(records,1)
    % check active flag
    if ~records{data_th, 1}
        continue;
    end

    shuttleVideo = TProVideoReader(videoPaths{data_th}, records{data_th,2}, records{data_th,6}, records{data_th,7});

    % show detecting message
    set(handles.text14, 'String', ['detecting background for ', shuttleVideo.name]);

    % set output file name
    pathName = strcat(videoPaths{data_th}, shuttleVideo.name, '_tpro/');
    backgroundFileName = [pathName 'background.png'];

    % show startEndDialog or command line auto start
    if handles.autobackground
        startFrame = records{data_th, 4};
        endFrame = records{data_th, 6};
        isInvert = records{data_th, 12};
        checkNums = 50;
        if ~isempty(handles.bgOp)
            if ~strcmp(handles.bgOp{1},'start')
                startFrame = str2num(handles.bgOp{1});
            end
            if ~strcmp(handles.bgOp{2},'end')
                endFrame = str2num(handles.bgOp{2});
            end
            checkNums = str2num(handles.bgOp{3});
        end

        % apply template
        if handles.tmpindex > 0
            modeFileName = getTproEtcFile('mode_template.csv');
            if ~exist(modeFileName, 'file')
                errordlg(['mode template file not found : ' modeFileName], 'Error');
                return;
            end
            confTable = readtable(modeFileName);
            templates = table2cell(confTable);
            template = {templates{handles.tmpindex,:}};
            template(1:7) = {records{data_th, 1:7}};
            template{10} = records{data_th, 10};

            confFileName = [pathName 'input_video_control.csv'];
            status = saveInputControlFile(confFileName, template);
            if ~status
                errordlg(['failed to save a configuration file : ' confFileName], 'Error');
                return;
            end
            isInvert = template{12};
        end
    else
        [dlg, startFrame, endFrame, checkNums, detectMode] = startEndDialog({'1', num2str(shuttleVideo.NumberOfFrames), shuttleVideo.name});
        delete(dlg);
        if startFrame < 0
            continue;
        end

        % update configuration with mode template
        modeFileName = getTproEtcFile('mode_template.csv');
        if ~exist(modeFileName, 'file')
            errordlg(['mode template file not found : ' modeFileName], 'Error');
            return;
        end
        confTable = readtable(modeFileName);
        templates = table2cell(confTable);
        template = {templates{detectMode,:}};
        template(1:7) = {records{data_th, 1:7}};
        template{10} = records{data_th, 10};

        confFileName = [pathName 'input_video_control.csv'];
        status = saveInputControlFile(confFileName, template);
        if ~status
            errordlg(['failed to save a configuration file : ' confFileName], 'Error');
            return;
        end
        isInvert = template{12};
    end

    if startFrame < 0
        continue;
    end
    if (isempty(startFrame) || strcmp(startFrame,'auto') || startFrame <= 0)
        startFrame = 1;
    end
    if (endFrame - startFrame + 1) < checkNums
        checkNums = (endFrame - startFrame + 1);
    end

    % initialize output matrix 
    frameImage = TProRead(shuttleVideo,1);
    [m,n,l] = size(frameImage);
    grayImages = uint8(zeros(m,n,checkNums));
    clear frameImage;

    % generate random
    r = randperm(endFrame - startFrame + 1);
    r = r(1:checkNums);

    % show wait dialog
    hWaitBar = waitbar(0,'processing ...','Name',['detecting background for ', shuttleVideo.name],...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitBar,'canceling',0);

    % find appropriate background pixels
    for i = 1 : checkNums
        % Check for Cancel button press
        isCancel = getappdata(hWaitBar, 'canceling');
        if isCancel
            break;
        end
        % Report current estimate in the waitbar's message field
        waitbar(i/checkNums, hWaitBar, [num2str(100*i/checkNums) ' %']);
        pause(0.001);

        frameImage = TProRead(shuttleVideo, r(i) + startFrame - 1);
        if size(frameImage,3) == 1
            grayImage = frameImage;
        else
            grayImage = rgb2gray(frameImage);
        end
        if isInvert
            grayImage = imcomplement(grayImage);
        end
        grayImages(:,:,i) = grayImage;
        clear frameImage;
    end
    % get candidate image
    switch bgAlgorithm
    case 'mean'
        bgImage = mean(grayImages,3); 
    case 'max'
        bgImage = max(grayImages,[],3); 
    otherwise
        bgImage = mode(grayImages,3); % this takes much memory and CPU power
    end
    pause(3); % wait for freeing memory

    % sometimes fly stays same position. and mode does not work well.
    % check its mean color and difference each pixels.
    bgMeanImage = mean(grayImages,3);
    maxImage = max(grayImages,[],3); % get most blight image

    diffImage = abs(single(bgImage) - bgMeanImage);
    diffImage2 = maxImage - bgImage;
    for x = 1 : n
        for y = 1 : m
            if diffImage(y,x) > 50 || diffImage2(y,x) > 100
                bgImage(y,x) = maxImage(y,x);
            end
        end
    end
    
    % delete dialog bar
    delete(hWaitBar);
    
    if isCancel
        continue;
    end
    
    % create new background window if it does not exist
    if ~exist('figureWindow','var') || isempty(figureWindow) || ~ishandle(figureWindow)
        figureWindow = figure('name','detecting ','NumberTitle','off');
    end

    if isInvert
        bgImage = imcomplement(bgImage);
    end
    % show background image
    figure(figureWindow);
    clf;
    imshow(bgImage);
    set(figureWindow, 'name', ['background for ', shuttleVideo.name]);

    % output png file
    disp(['imwrite : ' backgroundFileName]);
    imwrite(bgImage, backgroundFileName);
    clear bgImage;
end

% close background image window
if exist('figureWindow','var') && ~isempty(figureWindow) && ishandle(figureWindow)
    pause(2);
    if ishandle(figureWindow) % sometime closed by user
        close(figureWindow);
    end
end

% show end text
time = toc;
set(handles.text14, 'String',strcat('detecting background ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);


% check_threshold--- Executes on button press in pushbutton3
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    errordlg('please select movies before operation.', 'Error');
    return;
end

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    C = checkConfigCompatibility(C);
    records = [records; C];
end

% show start text
set(handles.text14, 'String','checking detection threashold ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

uniquePaths = unique(videoPaths);
for i=1:length(uniquePaths)
    addpath(uniquePaths{i});
end

% delete last config cache
lastConfigFile = getTproEtcFile('last_detect_config.mat');
if exist(lastConfigFile, 'file')
    delete(lastConfigFile);
end

% loop for every movies
for i = 1 : size(records,1)
    % show detection optimizer
    dlg = detectoptimizer({num2str(i)});
    delete(dlg);
    pause(0.1);
end

set(handles.text14, 'String',strcat('checking detection threashold ... done!'))
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);

%%
% detection--- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    errordlg('please select movies before operation.', 'Error');
    return;
end

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    C = checkConfigCompatibility(C);
    records = [records; C];
end

exportDcd = readTproConfig('exportDcd', 0);
dcdRadius = readTproConfig('dcdRadius', 7.5);
dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);
meanBlobmajor = readTproConfig('meanBlobMajor', 3.56);
auto1stBlobTh = readTproConfig('auto1stFrameBlobTh', 0.8);
exportDetectionText = readTproConfig('exportDetectionText', 1);
detectWings = readTproConfig('detectWings', 1);

% show start text
set(handles.text14, 'String','detection ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

uniquePaths = unique(videoPaths);
for i=1:length(uniquePaths)
    addpath(uniquePaths{i});
end

% parameters setting
tic % start timer

% blob center detection (1)
blob_center_enable = 1;

% extrema detection (0)
extrema_enable = 0;

% deep learning data
netForFrontBack = [];
classifierFrontBack = [];
if exist('./deeplearningFrontBack2.mat', 'file')
    load('./deeplearningFrontBack2.mat');
end

% added on 2016-07-28
for data_th = 1:size(records,1)
    % check active flag
    if ~records{data_th, 1}
        continue;
    end
    record = records(data_th,:);
    blob_threshold = record{8};
    start_frame = record{4};
    end_frame = record{5};
    frame_steps = record{16};
    h = record{13};
    sigma = record{14};
    area_pixel = record{15};
    blobSeparateRate = record{17};
    roiNum = record{10};
    isInvert = record{12};
    mmPerPixel = record{9};
    % check compatibility
    filterType = getVideoConfigValue(record, 18, 'log');
    maxSeparate = getVideoConfigValue(record, 19, 4);
    isSeparate = getVideoConfigValue(record, 20, 1);
    maxBlobs = getVideoConfigValue(record, 21, 0);
    delRectOverlap = getVideoConfigValue(record, 22, 0);
    rRate = getVideoConfigValue(record, 23, 1);
    gRate = getVideoConfigValue(record, 24, 1);
    bRate = getVideoConfigValue(record, 25, 1);
    keepNear = getVideoConfigValue(record, 26, 0);
    contMin = getVideoConfigValue(record, 29, 0);
    contMax = getVideoConfigValue(record, 30, 0);
    sharpRadius = getVideoConfigValue(record, 31, 0);
    sharpAmount = getVideoConfigValue(record, 32, 0);
    templateCount = getVideoConfigValue(record, 33, 0);
    tmplMatchTh = getVideoConfigValue(record, 34, 0);
    tmplSepNum = getVideoConfigValue(record, 35, 4);
    tmplSepTh = getVideoConfigValue(record, 36, 0.85);
    overlapTh = getVideoConfigValue(record, 37, 0.17);
    wingColorMin = getVideoConfigValue(record, 38, 140);
    wingColorMax = getVideoConfigValue(record, 39, 216);
    wingRadiusRate = getVideoConfigValue(record, 40, 0.55);
    wingColorRange = getVideoConfigValue(record, 41, 1);
    wingCircleStep = getVideoConfigValue(record, 42, 10);
    ignoreEccTh = getVideoConfigValue(record, 43, 0.75);
    auto1st1 = getVideoConfigValue(record, 44, '-');
    auto1st1val = getVideoConfigValue(record, 45, 0);
    auto1st2 = getVideoConfigValue(record, 46, '-');
    auto1st2val = getVideoConfigValue(record, 47, 0);
    isColorFilter = (rRate ~= 1 || gRate ~= 1 || bRate ~= 1);

    confPath = [videoPaths{data_th} videoFiles{data_th} '_tpro/'];
    if ~exist([confPath 'multi'], 'dir')
        mkdir([confPath 'multi']);
    end

    shuttleVideo = TProVideoReader(videoPaths{data_th}, records{data_th,2}, records{data_th,6}, records{data_th,7});

    % ROI
    roi_mask = [];
    roiMasks = {};
    csvFileName = [confPath 'roi.csv'];
    if exist(csvFileName, 'file')
        roiTable = readtable(csvFileName,'ReadVariableNames',false);
        roiFiles = table2cell(roiTable);
    end
    for i=1:roiNum
        if exist(csvFileName, 'file')
            roiFileName = roiFiles{i};
        else
            if i==1 idx=''; else idx=num2str(i); end
            roiFileName = [confPath 'roi' idx '.png'];
        end
        if exist(roiFileName, 'file')
            img = imread(roiFileName);
            roiMasks = [roiMasks, im2single(img)];
            if i==1
                roi_mask = roiMasks{i};
            else
                roi_mask = roi_mask | roiMasks{i};
            end
        end
    end

    % background
    bgImageFile = strcat(confPath,'background.png');
    if exist(bgImageFile, 'file')
        bgImage = imread(bgImageFile);
        if isInvert
            bgImage = imcomplement(bgImage);
        end
        if size(size(bgImage),2) == 2 % one plane background
            bgImage(:,:,2) = bgImage(:,:,1);
            bgImage(:,:,3) = bgImage(:,:,1);
        end
        bgImage = rgb2gray(bgImage);
        bg_img_double = single(bgImage);
        bg_img_mean = mean(mean(bgImage));
    else
        bg_img_double = [];
        bg_img_mean = [];
    end

    % template matching image
    templateImages = {};
    for i=1:templateCount
        if i==1 idx=''; else idx=num2str(i); end
        templateFileName = [confPath 'template' idx '.png'];
        if exist(templateFileName, 'file')
            tmplImage = imread(templateFileName);
            tmplImage = rgb2gray(tmplImage);
            tmplImage = 255 - tmplImage;
            tmplImage = single(tmplImage);
            templateImages = [templateImages, tmplImage];
        end
    end

    % get blob analysis
    hBlobAnls = getVisionBlobAnalysis();

    % finding first frame
    if ~strcmp(auto1st1, '-') && (isempty(start_frame) || strcmp(start_frame,'auto') || start_frame <= 0)
        disp(['finding first frame : ' shuttleVideo.name]);
        hWaitBar = waitbar(0,'finding first frame ...','Name',['finding first frame ', shuttleVideo.name],...
                    'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
        setappdata(hWaitBar,'canceling',0)

        type = auto1st1;
        typeVal = auto1st1val;
        fffStep = 1;

        roiNanMask = double(roi_mask);
        roiNanMask(roiNanMask==0) = NaN;
        for i = 1 : end_frame
            % Check for Cancel button press
            isCancel = getappdata(hWaitBar, 'canceling');
            if isCancel
                break;
            end

            % Report current estimate in the waitbar's message field
            waitbar(i/end_frame, hWaitBar, [num2str(100*i/end_frame) ' %']);
            pause(0.001);

            % read a frame and process image
            img = TProRead(shuttleVideo, i);
            if size(img,3) > 1
                img = rgb2gray(img);
            end
            if strcmp(type, 'pxIntensityLess') || strcmp(type, 'pxIntensityMore')
                img = double(img) .* roiNanMask;
                val = nanmean(nanmean(img));
            elseif strcmp(type, 'maxBlobAreaLess') || strcmp(type, 'maxBlobAreaMore')
                img = imcomplement(img);
                img = double(img) .* roi_mask;
                img = im2bw(uint8(img), auto1stBlobTh);
                img = bwareaopen(img, 25); % delete pixels less than 25
                % blob analysis
                [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(hBlobAnls, img);
                if isempty(AREA)
                    val = 0;
                else
                    val = nanmax(AREA);
                end
            end
            switch type
            case {'pxIntensityLess', 'maxBlobAreaLess'}
                if val <= typeVal
                    fffStep = fffStep + 1;
                end
            case {'pxIntensityMore', 'maxBlobAreaMore'}
                if val >= typeVal
                    fffStep = fffStep + 1;
                end
            end
            if fffStep == 2
                if ~strcmp(auto1st2, '-')
                    type = auto1st2;
                    typeVal = auto1st2val;
                else
                    break;
                end
            elseif fffStep == 3
                break;
            end
        end
        % delete dialog bar
        delete(hWaitBar);
        if isCancel
            continue;
        end
        % set start frame
        start_frame = i;
        % update configuration file
        record{4} = i;
        confFileName = [confPath 'input_video_control.csv'];
        status = saveInputControlFile(confFileName, record);
        if ~status
            errordlg(['failed to save a configuration file : ' confFileName], 'Error');
            continue;
        end
    end

    % make output folder
    filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
    if exportDetectionText > 0
        for i=1:roiNum
            outputPath = [confPath 'detect_output/' filename '_roi' num2str(i)];
            if ~exist(outputPath, 'dir')
                mkdir(outputPath);
            end
        end
    end
    insideNum = end_frame - start_frame + 1;
    outFrameNum = ceil(insideNum / frame_steps);
    X = cell(1,outFrameNum);
    Y = cell(1,outFrameNum);
    X_update2 = X;
    Y_update2 = Y;
    detection_num = nan(2,outFrameNum);
    blobAvgSize = 0;
    checkNums = 25; % for finding middle area size
    if checkNums > insideNum
        checkNums = insideNum;
    end

    % finding middle area size
    disp(['finding middle area size : ' shuttleVideo.name]);
    hWaitBar = waitbar(0,'finding middle area size ...','Name',['finding middle area size ', shuttleVideo.name],...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitBar,'canceling',0)

    % generate random
    r = randperm(insideNum);
    r = r(1:checkNums);
    areas = [];
    for i = 1 : checkNums
        % Check for Cancel button press
        isCancel = getappdata(hWaitBar, 'canceling');
        if isCancel
            break;
        end

        % Report current estimate in the waitbar's message field
        waitbar(i/checkNums, hWaitBar, [num2str(100*i/checkNums) ' %']);
        pause(0.001);

        % read a frame and process image
        frameImage = TProRead(shuttleVideo, r(i) + start_frame - 1);
        if size(frameImage,3) == 1
            grayImg = frameImage;
        else
            grayImg = rgb2gray(frameImage);
        end
        if isInvert
            grayImg = imcomplement(grayImg);
        end
        clear frameImage;
        if ~isempty(bg_img_mean)
            grayImg = grayImg + (bg_img_mean - mean(mean(grayImg)));
            grayImageDouble = single(grayImg);
            img = bg_img_double - grayImageDouble;
            img = uint8(img);
            img = imcomplement(img);
        else
            img = grayImg;
        end
        % sharp and consrast filters
        if contMin > 0 && contMax > 0
            img = imadjust(img, [contMin; contMax]);
        end
        if sharpRadius > 0 && sharpAmount > 0
            img = imsharpen(img, 'Radius',sharpRadius, 'Amount',sharpAmount);
        end
        %do the blob filter
        blob_img = PD_blobfilter(img, h, sigma, filterType);
        % ROI
        if ~isempty(roi_mask)
            blob_img = blob_img .* roi_mask;
        end
        % binarize
        img = im2bw(blob_img, blob_threshold);
        blob_img_logical2 = bwareaopen(img, area_pixel);   % delete blob that has area less than 50

        % step
        [AREA, CENTROID, BBOX, MAJORAXIS, MINORAXIS, ORIENTATION, ECCENTRICITY, EXTENT] = step(hBlobAnls, blob_img_logical2);
        areas = [areas; AREA];
    end
    % delete dialog bar
    delete(hWaitBar);
    if isCancel
        continue;
    end
    blobAvgSize = nanmedian(areas);
    disp(['middle area size : ' num2str(blobAvgSize)]);

    % start detection
    disp(['start detection : ' shuttleVideo.name]);

%load(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'.mat'));
%load(strcat('./multi/detect_',shuttleVideo.name,'_',filename,'keep_count.mat'));
%X_update2 = X;
%Y_update2 = Y;
%if size(X,2) <= 1
    % show wait dialog
    hWaitBar = waitbar(0,'processing ...','Name',['detecting for ', shuttleVideo.name],...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitBar,'canceling',0)

    % loading instance each PD_Blob_center is slow. so allocate instances first.
    hFindMax = vision.LocalMaximaFinder( 'Threshold', single(-1));
    hConv2D = vision.Convolver('OutputSize','Valid');

    keep_i = [];
    keep_count = [];
    keep_mean_blobmajor = [];
    keep_mean_blobminor = [];

    i = 1;
    for i_count = start_frame : frame_steps : end_frame
        % Check for Cancel button press
        isCancel = getappdata(hWaitBar, 'canceling');
        if isCancel
            break;
        end
        % process detection
        img_real = TProRead(shuttleVideo, i_count);
        if isColorFilter && size(img_real,3) == 3
            img_real(:,:,1) = img_real(:,:,1) * rRate;
            img_real(:,:,2) = img_real(:,:,2) * gRate;
            img_real(:,:,3) = img_real(:,:,3) * bRate;
        end
        if size(img_real,3) == 1
            grayImg = img_real;
        else
            grayImg = rgb2gray(img_real);
        end
        if isInvert
            grayImg = imcomplement(grayImg);
        end
        clear img_real;
        if ~isempty(bg_img_mean)
            grayImg = grayImg + (bg_img_mean - mean(mean(grayImg)));
            grayImageDouble = single(grayImg);
            img = bg_img_double - grayImageDouble;
            img = uint8(img);
            step2img = imcomplement(img);
        else
            step2img = grayImg;
        end
        % sharp and consrast filters
        if contMin > 0 && contMax > 0
            step2img = imadjust(step2img, [contMin; contMax]);
        end
        if sharpRadius > 0 && sharpAmount > 0
            step2img = imsharpen(step2img, 'Radius',sharpRadius, 'Amount',sharpAmount);
        end

        %do the blob filter
        step3img = PD_blobfilter(step2img, h, sigma, filterType);

        % ROI
        if ~isempty(roi_mask)
            step3img = step3img .* roi_mask;
        end

        % imshow(step3img)
%                blob_img_1st = step3img;

        %                 if animal_type == 2     % rodent set blob_threshold_peak to be the maximum of blob_img_1st
        %                     blob_th_test = blob_threshold;
        %                     blob_img_test = step3img;
        %                     for th_i = 1:10
        %                         blob_img_test2 = blob_img_test;
        %                         idx_test = find(blob_img_test < blob_th_test);
        %                         blob_img_test2(idx_test) = nan;
        %                         if sum(sum(~isnan(blob_img_test2))) > 100
        %                             break;
        %                         else
        %                             blob_th_test = blob_th_test - 0.05;
        %                         end
        %                     end
        %                     blob_threshold = blob_th_test;
        %                 end
%                idx = find(step3img < blob_threshold);
%                step3img(idx) = nan ;

        %                 %%% find the number of detection
        %                 blob_img_logical = blob_img_1st;
        %                 blob_img_logical(~idx) = 1;
        %                 blob_img_logical(idx) = 0;
        %                 blob_img_logical = logical(blob_img_logical);
        %                 abc = bwareaopen(blob_img_logical, 50);
        %                 [AREA,CENTROID,BBOX] = step(H,abc);
        %                 dnum = dnum + size(AREA,1)

        %                     %% for output cut_Video_14.avi blob specific and normal thresholding
        %                     figure(1)
        %                     imshow(step3img(228:255,329:369))
        %                     set(gca,'Units','Normalized','position',[0.1,0.1,0.8,0.8]);
        %
        %                     figure(2)
        %                     img2 = uint8(img);
        %                     idx_img2 = find(img2 > 160);
        %                     idx2_img2 = find(img2 <= 160);
        %                     img2(idx_img2) = nan ;
        %                     img2(idx2_img2) = 255 ;
        %                     imshow(img2(228:255,329:369))
        %                     set(gca,'Units','Normalized','position',[0.1,0.1,0.8,0.8]);
        % %                     f=getframe;
        % %                     imwrite(f.cdata,strcat('./for_resource/','blob_after_thresholding','.png'));
        %                     keyboard

        %%% for output cut_Video_14.aviblob_after_thresholding
        %                     imshow(step3img)
        %                     f=getframe;
        %                     imwrite(f.cdata,strcat('./for_resource/','blob_after_thresholding','.png'));
        %                     keyboard

        %%% for output cut_Video_14.aviblob_splitting
        %                     imshow(step3img(60:130,320:390))
        %                     f=getframe;
        %                     imwrite(f.cdata,strcat('./for_resource/','blob_splitting','.png'));
        %                     keyboard

        %                 %% for output 3d splitting
        %
        %                                 blob_temp = step3img(60:130,320:390);
        %                                 blob_temp(1:end,:) = step3img(130:-1:60,320:390);
        %                                 surf(blob_temp);
        %                                 colormap(parula);
        %                                 axis([20 60 20 50 0.8 2.4])
        %                                 view(-15,29)
        %                                 xlabel('x','FontSize',18)
        %                                 ylabel('y','FontSize',18)
        %                                 zlabel('z','FontSize',18)
        %                                 set(gca,'fontsize',18)
        %                                 f=getframe;
        %                                 imwrite(f.cdata,strcat('./for_resource/','3dblob_splitting','.png'));
        %                                 keyboard

        img = im2bw(step3img, blob_threshold);
        blob_img_logical2 = bwareaopen(img, area_pixel);   % delete blob that has area less than 50

        % get blobs from step function
        if blob_center_enable
            [ X_update2{i}, Y_update2{i}, blobAreas, blobCenterPoints, blobBoxes, ...
              blobMajorAxis, blobMinorAxis, blobOrient, blobEcc, blobAvgSize ] = PD_blob_center( ...
                step2img, step3img, blob_img_logical2, blob_threshold, blobSeparateRate, blobAvgSize, ...
                tmplMatchTh, tmplSepNum, tmplSepTh, overlapTh, templateImages, ...
                isSeparate, delRectOverlap, maxBlobs, keepNear, ...
                hBlobAnls, hFindMax, hConv2D);
        end

        if extrema_enable

            [zmax,imax,zmin,imin] = extrema2(blob_img);

            [X{i},Y{i}] = ind2sub(size(blob_img),imax);

            % near point average
            [ X_update{i}, Y_update{i} ] = PD_npa(X{i}, Y{i}, npa_radius);

            % blob analysis
            if ba_enable
                % blob_img_logical is logical version of blob image after thresholding
                blob_img_logical = blob_img_1st;
                blob_img_logical(~idx) = 1;
                blob_img_logical(idx) = 0;
                blob_img_logical = logical(blob_img_logical);
                [ X_update2{i}, Y_update2{i} ] = PD_blob_analysis( H, blob_img_logical, X_update{i}, Y_update{i} );
                blob_img_logical2 = blob_img_logical;   % just copy blob_img_logical
            end
        end

        %%
        if size(netForFrontBack, 1) > 0
            [ keep_direction, keep_angle, keep_wings ] = PD_direction_deepLearning(step2img, blobAreas, blobCenterPoints, blobBoxes, meanBlobmajor, mmPerPixel, blobOrient, netForFrontBack, classifierFrontBack);
        elseif wingColorMax > 0 && detectWings > 0
            params = {  wingColorMin, wingColorMax, wingRadiusRate, ...
                        wingColorRange, wingCircleStep, ignoreEccTh };
            [ keep_direction, keep_angle, keep_wings ] = PD_direction3(step2img, blobAreas, blobCenterPoints, blobMajorAxis, blobOrient, blobEcc, params);
        else
            [ keep_direction, keep_angle, keep_wings ] = PD_direction(step2img, blobAreas, blobCenterPoints, blobBoxes, blobMajorAxis, blobMinorAxis, blobOrient);
        end
        % ith of the XY_update is the XY_update_to_keep_direction th of the keep direction
        % sort based on X_update2 and Y_update2
        keep_direction_sorted{i} = keep_direction;
        keep_ecc_sorted{i} = blobEcc';
        keep_angle_sorted{i} = keep_angle;
        keep_areas{i} = blobAreas';
        keep_major_axis{i} = blobMajorAxis';
        keep_minor_axis{i} = blobMinorAxis';
        keep_wings_sorted{i} = keep_wings;

        processRate = 100 * (i_count-start_frame)/(end_frame-start_frame+1);
        if extrema_enable
            if size(imax,1) == size(X_update{i},1)
                disp(strcat(num2str(data_th), 'th     >', num2str(processRate), '%', '     detect : ', num2str(size(imax,1))));
            elseif ba_enable
                disp(strcat(num2str(data_th), 'th     >', num2str(processRate), '%', '     detect : ', num2str(size(imax,1)), '   detect_npa : ', num2str(size(X_update{i},1)), '   detect_ba : ', num2str(size(X_update2{i},1))));
            else
                disp(strcat(num2str(data_th), 'th     >', num2str(processRate), '%', '     detect : ', num2str(size(imax,1)), '   detect_npa : ', num2str(size(X_update{i},1))));
            end
            detection_num(:,i) = [size(imax,1); size(X_update{i},1)];
        end

        if blob_center_enable
            disp([num2str(data_th), 'th >', num2str(processRate), '%', ' i:',num2str(i),' frame:',num2str(i_count), '  detect_blob_center : ', num2str(size(X_update2{i},1))]);
        end

        % graph for detection analysis
        keep_i = [keep_i i];
        keep_count = [keep_count size(X_update2{i},1)];
        keep_mean_blobmajor = [keep_mean_blobmajor mean(blobMajorAxis)];
        keep_mean_blobminor = [keep_mean_blobminor mean(blobMinorAxis)];
        % Report current estimate in the waitbar's message field
        rate = (i_count-start_frame+1)/(end_frame-start_frame+1);
        waitbar(rate, hWaitBar, [num2str(int64(100*rate)) ' %']);
        pause(0.001);
        i = i + 1;
    end
%end
    % delete dialog bar
    delete(hWaitBar);
    
    if isCancel
        continue;
    end
    
    img_h = size(grayImg, 1);

    X = X_update2;
    Y = Y_update2;

    % before saving, check standard deviation of fly count
    sd = std(keep_count);
    mcount = mean(keep_count);
    zerocnt = sum(keep_count==0) / length(keep_count);
    maxcnt = max(keep_count);
    mincnt = min(keep_count);
    if 0 < sd && sd < 1 && zerocnt < 0.2 && (maxcnt-mincnt) <= 5
        % fly count should be same every frame.
        % let's fix false positive or false negative
        errorCases = find(abs(keep_count - mcount) > 0.5);
        for i = 1 : size(errorCases, 2)
            idx = errorCases(i);
            errorFrameX = X{idx};
            errorFrameY = Y{idx};
            errorFrameAreas = keep_areas{idx};
            
            % error case 1 : [false positive] sometimes wing is separated as a individual blob
            if keep_count(idx) > mcount
                % find nearest points
                min1 = 1; min2 = 2;
                minDist = 4096; % initial dummy
                flyCount = size(errorFrameX, 1);
                for j = 1 : flyCount - 1
                    for k = j+1 : flyCount
                        dx = errorFrameX(j) - errorFrameX(k);
                        dy = errorFrameY(j) - errorFrameY(k);
                        dist = sqrt(dx*dx + dy*dy);
                        if minDist > dist
                            min1 = j; min2 = k;
                            minDist = dist;
                        end
                    end
                end
                % remove smaller one!
                if errorFrameAreas(min1) > errorFrameAreas(min2)
                    X{idx}(min2) = [];
                    Y{idx}(min2) = [];
                else
                    X{idx}(min1) = [];
                    Y{idx}(min1) = [];
                end
                keep_count(idx) = flyCount - 1;
            end
        end
    end

    % save data
    save(strcat(confPath,'multi/detect_',filename,'.mat'),  'X','Y', 'keep_direction_sorted', 'keep_ecc_sorted', 'keep_angle_sorted', 'keep_areas', 'keep_major_axis', 'keep_minor_axis', 'keep_wings_sorted');
    save(strcat(confPath,'multi/detect_',filename,'keep_count.mat'), 'keep_count', 'keep_mean_blobmajor', 'keep_mean_blobminor');

    % save data as text
    if exportDetectionText > 0
        for i=1:roiNum
            outputPath = [confPath 'detect_output/' filename '_roi' num2str(i) '/'];
            dataFileName = [outputPath shuttleVideo.name '_' filename];

            dcdparam = {};
            if exportDcd
                dcdpfile = [confPath 'multi/aggr_dcd_percent.mat'];
                if isfield(handles, 'dcdpfile')
                    dcdpfile = handles.dcdpfile;
                end
                dcdparam = {dcdRadius / mmPerPixel, dcdCnRadius / mmPerPixel, dcdpfile};
            end
            saveDetectionResultText(dataFileName, X, Y, i, img_h, roiMasks, dcdparam);
            %saveDetectionEccAxesResultText(dataFileName, X, Y, i, img_h, roiMasks, keep_ecc_sorted, keep_major_axis, keep_minor_axis);

            % open text file with notepad (only windows)
            % system(['start notepad ' countFileName]);
            if ~isfield(handles, 'showcount') || handles.showcount
                countFileName = [dataFileName '_count.txt'];
                disp(['winopen : ' countFileName]);
                winopen(countFileName);
            end
        end
    end

    set(handles.text9, 'String','100 %'); % done!
    pause(3); % pause 3 sec
end

% show end text
time = toc;
disp(['detection ... done!     t =',num2str(time),'s']);
set(handles.text14, 'String',strcat('detection ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);


% tracker--- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)  % tracker
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    errordlg('please select movies before operation.', 'Error');
    return;
end

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    C = checkConfigCompatibility(C);
    records = [records; C];
end

uniquePaths = unique(videoPaths);
for i=1:length(uniquePaths)
    addpath(uniquePaths{i});
end

% show start text
set(handles.text14, 'String','tracking ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

%% parameters setting
tic % start timer

% for strike track
STRIKE_TRACK_TH = readTproConfig('trackingStrikeTh', 5);

% assignment for no assignment
assign_for_noassign = 1;

% minimum distance threshold
min_dist_threshold = 50;

% Kalman only
kalman_only_enable = 0;

% kalman filter multiple object tracking

% Kalman

dt = 1;  % sampling rate
frame_start = 1; % starting frame
MAX_FLIES = readTproConfig('trackingFlyMax', 800); % maxmum number of flies
RECURSION_LIMIT = readTproConfig('recursionLimit', 500); % maxmum number of recursion limit
IGNORE_NAN_COUNT = readTproConfig('ignoreNaNCount', 20); % maxmum NaN count of fly (removed from tracking pair-wise)
DELETE_TRACK_TH = readTproConfig('trackingDeleteTh', 5); % delete tracking threshold: minimam valid frames
PILEUPS_SWAP_TH = readTproConfig('pileupsSwapTh', 7); % pile-ups checking threshold at tracking
KEEP_DATA_MAX = 10;

exportDcd = readTproConfig('exportDcd', 0);
exportMd = readTproConfig('exportMinDistance', 0);
dcdRadius = readTproConfig('dcdRadius', 7.5);
dcdCnRadius = readTproConfig('dcdCnRadius', 2.5);
exportTrackingText = readTproConfig('exportTrackingText', 1);
flipRangeMax = readTproConfig('trackingFlipRange', 1);

% set recursion limit
set(0,'RecursionLimit',RECURSION_LIMIT);

u = 0; % no acceleration
noise_process = 1; % process noise
noise_meas_x = .1;  % measurement noise in x direction
noise_meas_y = .1;  % measurement noise in y direction
Ez = [noise_meas_x 0; 0 noise_meas_y];
Ex = [dt^4/4 0 dt^3/2 0; ...
    0 dt^4/4 0 dt^3/2; ...
    dt^3/2 0 dt^2 0; ...
    0 dt^3/2 0 dt^2].*noise_process^2; % Ex convert the process noise (stdv) into covariance matrix

P = Ex; % estimate of initial position variance (covariance matrix)

%% update equations in 2-D
A = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1];
B = [(dt^2/2); (dt^2/2); dt; dt];
C = [1 0 0 0; 0 1 0 0];

for data_th = 1:size(records,1)
    if ~records{data_th, 1}
        continue;
    end
    record = records(data_th,:);
    start_frame = record{4};
    end_frame = record{5};
    frame_steps = record{16};
    roiNum = record{10};
    fpsNum = record{7};
    mmPerPixel = record{9};
    reject_dist = record{11} / mmPerPixel / fpsNum;
    fixedTrackNum = getVideoConfigValue(record, 27, 0);
    fixedTrackDir = getVideoConfigValue(record, 28, 0);
    ignoreEccTh = getVideoConfigValue(record, 43, 0.75);

    shuttleVideo = TProVideoReader(videoPaths{data_th}, records{data_th,2}, records{data_th,6}, records{data_th,7});

    % make output folder
    confPath = [videoPaths{data_th} videoFiles{data_th} '_tpro/'];
    filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
    if exportTrackingText > 0
        if ~exist([confPath 'output'], 'dir')
            mkdir([confPath 'output']);
        end
        for i=1:roiNum
            outputDataPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
            if ~exist(outputDataPath, 'dir')
                mkdir(outputDataPath);
            end
        end
    end

    % load detection
    load(strcat(confPath,'multi/detect_',filename,'.mat'));

    % load roi
    roiImage = [];
    roiMasks = {};
    csvFileName = [confPath 'roi.csv'];
    if exist(csvFileName, 'file')
        roiTable = readtable(csvFileName,'ReadVariableNames',false);
        roiFiles = table2cell(roiTable);
    end
    for i=1:roiNum
        if exist(csvFileName, 'file')
            roiFileName = roiFiles{i};
        else
            if i==1 idx=''; else idx=num2str(i); end
            roiFileName = [confPath 'roi' idx '.png'];
        end
        if exist(roiFileName, 'file')
            img = imread(roiFileName);
            roiMasks = [roiMasks, im2single(img)];
            if i==1
                roiImage = roiMasks{i};
            else
                roiImage = roiImage | roiMasks{i};
            end
        end
    end

    % initialize result variables
    Q_loc_meas = []; % location measure

    % initialize estimation variables for two dimensions
    Q = [X{frame_start} Y{frame_start} zeros(length(X{frame_start}),1) zeros(length(X{frame_start}),1)]';
    Q_estimate = nan(4, MAX_FLIES, 'single');
    Q_estimate(:,1:size(Q,2)) = Q;  % initial location
    direction_track = nan(2, MAX_FLIES, 'single'); % initialize the direction
    direction_track(:,1:size(keep_direction_sorted{frame_start},2)) = keep_direction_sorted{frame_start};
    ecc_track = nan(1, MAX_FLIES, 'single');
    % ecc
    szMax = size(keep_ecc_sorted{frame_start},2);
    if szMax > 0
        ecc_track(:,1:szMax) = keep_ecc_sorted{frame_start};
    end
    % angle
    angle_track = nan(1, MAX_FLIES, 'single');
    szMax = size(keep_angle_sorted{frame_start},2);
    if szMax > 0
        angle_track(:,1:szMax) = keep_angle_sorted{frame_start};
    end
    % wings
    wings_track = nan(2, MAX_FLIES, 'single'); % initialize
    if exist('keep_wings_sorted', 'var')
        wings = keep_wings_sorted{frame_start};
        wings_track = nan(size(wings,1), MAX_FLIES, 'single'); % initialize
        wings_track(:,1:size(wings,2)) = wings;
        if size(wings,1) > 2 % for compatibility
            KEEP_DATA_MAX = 12;
        end
    end
    nancount = zeros(1,MAX_FLIES); % counting NaN each fly
    strk_trks = zeros(1, MAX_FLIES);  % counter of how many strikes a track has gotten
    flyNum =  find(isnan(Q_estimate(1,:))==1,1)-1 ; % initize number of track estimates

    keep_data = cell(1,KEEP_DATA_MAX);  % x y vx vy
    outFrameNum = int64((end_frame - start_frame + 1) / frame_steps) + 2;
    for i = 1:KEEP_DATA_MAX
        keep_data{i} = nan(outFrameNum, MAX_FLIES, 'single');
    end
    assignCost = nan(outFrameNum, 1, 'single');
    trackHistory = {};

    % size
    img_initial = TProRead(shuttleVideo,1);
    img_h = size(img_initial,1);
    img_w = size(img_initial,2);
    clear img_initial;
    
    disp(['start tracking : ' shuttleVideo.name]);

    % show wait dialog
    hWaitBar = waitbar(0,'processing ...','Name',['tracking for ', shuttleVideo.name],...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitBar,'canceling',0)

    t = 1;
    flyZeroCount = 0;
    for t_count = start_frame:frame_steps:end_frame
        % Check for Cancel button press
        isCancel = getappdata(hWaitBar, 'canceling');
        if isCancel
            break;
        end
        
        % make the given detections matrix
        Q_loc_meas = [X{t} Y{t}];
        direction_meas = keep_direction_sorted{t};

        % other params
        ecc_meas = keep_ecc_sorted{t};
        angle_meas = keep_angle_sorted{t};
        if exist('keep_wings_sorted', 'var')
            wings_meas = keep_wings_sorted{t};
        else
            wings_meas = [];
        end

        % do the kalman filter
        % Predict next state
        nD = size(X{t},1); %set new number of detections
        if nD == 0
            flyZeroCount = flyZeroCount + 1; % counting for reseting assign
        else
            flyZeroCount = 0; % reset
        end

        Q_estimate_before_update = Q_estimate;  % keep Q_estimate before the update

        %                 % keep data from Q_estimate_before_update
        %                 for F = 1:nF
        %
        %                     keep_data{1}(t,F) = Q_estimate_before_update(1,F);
        %                     keep_data{2}(t,F) = Q_estimate_before_update(2,F);
        %                     keep_data{3}(t,F) = Q_estimate_before_update(3,F);
        %                     keep_data{4}(t,F) = Q_estimate_before_update(4,F);
        %
        %                 end

        for F = 1:flyNum
            Q_estimate(:,F) = A * Q_estimate(:,F) + B * u;
            %         if (Q_estimate(1,F) > img_h) || (Q_estimate(2,F) > img_w) || (Q_estimate(1,F) < 0) || (Q_estimate(2,F) < 0)
            %             % if the predict is out of bound
            %             Q_estimate(:,F) = NaN;
            %         end
        end


        %predict next covariance
        P = A * P* A' + Ex;
        % Kalman Gain
        K = P*C'*inv(C*P*C'+Ez);


        % assign the detections to estimated track positions
        %make the distance (cost) matrice between all pairs rows = tracks, coln =
        %detections
        if ~isempty(Q_loc_meas)
            nanidx = find(isnan(Q_estimate(1,1:flyNum)));
            nancount(nanidx) = nancount(nanidx) + 1;
            idx = find(nancount(1,1:flyNum) < IGNORE_NAN_COUNT);
            idxlen = length(idx);

            est_dist0 = pdist([Q_estimate(1:2,idx)'; Q_loc_meas]);
            est_dist0 = squareform(est_dist0); %make square
            est_dist1 = est_dist0(1:idxlen,idxlen+1:end) ; %limit to just the tracks to detection distances

            %                 for est_count = 1:nF    % added on 2016-07-28
            %                     if min(est_dist(est_count,:)) < 50
            %                         est_dist(find(est_dist(est_count,:) ~= min(est_dist(est_count,:)))) = est_dist(find(est_dist(est_count,:) ~= min(est_dist(est_count,:)))) * 2;
            %                     end
            %                 end

            [asgnT, cost] = assignmentoptimal(est_dist1); %do the assignment with hungarian algo
            asgn = zeros(1,flyNum);
            invIdx = zeros(1,flyNum);
            if idxlen == 0
                asgn = asgnT;
            else
                for i=1:idxlen
                    fn = idx(i);
                    asgn(fn) = asgnT(i);
                    invIdx(fn) = i;
                end
            end
            %check for tough situations and if it's tough, just go with estimate and ignore the data
            %make asgn = 0 for that tracking element

            %check 1: is the detection far from the observation? if so, reject it.
            rej = [];
            for F = 1:flyNum
                if ~isempty(asgn) && asgn(F) > 0  % if track F has pair asgn(F)
                    estF = invIdx(F);
                    rej(F) = est_dist1(estF,asgnT(estF)) < reject_dist;
                    v1 = direction_track(:,F);
                    v2 = direction_meas(:,asgn(F));
                    if (norm(v1) ~= 0) && (norm(v2) ~= 0)
                        angle_v1_v2 = abs(acosd(dot(v1,v2)/norm(v1)/norm(v2)));  % calculate the angle between two vectors
                        
                        e1 = ecc_track(F);
                        e2 = ecc_meas(asgn(F));
                        ecc_e1_e2 = abs(e1 - e2);

                        rej(F) = (ecc_e1_e2 < 0.3 || angle_v1_v2 < 45); % reject if direction and ecc are too different
                    end
                else
                    rej(F) = 0;
                end
            end
            if size(asgn,2) > 0 && ~isempty(rej)
                asgn = asgn.*rej;
            end
            % check point distance each other
            if fixedTrackDir && t > 1
                for fn = 1:flyNum
                    cnt = sum(est_dist0(fn,1:flyNum) > fixedTrackDir);
                    if  cnt >= (flyNum-1) && flyNum >= 3
                        invFn = invIdx(fn);
                        asgn(invFn) = 0;
                    end
                end
            end

            % check 2
            if ~kalman_only_enable
                Q_estimate_before_update(1:2, (asgn ~= 0)) = NaN;
                Q_loc_meas2 = Q_loc_meas;
                members = ismember(1:size(Q_loc_meas,1),asgn);
                Q_loc_meas2(members,:) = NaN;

                idx2 = find(~isnan(Q_estimate_before_update(1,1:flyNum)));
                idxlen2 = length(idx2);
                est_dist3 = pdist([Q_estimate_before_update(1:2,idx2)'; Q_loc_meas2]);
                est_dist3 = squareform(est_dist3); %make square
                est_dist3 = est_dist3(1:idxlen2,idxlen2+1:end) ; %limit to just the tracks to detection distances

                % Closest Neighbour Approach
                asgn2 = asgn.*0;
                row_est_dist3 = max(sum(~isnan(est_dist3)));
                col_est_dist3 = max(sum(~isnan(est_dist3),2));
                if ((row_est_dist3 - col_est_dist3) >= 0)
                    count_target = col_est_dist3;
                else
                    count_target = row_est_dist3;
                end

                for count2 = 1:count_target
                    %                             if min(min(est_dist2)) < reject_dist    % check again for reject distance in CNA case 20161014
                    [mmin,m0] = min(est_dist3);
                    [nmin,n] = min(mmin);
                    if ~isempty(m0)
                        if size(est_dist3,1) > 1
                            m = m0(n);
                            if nmin < reject_dist
                                asgn2(idx2(m)) = n;
                            end
                            est_dist3(m,:) = NaN;
                            est_dist3(:,n) = NaN;
                        else
                            if mmin < reject_dist
                                asgn2(idx2(n)) = m0;
                            end
                            est_dist3(1,:) = NaN;
                        end
                    end
                    
                    %                             end   % fixed bug 2016-12-30
                end
                    
                asgn = asgn + asgn2;
            else
                asgn2 = asgn.*0;
            end

            % check 3 - pile-ups
            [m3,mi3] = min(est_dist1,[],2);
            log3 = nan(1,length(asgn));
            asgnInv = asgn(invIdx>0);
            if isempty(mi3)
                tmp = [];
            elseif size(mi3,1) == size(asgnInv,1)
                tmp = (mi3 == asgnInv);
            else
                tmp = (mi3' == asgnInv);
            end
            log3(invIdx>0) = tmp;
            idx3 = find(log3==0);
            for j=1:length(idx3)
                qidx = idx3(j);
                q = Q_estimate(:,qidx);
                v = sqrt(q(3)^2 + q(4)^2);
                jidx = invIdx(qidx);
                dist = est_dist1(jidx,mi3(jidx));
                if v < PILEUPS_SWAP_TH && dist < PILEUPS_SWAP_TH
                    % fly should not move
                    ridx = find(asgn==mi3(jidx));
                    if ~isempty(ridx)
                        tmp = asgn(qidx);
                        asgn(qidx) = mi3(jidx);
                        asgn(ridx(1)) = tmp;
                        disp(['fixed pile-ups at ' num2str(t_count) ' : ' num2str(qidx) ' <-> ' num2str(ridx(1))]);
                        trackHistory = [trackHistory; {'pileups',t_count,qidx,ridx(1)}];
                    end
                end
            end
            % recalc assign cost
            cost = 0;
            asgn3 = asgn(invIdx>0);
            for F = 1:length(asgn3)
                if asgn3(F) > 0
                    cost = cost + est_dist1(F,asgn3(F));
                end
            end
            assignCost(t) = cost;

            %apply the assingment to the update
            k = 1;
            velocity_temp2 = [];
            for F = 1:length(asgn)
                Q_estimate_previous = Q_estimate(:,k);
                asgnF = asgn(F);
                if asgnF > 0  % found its match
                    Q_estimate(:,k) = Q_estimate(:,k) + K * (Q_loc_meas(asgnF,:)' - C * Q_estimate(:,k)); % same as asgn
                    direction_track(:,k) = direction_meas(:,asgnF);   % update the direction to be the match's direction
                    ecc_track(:,k) = ecc_meas(:,asgnF);
                    angle_track(:,k) = angle_meas(:,asgnF);
                    if ~isempty(wings_meas)
                        wings_track(:,k) = wings_meas(:,asgnF);
                    end

                elseif asgnF == 0 % assignment for no assignment
                    if assign_for_noassign
                        y = round(Q_estimate(1,k));
                        x = round(Q_estimate(2,k));
                        if (y > img_h) || (x > img_w) || (y < 1) || (x < 1) || isnan(y) || isnan(x)
                            % if the predict is out of bound then delete
                            Q_estimate(:,k) = NaN;
                        elseif ~isempty(roiImage) && roiImage(y,x) == 0
                            % if the predict is out of ROI then stop fly movement
                            Q_estimate(1,k) = y - Q_estimate(3,k);
                            Q_estimate(2,k) = x - Q_estimate(4,k);
                            Q_estimate(3,k) = 0;
                            Q_estimate(4,k) = 0;
                        elseif fixedTrackDir && fixedTrackNum
                            % check if estimated point is too far or not
                            invK = [1:(k-1),(k+1):flyNum];
                            maxDir = max(est_dist0(k,invK));
                            if maxDir > fixedTrackDir
                                Q_estimate(1,k) = y - Q_estimate(3,k);
                                Q_estimate(2,k) = x - Q_estimate(4,k);
                                Q_estimate(3,k) = 0;
                                Q_estimate(4,k) = 0;
                            end
                        else
                            estF = invIdx(k);
                            if estF > 0
                                [m,i] = min(est_dist1(estF,:));
                                % find non assigned detection point and nearest measurement within min_dist_threshold, then estimate next point
                                if isempty(find(asgn==i)) && m < min_dist_threshold  
                                    Q_estimate(:,k) = Q_estimate(:,k) + K * (Q_loc_meas(i,:)' - C * Q_estimate(:,k));
                                end
                            end
                        end
                    end
                end

                % velocity thresholding, actually this is redundant. maybe I can ommit.
                if ~isnan(Q_estimate(1,k))  % if the value is not NaN
                    % velocity filter (delete or use previous if the velocity is higher than velocity_thres)
                    velocity = sqrt(Q_estimate(3,k)^2 + Q_estimate(4,k)^2);
                    if velocity > reject_dist
                        if fixedTrackNum
                            % stop movement
                            Q_estimate(1,k) = Q_estimate(1,k) - Q_estimate(3,k);
                            Q_estimate(2,k) = Q_estimate(2,k) - Q_estimate(4,k);
                            Q_estimate(3,k) = 0;
                            Q_estimate(4,k) = 0;
                        else
                            Q_estimate(:,k) = NaN;    % delete
                        end
                    end
                end

                k = k + 1;
            end

        end     % end of if ~isempty(Q_loc_meas)

        % update covariance estimation.
        P =  (eye(4)-K*C)*P;

        % keep data from Q_estimate
        keep_data{1}(t,1:flyNum) = Q_estimate(1,1:flyNum);    % x
        keep_data{2}(t,1:flyNum) = Q_estimate(2,1:flyNum);    % y
        keep_data{3}(t,1:flyNum) = Q_estimate(3,1:flyNum);    % vx
        keep_data{4}(t,1:flyNum) = Q_estimate(4,1:flyNum);    % vy
        keep_data{5}(t,1:flyNum) = direction_track(1,1:flyNum);   % fly head direction X
        keep_data{6}(t,1:flyNum) = direction_track(2,1:flyNum);   % fly head direction Y
        keep_data{7}(t,1:flyNum) = ecc_track(1,1:flyNum);     % ellipse body ecc
        keep_data{8}(t,1:flyNum) = angle_track(1,1:flyNum);   % ellipse body angle (-90 to 90)
        keep_data{9}(t,1:flyNum) = wings_track(1,1:flyNum);   % fly's right wing angle
        keep_data{10}(t,1:flyNum) = wings_track(2,1:flyNum);  % fly's left wing angle
        if size(wings_track,1) > 2
            keep_data{11}(t,1:flyNum) = wings_track(3,1:flyNum);   % fly's right wing angle (reverse side)
            keep_data{12}(t,1:flyNum) = wings_track(4,1:flyNum);  % fly's left wing angle (reverse side)
        end
        
        if ~isempty(Q_loc_meas)

            %find the new detections. basically, anything that doesn't get assigned is a new tracking
            new_trk = Q_loc_meas(~ismember(1:size(Q_loc_meas,1),asgn),:)';
            if ~isempty(new_trk) && ~fixedTrackNum
                Q_estimate(:,flyNum+1:flyNum+size(new_trk,2))=  [new_trk; zeros(2,size(new_trk,2))];
                flyNum = flyNum + size(new_trk,2);  % number of track estimates with new ones included
            end

        end  % end of if ~isempty(Q_loc_meas)
        
        %give a strike to any tracking that didn't get matched up to a detection
        if exist('asgn', 'var')
            aIdx = find(asgn>0);
            for j = 1:length(aIdx)
                k = aIdx(j);
                y = round(Q_estimate(1,k));
                x = round(Q_estimate(2,k));
                if (y > img_h) || (x > img_w) || (y < 1) || (x < 1) || isnan(y) || isnan(x)
                    % if the predict is out of bound then delete
                    asgn(k) = 0;
                elseif ~isempty(roiImage) && roiImage(y,x) == 0
                    % if the predict is out of ROI then delete
                    asgn(k) = 0;
                end
            end

            prev_strk_trks = strk_trks;
            no_trk_list = find(asgn==0);
            if ~isempty(no_trk_list)
                % check 1 frame error detection. sometimes it increase fly
                % number too much. so find such noise and clean fly number.
                if ~isempty(find(flyNum==no_trk_list)) && strk_trks(flyNum) == 0
                    if t <= 10
                        chkst = 1;
                    else
                        chkst = t - 10;
                    end
                    keep_data_x_fly = keep_data{1}(chkst:t,flyNum);
                    if length(find(~isnan(keep_data_x_fly))) == 1
                        % remove old 1 tracking frames
                        for j = 1:KEEP_DATA_MAX
                            keep_data{j}(t,flyNum) = NaN;
                        end
                        flyNum = flyNum - 1;
                    else
                        strk_trks(no_trk_list) = strk_trks(no_trk_list) + 1;
                    end
                else
                    strk_trks(no_trk_list) = strk_trks(no_trk_list) + 1;
                end
            end

            % consecutive strike
            % if the strike is not consecutive then reset
            strk_trks(strk_trks == prev_strk_trks) = 0;

            %if a track has a strike greater than 3, delete the tracking. i.e.
            %make it nan first vid = 3
            bad_trks = find(strk_trks > STRIKE_TRACK_TH);
            if ~isempty(bad_trks)
                if fixedTrackNum
                    if fixedTrackDir
                        nonAsgn = Q_loc_meas(~ismember(1:size(Q_loc_meas,1),asgn),:);
                        idx = asgn(find(asgn>0));
                        asgnLen = length(idx);
                        if ~isempty(nonAsgn) && asgnLen > 0
                            pts = [Q_loc_meas(idx,:); nonAsgn];
                            dist = pdist(pts);
                            dist1 = squareform(dist); %make square
                            for i=1:length(bad_trks)
                                if (asgnLen+i) <= size(dist1,1) && max(dist1(asgnLen+i,1:asgnLen)) < fixedTrackDir
                                    Q_estimate(1:2,bad_trks(i)) = pts(asgnLen+i,:)';
                                end
                            end
                        end
                    end
                    % stop movement
                    Q_estimate(3,bad_trks) = 0;
                    Q_estimate(4,bad_trks) = 0;
                else
                    Q_estimate(:,bad_trks) = NaN;

                    bad_trks = find(strk_trks ==(STRIKE_TRACK_TH+1));
                    if ~isempty(bad_trks)
                        % remove old 3 tracking frames
                        for j = 1:KEEP_DATA_MAX
                            keep_data{j}((t-(STRIKE_TRACK_TH-1)):t,bad_trks) = NaN;
                        end
                    end
                end
            end
        end

        if fixedTrackDir && t == 1 % if first track, check its distances
            points = Q_estimate(1:2, 1:flyNum)';
            dist = pdist(points);
            dist1 = squareform(dist); %make square
            fixedTrackDir = max(dist1(1,2:flyNum)) * 1.2;
            min_dist_threshold = fixedTrackDir;
        end

        rate = (t_count-start_frame+1)/(end_frame-start_frame+1);
        disp(['processing : ' shuttleVideo.name ' ' num2str(100*rate) '%  fn : ' num2str(flyNum) '  t : ' num2str(t)]);
        % Report current estimate in the waitbar's message field
        waitbar(rate, hWaitBar, [num2str(int64(100*rate)) ' %']);
        pause(0.01);
        t = t + 1;
    end
    
    % delete dialog bar
    delete(hWaitBar);

    if isCancel
        continue;
    end

    % find end of row (some frames has zero flies. so finding NaN is bad)
    end_row = t - 1;

    % delete useless data (mostly NaN tracking)
    delIdx = [];
    for i=1:flyNum
        if sum(~isnan(keep_data{1}(:,i))) <= DELETE_TRACK_TH
            delIdx = [delIdx, i];
        end
    end
    moveIdx = 1:flyNum;
    if ~isempty(delIdx)
        moveIdx(delIdx) = [];
        flyNum = length(moveIdx);
    end
    % organize keep_data
    for j = 1:KEEP_DATA_MAX
        keep_data{j} = keep_data{j}(:,moveIdx);
    end
    % inverse the angle upside-down
    keep_data{8} = -keep_data{8};

    % fix angle flip (direction & wing angle, except elliptic angle)
    beJumpLv = readTproConfig('beJumpLv', 63);
    vxy = calcVxy(keep_data{3}, keep_data{4}) * fpsNum * mmPerPixel;
    headAngle = calcDir(keep_data{5}, keep_data{6});
    [headAngle, keep_data] = fixHeadAndWingAngle(vxy, keep_data{7}, headAngle, keep_data, beJumpLv, ignoreEccTh, fpsNum, start_frame, flipRangeMax);

    % save keep_data
    save(strcat(confPath,'multi/track_',filename,'.mat'), 'keep_data', 'assignCost', 'trackHistory', '-v7.3');

    if exportTrackingText > 0
        % optional data export
        mdparam = [];
        dcdparam = [];
        if exportDcd
            dcdparam = [dcdRadius / mmPerPixel, dcdCnRadius / mmPerPixel];
        end
        if exportMd
            mdparam = [mmPerPixel];
        end

        % save data as text
        for i=1:roiNum
            if isfield(handles, 'export') && ~isempty(handles.export)
                outputDataPath = [handles.export '/'];
                dataFileName = [outputDataPath shuttleVideo.name];
            else
                outputDataPath = [confPath 'output/' filename '_roi' num2str(i) '_data/'];
                dataFileName = [outputDataPath shuttleVideo.name '_' filename];
            end

            % output text data
            if isempty(roiMasks)
                roiMask = [];
            else
                roiMask = roiMasks{i};
            end
            saveTrackingResultText(dataFileName, keep_data, end_row, flyNum, img_h, img_w, roiMask, dcdparam, mdparam);

            % save input data used for generating this result
            record = {records{data_th,:}};
            T = cell2table(record);
            T.Properties.VariableNames = getVideoConfigHeader();
            writetable(T, [dataFileName '_config.csv']);
        end
    end

    % show tracking result
    if ~isfield(handles, 'showcount') || handles.showcount
        dlg = trackingResultDialog({num2str(data_th)});
    end
    pause(3); % pause 3 sec
end

% show end text
time = toc;
disp(['tracking ... done!     t =',num2str(time),'s']);
set(handles.text14, 'String',strcat('tracking ... done!     t =',num2str(time),'s'))
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);


%%
function enableAllButtons(handles)
buttons = [handles.pushbutton1, handles.pushbutton2, handles.pushbutton3, handles.pushbutton4, ...
    handles.pushbutton5, handles.pushbutton6, handles.pushbutton8, handles.pushbutton10, ...
    handles.pushbutton11, handles.pushbutton12];
enableButtons(buttons);

%%
function enableButtons(buttons)
max = size(buttons, 2);
for i = 1 : max
    set(buttons(i), 'Enable', 'on');
end

%%
function disableAllButtons(handles)
buttons = [handles.pushbutton1, handles.pushbutton2, handles.pushbutton3, handles.pushbutton4, ...
    handles.pushbutton5, handles.pushbutton6, handles.pushbutton8, handles.pushbutton10, ...
    handles.pushbutton11, handles.pushbutton12];
disableButtons(buttons);

%%
function disableButtons(buttons)
max = size(buttons, 2);
for i = 1 : max
    set(buttons(i), 'Enable', 'off');
end

%%
function checkAllButtons(handles)
% first disable all buttons
disableAllButtons(handles)

% button1 is always on
set(handles.pushbutton1, 'Enable', 'on');

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    return;
end

confFileName = [videoPaths{1} videoFiles{1} '_tpro/input_video_control.csv'];
if ~exist(confFileName, 'file')
    return; % no config file
end
confTable = readtable(confFileName);
record = table2cell(confTable);
start_frame = record{4};
end_frame = record{5};

% background button
set(handles.pushbutton2, 'Enable', 'on');

confPath = [videoPaths{1} videoFiles{1} '_tpro/'];
backgroundFileName = [confPath 'background.png'];
if ~exist(backgroundFileName, 'file')
    return; % no background image file
end

% roi button
set(handles.pushbutton6, 'Enable', 'on');

roiFileName = [confPath 'roi.png'];
csvFileName = [confPath 'roi.csv'];
if ~exist(roiFileName, 'file') && ~exist(csvFileName, 'file')
    return; % no roi image file
end

% threshold check button
set(handles.pushbutton3, 'Enable', 'on');
% detect button
set(handles.pushbutton4, 'Enable', 'on');
% detect + track button
set(handles.pushbutton8, 'Enable', 'on');

filename = [sprintf('%05d',start_frame) '_' sprintf('%05d',end_frame)];
keepFileName = [confPath 'multi/detect_' filename 'keep_count.mat'];
if ~exist(keepFileName, 'file')
    return; % no keep count file
end

% track button
set(handles.pushbutton5, 'Enable', 'on');
% show detection result button
set(handles.pushbutton12, 'Enable', 'on');

trackFileName = [confPath 'multi/track_' filename '.mat'];
if ~exist(trackFileName, 'file')
    return; % no tracking file
end

% show tracking result button
set(handles.pushbutton10, 'Enable', 'on');
% show annotation button
set(handles.pushbutton11, 'Enable', 'on');



% --- Executes on button press in ROI.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    errordlg('please select movies before operation.', 'Error');
    return;
end

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    C = checkConfigCompatibility(C);
    records = [records; C];
end

% show start text
set(handles.text14, 'String','selecting "Region of Interest" ...')
set(handles.text9, 'String','Running','BackgroundColor','red');
disableAllButtons(handles);
pause(0.01);

uniquePaths = unique(videoPaths);
for i=1:length(uniquePaths)
    addpath(uniquePaths{i});
end

% select roi for every movie
data_th = 1;
while data_th <= size(records,1)
    if records{data_th, 1}
        videoPath = videoPaths{data_th};
        shuttleVideo = TProVideoReader(videoPath, records{data_th,2}, records{data_th,6}, records{data_th,7});

        % load background image
        bgImageFile = [videoPath shuttleVideo.name '_tpro/background.png'];
        if exist(bgImageFile, 'file')
            frameImage = imread(bgImageFile);
        else
            frameImage = TProRead(shuttleVideo,1);
        end
        if size(frameImage,3) == 1
            grayImage = frameImage;
        else
            grayImage = rgb2gray(frameImage);
        end

        % show selectRoiWayDialog
        roiFileName = [videoPath shuttleVideo.name '_tpro/roi.png'];
        csvFileName = [videoPath shuttleVideo.name '_tpro/roi.csv'];
        if exist(csvFileName, 'file')
            selectedType = 2;
        elseif exist(roiFileName, 'file')
            selectedType = 1;
        else
            [dlg, selectedType] = selectRoiWayDialog({});
            delete(dlg);

            if selectedType < 0
                data_th = data_th + 1;
                continue;
            end
        end

        % select fixed ROI image files or create new ROI images
        if selectedType == 2
            [i, figureWindow] = selectRoiFiles(csvFileName, shuttleVideo, grayImage);
            figureWindow = [];
            if i<0 continue; end
        else
            [i, figureWindow] = createRoiImages(videoPath, shuttleVideo, frameImage, grayImage, records{data_th, 10});
        end
        clear frameImage;

        % update ROI param in configuration
        record = {records{data_th,:}};
        record{10} = i;
        confFileName = [videoPath videoFiles{data_th} '_tpro/input_video_control.csv'];
        status = saveInputControlFile(confFileName, record);
        if ~status
            errordlg(['failed to save a configuration file : ' confFileName], 'Error');
        end
    end
    data_th = data_th + 1;
end

% close background image window
if exist('figureWindow','var') && ~isempty(figureWindow) && ishandle(figureWindow)
    pause(2);
    close(figureWindow);
end

% show end text
set(handles.text14, 'String','selecting "Region of Interest" ... done!')
set(handles.text9, 'String','Ready','BackgroundColor','green');
checkAllButtons(handles);



% --- Detect + Track
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pushbutton4_Callback(hObject, eventdata, handles)
pushbutton5_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    errordlg('please select movies before operation.', 'Error');
    return;
end

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    C = checkConfigCompatibility(C);
    records = [records; C];
end

% loop for every movies
for i = 1 : size(records,1)
    % show tracking result
    dlg = trackingResultDialog({num2str(i)});
    pause(0.1);
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    errordlg('please select movies before operation.', 'Error');
    return;
end

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    C = checkConfigCompatibility(C);
    records = [records; C];
end

% loop for every movies
for i = 1 : size(records,1)
    % show tracking result
    dlg = annotationDialog({num2str(i)});
    pause(0.1);
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[videoPaths, videoFiles, tebleItems] = getInputList();
if isempty(videoPaths)
    errordlg('please select movies before operation.', 'Error');
    return;
end

% load configuration files
videoFileNum = size(videoFiles,1);
records = {};
for i = 1:videoFileNum
    confFileName = [videoPaths{i} videoFiles{i} '_tpro/input_video_control.csv'];
    if ~exist(confFileName, 'file')
        errordlg(['configuration file not found : ' confFileName], 'Error');
        return;
    end

    confTable = readtable(confFileName);
    C = table2cell(confTable);
    C = checkConfigCompatibility(C);
    records = [records; C];
end

% loop for every movies
for i = 1 : size(records,1)
    % show tracking result
    dlg = detectionResultDialog({num2str(i)});
    pause(0.1);
end
