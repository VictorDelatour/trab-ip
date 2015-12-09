function varargout = GUI_MaxDensity(varargin)
%GUI_MAXDENSITY M-file for GUI_MaxDensity.fig
%      GUI_MAXDENSITY, by itself, creates a new GUI_MAXDENSITY or raises the existing
%      singleton*.
%
%      H = GUI_MAXDENSITY returns the handle to a new GUI_MAXDENSITY or the handle to
%      the existing singleton*.
%
%      GUI_MAXDENSITY('Property','Value',...) creates a new GUI_MAXDENSITY using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to GUI_MaxDensity_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUI_MAXDENSITY('CALLBACK') and GUI_MAXDENSITY('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUI_MAXDENSITY.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_MaxDensity

% Last Modified by GUIDE v2.5 08-Dec-2015 15:59:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_MaxDensity_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_MaxDensity_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before GUI_MaxDensity is made visible.
function GUI_MaxDensity_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for GUI_MaxDensity
handles.output = hObject;

current_folder = pwd;

setappdata(0, 'hMax', gcf);
hMax = getappdata(0, 'hMax');

folder = getappdata(0, 'folder');
folder = uigetdir(folder,'Folder selection');

if folder ~= 0
    cd(folder);
    
    file_names = dir('*.mat');
    [file_names, ~] = sortrows({file_names.name}');
    full_file_names = strcat(folder, '/', file_names)
    
    cd(current_folder);
    
    setappdata(hObject, 'file_names', file_names);
    setappdata(hObject, 'index', 1);
    setappdata(hObject, 'full_file_names', full_file_names);
    setappdata(0, 'folder', folder);
    image_list = cell(numel(file_names),1);
    loaded_images = false(size(image_list));
    
    setappdata(hMax, 'image_list', image_list);
    setappdata(hMax, 'loaded_images', loaded_images);
    
    set(handles.pushbutton1, 'Enable', 'off');
    if numel(file_names) <= 1
        set(handles.pushbutton2, 'Enable', 'off');
    end
        
    loaded_image = load_image(hMax, 1);
    contourf(flipud(loaded_image));
    colormap(jet(256));
    set(handles.axes1,'DataAspectRatio',[1 1 1]);
    set(handles.axes1,'YTick',[]);
    set(handles.axes1,'XTick',[]);
    
    setappdata(handles.axes1, 'size', size(loaded_image));
        
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_MaxDensity wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_MaxDensity_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');
% file_names = getappdata(hMax, 'file_names');
index = getappdata(hMax, 'index');

file_names = getappdata(hMax, 'file_names');

if index == numel(file_names)
    set(handles.pushbutton2, 'Enable', 'on');
end

index = index-1;

% Update image
image = load_image(hMax, index);
imshow(image);
contour(image, 8);

% Update image

setappdata(hMax, 'index', index);

if index == 1
    set(handles.pushbutton1, 'Enable', 'off');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');
index = getappdata(hMax, 'index');
file_names = getappdata(hMax, 'file_names');

if index == 1
    set(handles.pushbutton1, 'Enable', 'on');
end

index = index+1;

% Update image
image = load_image(hMax, index);
setappdata(handles.axes1, 'size', size(image));

imshow(image);
contour(image, 8);

setappdata(hMax, 'index', index);

if index == numel(file_names)
    set(handles.pushbutton2, 'Enable', 'off');
end


% --- Executes on button press in pushbutton3.
% --- Button for lateral density
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');
sz = getappdata(handles.axes1, 'size');

mid_row = round(.5*sz(1));
index = getappdata(hMax, 'index');
image_list = getappdata(hMax, 'image_list');
current_image = flipud(image_list{index});

contourf(current_image(mid_row:end,:)); colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);



% --- Executes on button press in pushbutton4.
% --- Button for medial density
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');

sz = getappdata(handles.axes1, 'size');

mid_row = round(.5*sz(1));
index = getappdata(hMax, 'index');
image_list = getappdata(hMax, 'image_list');
current_image = flipud(image_list{index});

contourf(current_image(1:mid_row,:)); colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');

index = getappdata(hMax, 'index');
image_list = getappdata(hMax, 'image_list');
current_image = flipud(image_list{index});

contourf(current_image); colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);


