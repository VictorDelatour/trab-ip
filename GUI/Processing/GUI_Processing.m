function varargout = GUI_Processing(varargin)
% GUI_PROCESSING MATLAB code for GUI_Processing.fig
%      GUI_PROCESSING, by itself, creates a new GUI_PROCESSING or raises the existing
%      singleton*.
%
%      H = GUI_PROCESSING returns the handle to a new GUI_PROCESSING or the handle to
%      the existing singleton*.
%
%      GUI_PROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PROCESSING.M with the given input arguments.
%
%      GUI_PROCESSING('Property','Value',...) creates a new GUI_PROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Processing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Processing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Processing

% Last Modified by GUIDE v2.5 21-Dec-2015 16:10:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Processing_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Processing_OutputFcn, ...
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


% --- Executes just before GUI_Processing is made visible.
function GUI_Processing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Processing (see VARARGIN)

% Choose default command line output for GUI_Processing
handles.output = hObject;

current_folder = pwd;

setappdata(0, 'hStat', gcf);
hStat = getappdata(0, 'hStat');

folder = getappdata(0, 'folder'); % Check if folder is stored
folder = uigetdir(folder,'Folder selection'); % Suggest stored folder as root

if folder ~= 0 
    cd(folder);
    
    setappdata(0, 'folder', folder);
    
    %% Get all meshData and scanData files
    
    mesh_files = dir('*meshData.mat'); 
    [mesh_files,~] = sortrows({mesh_files.name}');
    scan_files = dir('*scanData.mat');
    [scan_files,~] = sortrows({scan_files.name}');
    
    % The 7 first chars of all files are the code
    mesh_codes = cell(size(mesh_files));
    scan_codes = cell(size(scan_files));
    
    for file = 1:numel(mesh_files)
        mesh_codes{file} = mesh_files{file}(1:7);
    end
    
    for file = 1:numel(scan_files)
        scan_codes{file} = scan_files{file}(1:7);
    end
    
    %% Pick only files with both scanData and meshData
    [codes, indMesh, indScan] = intersect(mesh_codes, scan_codes);
    
    mesh_files = mesh_files(indMesh);
    scan_files = scan_files(indScan);
    
    %% Keep in memory the folder link
    if isunix
        sbar = '/';
    else
        sbar = '\';
    end
    
    setappdata(0, 'sbar', sbar);
    
    %% Store filenames and codes
    files = struct;
    files.mesh = strcat(folder, sbar, mesh_files);
    files.scan = strcat(folder, sbar, scan_files);
    files.code = codes;
    
    setappdata(hStat, 'files', files);
    
    %% Read average density data
    
    av_file = 'average_density_data.mat';
    
    if exist(av_file, 'file') == 2
        load(av_file);
        pos = struct;
        pos.x = data.nonOA.medial.mean_x;
        pos.y = data.nonOA.medial.mean_y;
        setappdata(hStat, 'pos', pos);
    else
        fprintf('File not found\n');
    end
    
    cd(current_folder);
    
    index = 1;
    setappdata(hStat, 'index', index);
    
    %% Get size of density map
    meshData = load(files.mesh{index});
    meshData = meshData.meshData.tibia;
    
    density_map = meshData.subBoneDensityMap;

    dm_colsum = sum(density_map, 1, 'omitnan')>0;
    dm_min = find(dm_colsum, 1);
    dm_max = find(dm_colsum(1:round(.5*size(density_map,2))), 1, 'last');
    dm_rows = [dm_min, dm_max];

    dm_rowsum = sum(density_map, 2, 'omitnan')>0;
    dm_min = find(dm_rowsum, 1);
    dm_max = find(dm_rowsum, 1, 'last');
    dm_cols = [dm_min, dm_max];

%     density_map = density_map(dm_cols(1):dm_cols(2),dm_rows(1):dm_rows(2));
    density_size = [diff(dm_cols) + 1, diff(dm_rows) + 1];
    setappdata(hStat, 'density_size', density_size);
    
    %%
    
    stored_data = struct;
    stored_data.images = cell(numel(codes),1);
    stored_data.masks = cell(numel(codes),1);
    stored_data.limits = cell(numel(codes),1);
    stored_data.rois = cell(numel(codes),1);
    stored_data.computed = false(numel(codes),1);
    
    setappdata(hStat, 'stored_data', stored_data);
    

    
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_Processing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Processing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Previous button
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hStat = getappdata(0, 'hStat');
files = getappdata(hStat, 'files');
index = getappdata(hStat, 'index');

if index == numel(files.code)
    set(handles.pushbutton2,'Enable', 'on');
end

index = index-1

setappdata(hStat, 'index', index);

pushbutton5_Callback(handles.pushbutton5, eventdata, handles)

if index == 1
    set(hObject,'Enable', 'off');
end



% Next button
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hStat = getappdata(0, 'hStat');
files = getappdata(hStat, 'files');
index = getappdata(hStat, 'index');

if index == 1
    set(handles.pushbutton1,'Enable', 'on');
end

index = index+1

setappdata(hStat, 'index', index);

pushbutton5_Callback(handles.pushbutton5, eventdata, handles)

%%

if index == numel(files.code)
    set(hObject,'Enable', 'off');
end

% Statistics button
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hStat = getappdata(0, 'hStat');

% Load button
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Load everything needed
hStat = getappdata(0, 'hStat');
index = getappdata(hStat, 'index');
stored_data = getappdata(hStat, 'stored_data');

if stored_data.computed(index)
    
    image = stored_data.images{index};
    mask = stored_data.masks{index};
    limits = stored_data.limits{index};
    roi = stored_data.rois{index};
    
else
    
    files = getappdata(hStat, 'files');
    pos = getappdata(hStat, 'pos');
    density_size = getappdata(hStat, 'density_size');
    
    [ image, mask, roi, limits ] = load_data( files, pos, density_size, index );
    
    %% Store all data and say that it has been computed
    
    stored_data.images{index} = image;
    stored_data.masks{index} = mask;
    stored_data.limits{index} = limits;
    stored_data.rois{index} = roi;
    stored_data.computed(index) = true;
    
    setappdata(hStat, 'stored_data', stored_data);
   
end

%% Show image

plot_image_with_limits( handles.axes1, image, mask, limits )

% Set lower plot in GUI as current axes
axes(handles.axes2);
imshow(roi);




