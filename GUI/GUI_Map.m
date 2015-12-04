function varargout = GUI_Map(varargin)
% GUI_MAP MATLAB code for GUI_Map.fig
%      GUI_MAP, by itself, creates a new GUI_MAP or raises the existing
%      singleton*.
%
%      H = GUI_MAP returns the handle to a new GUI_MAP or the handle to
%      the existing singleton*.
%
%      GUI_MAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MAP.M with the given input arguments.
%
%      GUI_MAP('Property','Value',...) creates a new GUI_MAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Map_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Map_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Map

% Last Modified by GUIDE v2.5 03-Dec-2015 17:34:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Map_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Map_OutputFcn, ...
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


% --- Executes just before GUI_Map is made visible.
function GUI_Map_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Map (see VARARGIN)

% Choose default command line output for GUI_Map
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(0, 'hGUI_Map', gcf);

hGUI_Map = getappdata(0, 'hGUI_Map');
hGUI_aBMD = getappdata(0, 'hGUI_aBMD');

setappdata(hGUI_Map, 'data', getappdata(hGUI_aBMD, 'data'));

% UIWAIT makes GUI_Map wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Map_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Value = get(hObject, 'Value');

hGUI_Map = getappdata(0, 'hGUI_Map');

computed_maps = getappdata(hGUI_Map, 'computed_maps');
density_maps = getappdata(hGUI_Map, 'density_maps');
limits = getappdata(hGUI_Map, 'limits');

if computed_maps(Value+1) == 1
    plot_density_map(density_maps{Value+1}, limits);
else
    se = strel('disk', 8);
    
    data = getappdata(hGUI_Map, 'data');
    radius = getappdata(hGUI_Map, 'radius');
    depth = getappdata(hGUI_Map, 'depth');
    bone_surf_map = getappdata(hGUI_Map, 'bone_surf_map');
    rowInd = getappdata(hGUI_Map, 'rowInd');
    colInd = getappdata(hGUI_Map, 'colInd');

    
    depth_mask = get_depth_mask(bone_surf_map, data.masque_t, Value * depth, rowInd, colInd);
    
    depth_mask = imerode(depth_mask, se);
    imshow(mat2gray(depth_mask));
    
    [depth_rowInd, depth_colInd] = ind2sub(size(bone_surf_map), find(depth_mask>0));
    density_maps{Value+1} = get_density_map(bone_surf_map - Value * depth, depth_mask, data.ProcessedData.DicomCube, depth_rowInd, depth_colInd, depth, radius);
    plot_density_map(density_maps{Value+1}, limits);
    setappdata(hGUI_Map, 'density_maps', density_maps);
end
    
    



% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'Visible', 'off');

hGUI_Map = getappdata(0, 'hGUI_Map');
data = getappdata(hGUI_Map, 'data');

% [nrow, ncol, nslab] = size(data.ProcessedData.DicomCube);

%% Compute bone map

% imshow(mat2gray(squeeze(data.ProcessedData.DicomCube(:,:,round(.5*nslab)))));
region = getappdata(hGUI_Map, 'region');
[bone_surf_map, rowInd, colInd, mat, limits] = get_aBMD( data, region );

radius = 3;
depth = 10;
n_depth = floor(min(bone_surf_map(:)-1)./depth);

setappdata(hGUI_Map, 'bone_surf_map', bone_surf_map);
setappdata(hGUI_Map, 'mat', mat);
setappdata(hGUI_Map, 'limits', limits);
setappdata(hGUI_Map, 'rowInd', rowInd);
setappdata(hGUI_Map, 'colInd', colInd);
setappdata(hGUI_Map, 'radius', radius);
setappdata(hGUI_Map, 'depth', depth);

set(handles.slider1, 'Value', 0);
set(handles.slider1, 'Min', 0);
set(handles.slider1, 'Max', n_depth);
set(handles.slider1, 'SliderStep', [1/n_depth 1]);

computed_maps = zeros(n_depth+1,1);
density_maps = cell(n_depth+1,1);

% temp = get_density_map(bone_surf_map, mat, data.ProcessedData.DicomCube, rowInd, colInd, depth, radius); 

density_maps{1} = get_density_map(bone_surf_map, mat, data.ProcessedData.DicomCube, rowInd, colInd, depth, radius); 
computed_maps(1) = 1;
% imshow(mat2gray(density_maps{1}));
plot_density_map(density_maps{1}, limits);

setappdata(hGUI_Map, 'computed_maps', computed_maps);
setappdata(hGUI_Map, 'density_maps', density_maps);


set(handles.slider1, 'Visible', 'on');
set(handles.axes1, 'Visible', 'on');
