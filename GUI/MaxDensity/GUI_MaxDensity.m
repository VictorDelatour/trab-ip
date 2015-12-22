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

% Last Modified by GUIDE v2.5 16-Dec-2015 16:30:27

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
    full_file_names = strcat(folder, '/', file_names);
    
    cd(current_folder);
    

    
    image_list = cell(numel(file_names),1);
    loaded_images = false(size(image_list));
    
    setappdata(hMax, 'image_list', image_list);
    setappdata(hMax, 'loaded_images', loaded_images);
    setappdata(hMax, 'loaded_OA', false)
    setappdata(hObject, 'file_names', file_names);
    setappdata(hObject, 'index', 1);
    setappdata(hObject, 'full_file_names', full_file_names);
    
    
    set(handles.pushbutton1, 'Enable', 'off');
    if numel(file_names) <= 1
        set(handles.pushbutton2, 'Enable', 'off');
    end
        
    loaded_image = load_image(hMax, 1);
    contourf(loaded_image{1});
    colormap(jet(256));
    set(handles.axes1,'DataAspectRatio',[1 1 1]);
    set(handles.axes1,'YTick',[]);
    set(handles.axes1,'XTick',[]);
    
    
    
    lateral = struct('loaded', false(numel(file_names),1), 'x', zeros(numel(file_names),1), 'y', zeros(numel(file_names),1));
    medial = lateral;
    max_density = struct('lateral', lateral, 'medial', medial);
    max_thickness = struct('lateral', lateral, 'medial', medial);
    max_data = cell(2,1);
    max_data{1} = max_density;
    max_data{2} = max_thickness;
    
    setappdata(0, 'folder', folder);
    
    setappdata(hMax, 'map_index', 1);
%     setappdata(hMax, 'max_density', max_density);
    setappdata(hMax, 'max_data', max_data);
  
    setappdata(handles.axes1, 'size', size(loaded_image{1}));
    
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
index = getappdata(hMax, 'index');

file_names = getappdata(hMax, 'file_names');

if index == numel(file_names)
    set(handles.pushbutton2, 'Enable', 'on');
end

index = index-1;

%% Plot new image

image = load_image(hMax, index);

map_index = getappdata(hMax, 'map_index');

contourf(image{map_index}); 
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);

%% Plot maximal density

max_data = getappdata(hMax, 'max_data');
map_index = getappdata(hMax, 'map_index');
max_data = max_data{map_index};

% max_density = getappdata(hMax, 'max_density');


if max_data.lateral.loaded(index)
    x = max_data.lateral.x(index);
    y = max_data.lateral.y(index);
    
    sz = getappdata(handles.axes1, 'size');
    mid_row = round(.5*sz(1));
    
    hold on
    plot(x, y + mid_row, '+k', 'MarkerSize',10);
    text(x + 2, y + mid_row, 'Lateral', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end

if max_data.medial.loaded(index)
    x = max_data.medial.x(index);
    y = max_data.medial.y(index);
    
    hold on
    plot(x, y, '+k', 'MarkerSize',20);
    text(x + 2, y, 'Medial', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end

%% Update data

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

%% Plot image
image = load_image(hMax, index);

map_index = getappdata(hMax, 'map_index');

% setappdata(handles.axes1, 'size', size(image{map_index}));

contourf(image{map_index}); 
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);

%% Plot max data
% max_density = getappdata(hMax, 'max_density');
max_data = getappdata(hMax, 'max_data');
map_index = getappdata(hMax, 'map_index');
max_data = max_data{map_index};

if max_data.lateral.loaded(index)
    x = max_data.lateral.x(index);
    y = max_data.lateral.y(index);
    
    sz = getappdata(handles.axes1, 'size');
    mid_row = round(.5*sz(1));
    
    hold on
    plot(x, y + mid_row, '+k', 'MarkerSize',10);
    text(x + 2, y + mid_row, 'Lateral', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end

if max_data.medial.loaded(index)
    x = max_data.medial.x(index);
    y = max_data.medial.y(index);
    
    hold on
    plot(x, y, '+k', 'MarkerSize',20);
    text(x + 2, y, 'Medial', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end

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

max_data = getappdata(hMax, 'max_data');
map_index = getappdata(hMax, 'map_index');
loc_max_data = max_data{map_index};
index = getappdata(hMax, 'index');

if loc_max_data.lateral.loaded(index)
    sNew = 'Select new max';
    sOld = 'Keep old max';

    choice = questdlg('Existing maximum', ... % Question
        'Maximum', ... % Window name
        sNew, sOld,... % Choices
        sOld); % Defaut answer

    if strcmp(choice, sOld)
        return
    end
end

sz = getappdata(handles.axes1, 'size');

mid_row = round(.5*sz(1));
index = getappdata(hMax, 'index');
image_list = getappdata(hMax, 'image_list');
current_image = image_list{index};
current_image = current_image{map_index};
current_image = current_image(mid_row:end,:);

[nrow, ncol] = size(current_image);


[~,h] = contourf(current_image); 
colormap(jet(256));

set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);
col = 0; row = 0; thresh = NaN;

while (col < 1 || col > ncol) || (row < 1 || row > nrow) || isnan(thresh);
    [col, row] = ginput(1);
    thresh = current_image(round(row), round(col));
end


if thresh > max(h.LevelList)
    thresh = max(h.LevelList);
else
    thresh = h.LevelList(max(find(h.LevelList>thresh,1)-1,1));
end

current_image(isnan(current_image) | current_image < thresh) = 0;
current_image(current_image >= thresh) = 1;

CC = bwconncomp(current_image);

max_ind = round(row) + (round(col)-1)*nrow;

if numel(CC.PixelIdxList) > 1
    for list = 1:numel(CC.PixelIdxList)
        if ismember(max_ind, CC.PixelIdxList{list})
            break
        end
    end
    
    to_erase = [1:(list-1), (list+1):numel(CC.PixelIdxList)];
    for i = 1:numel(to_erase)
        current_image(CC.PixelIdxList{to_erase(i)}) = 0;
    end
 
end


nzInd = find(current_image>0);
[nzRows, nzCols] = ind2sub(size(current_image), nzInd);

row = sum(nzRows.*current_image(nzInd))/sum(current_image(nzInd));
col = sum(nzCols.*current_image(nzInd))/sum(current_image(nzInd));

current_image = image_list{index};
current_image = current_image{map_index};
current_image = current_image(mid_row:end,:);

contourf(current_image); 
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);
hold on
plot(col, row, 'k+', 'MarkerSize',20);
hold off

loc_max_data.lateral.loaded(index) = true;
loc_max_data.lateral.x(index) = col;
loc_max_data.lateral.y(index) = row;

max_data{map_index} = loc_max_data;

setappdata(hMax, 'max_data', max_data);

% --- Executes on button press in pushbutton4.
% --- Button for medial density
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');

max_data = getappdata(hMax, 'max_data');
map_index = getappdata(hMax, 'map_index');
loc_max_data = max_data{map_index};
index = getappdata(hMax, 'index');

if loc_max_data.medial.loaded(index)
    sNew = 'Select new max';
    sOld = 'Keep old max';

    choice = questdlg('Existing maximum', ... % Question
        'Maximum', ... % Window name
        sNew, sOld,... % Choices
        sOld); % Defaut answer

    if strcmp(choice, sOld)
        return
    end
end

sz = getappdata(handles.axes1, 'size');

mid_row = round(.5*sz(1));
index = getappdata(hMax, 'index');
image_list = getappdata(hMax, 'image_list');
current_image = image_list{index};
current_image = current_image{map_index};
current_image = current_image(1:mid_row,:);

[nrow, ncol] = size(current_image);


[~,h] = contourf(current_image); 
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);

col = 0; row = 0; thresh = NaN;

while (col < 1 || col > ncol) || (row < 1 || row > nrow) || isnan(thresh);
    [col, row] = ginput(1);
    thresh = current_image(round(row), round(col));
end


if thresh > max(h.LevelList)
    thresh = max(h.LevelList);
else
    thresh = h.LevelList(max(find(h.LevelList>thresh,1)-1,1));
end

current_image(isnan(current_image) | current_image < thresh) = 0;
current_image(current_image >= thresh) = 1;

CC = bwconncomp(current_image);

max_ind = round(row) + (round(col)-1)*nrow;

if numel(CC.PixelIdxList) > 1
    for list = 1:numel(CC.PixelIdxList)
        if ismember(max_ind, CC.PixelIdxList{list})
            break
        end
    end
    
    to_erase = [1:(list-1), (list+1):numel(CC.PixelIdxList)];
    for i = 1:numel(to_erase)
        current_image(CC.PixelIdxList{to_erase(i)}) = 0;
    end
 
end

nzInd = find(current_image>0);
[nzRows, nzCols] = ind2sub(size(current_image), nzInd);

row = sum(nzRows.*current_image(nzInd))/sum(current_image(nzInd));
col = sum(nzCols.*current_image(nzInd))/sum(current_image(nzInd));

current_image = image_list{index};
current_image = current_image{map_index};
current_image = current_image(1:mid_row,:);

contourf(current_image); 
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);
hold on
plot(col, row, 'k+', 'MarkerSize',20);
hold off

loc_max_data.medial.loaded(index) = true;
loc_max_data.medial.x(index) = col;
loc_max_data.medial.y(index) = row;

max_data{map_index} = loc_max_data;

setappdata(hMax, 'max_data', max_data);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');

index = getappdata(hMax, 'index');
image_list = getappdata(hMax, 'image_list');
map_index = getappdata(hMax, 'map_index');
current_image = image_list{index};
current_image = current_image{map_index};

contourf(current_image); 
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);

max_data = getappdata(hMax, 'max_data');
max_data = max_data{map_index};

if max_data.lateral.loaded(index)
    x = max_data.lateral.x(index);
    y = max_data.lateral.y(index);
    
    sz = getappdata(handles.axes1, 'size');
    mid_row = round(.5*sz(1));
    
    hold on
    plot(x, y + mid_row, '+k', 'MarkerSize',10);
    text(x + 2, y + mid_row, 'Lateral', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end

if max_data.medial.loaded(index)
    x = max_data.medial.x(index);
    y = max_data.medial.y(index);
    
    hold on
    plot(x, y, '+k', 'MarkerSize',20);
    text(x + 2, y, 'Medial', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end


% --- Executes on button press in pushbutton6.
% --- Average Medial Density
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');
image_list = getappdata(hMax, 'image_list');

max_density = getappdata(hMax, 'max_density');

medial_ind = find(max_density.medial.loaded);


medial_image = zeros(size(image_list{1}));


medial_pos = struct;
medial_pos.x = 0;
medial_pos.y = 0;


for i = 1:numel(medial_ind)
    medial_image = medial_image + image_list{medial_ind(i)};
end

medial_image = medial_image ./ numel(medial_ind);

medial_pos.x = mean(max_density.medial.x(medial_ind));
medial_pos.y = mean(max_density.medial.y(medial_ind));

x_std = std(max_density.medial.x(medial_ind));
y_std = std(max_density.medial.y(medial_ind));

contourf(medial_image);
colormap(jet(256))
hold on
plot(medial_pos.x, medial_pos.y, '+k');
plot(medial_pos.x + x_std* [-1, 1], medial_pos.y * [1, 1], '-k')
plot(medial_pos.x * [1, 1], medial_pos.y + y_std * [-1, 1], '-k')
text(medial_pos.x + x_std + 2, medial_pos.y, 'Medial', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
hold off
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);



% --- Executes on button press in pushbutton7.
% --- Average Lateral Density
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');
image_list = getappdata(hMax, 'image_list');

%% Load or compute OA vector
if isappdata(hMax, 'OA')
    OA = getappdata(hMax, 'OA');
else
    file_names = getappdata(hMax, 'file_names');
    
    [filename, pathname] = uigetfile({'*.xls;*.xlsx', 'Excel File'}, 'Select OA file'); % Get reference file
    [num, txt, ~] = xlsread(strcat(pathname, filename)); % File should have two cols: 1.) Code (7 chars) 2.) OA (1/0)
    
    OA = false(numel(file_names,1));
    
    for file = 1:numel(file_names)
        code = file_names{file}(1:7);
        OA(file) = logical(num(strcmp(code, txt(2:end,1))));
    end
    
    setappdata(hMax, 'OA', OA);
end

%% Which images to use?
map_index = getappdata(hMax, 'map_index');
max_data = getappdata(hMax, 'max_data');
max_data = max_data{map_index};

medial_ind = find(max_data.medial.loaded);
lateral_ind = find(max_data.lateral.loaded);

if max(numel(medial_ind), numel(lateral_ind)) < 1
    fprintf('No data stored\n');
    return
else
    ind = intersect(medial_ind, lateral_ind);
    if (numel(ind) ~= numel(medial_ind)) || (numel(ind) ~= numel(lateral_ind))
        warning('Missing medial or lateral data');
    end
end

indOA = ind(OA(ind));
indHealthy = ind(~OA(ind));

dataOA = struct;
dataHealthy = struct;


%% Average image
image = zeros(size(image_list{1}{map_index}));

for i = 1:numel(lateral_ind)
    image = image + image_list{ind(i)}{map_index};
end

image = image ./ numel(lateral_ind);

%% OA

dataOA.lateral.mean_x = mean(max_data.lateral.x(indOA));
dataOA.lateral.mean_y = mean(max_data.lateral.y(indOA));
dataOA.lateral.std_x = std(max_data.lateral.x(indOA));
dataOA.lateral.std_y = std(max_data.lateral.y(indOA));

dataOA.medial.mean_x = mean(max_data.medial.x(indOA));
dataOA.medial.mean_y = mean(max_data.medial.y(indOA));
dataOA.medial.std_x = std(max_data.medial.x(indOA));
dataOA.medial.std_y = std(max_data.medial.y(indOA));

dataOA.image = zeros(size(image_list{1}{map_index}));
for i = 1:numel(indOA)
    dataOA.image = dataOA.image + image_list{indOA(i)}{map_index};
end

dataOA.image = dataOA.image./numel(indOA);

sz = size(dataOA.image);
mid_row = round(.5*sz(1));

contourf(dataOA.image);
colormap(jet(256))
hold on
% OA and Lateral
loc_dat = dataOA.lateral;
plot(loc_dat.mean_x, mid_row + loc_dat.mean_y, '+k');
plot(loc_dat.mean_x + loc_dat.std_x * [-1, 1], mid_row + loc_dat.mean_y * [1, 1], '-k')
text(loc_dat.mean_x + loc_dat.std_x + 2, mid_row + loc_dat.mean_y, 'OA', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');

% OA and Medial
loc_dat = dataOA.medial;
plot(loc_dat.mean_x, loc_dat.mean_y, '+k');
plot(loc_dat.mean_x + loc_dat.std_x * [-1, 1], loc_dat.mean_y * [1, 1], '-k')
text(loc_dat.mean_x + loc_dat.std_x + 2, loc_dat.mean_y, 'OA', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
hold off
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);
waitforbuttonpress;


%% nonOA

dataHealthy.lateral.mean_x = mean(max_data.lateral.x(indHealthy));
dataHealthy.lateral.mean_y = mean(max_data.lateral.y(indHealthy));
dataHealthy.lateral.std_x = std(max_data.lateral.x(indHealthy));
dataHealthy.lateral.std_y = std(max_data.lateral.y(indHealthy));

dataHealthy.medial.mean_x = mean(max_data.medial.x(indHealthy));
dataHealthy.medial.mean_y = mean(max_data.medial.y(indHealthy));
dataHealthy.medial.std_x = std(max_data.medial.x(indHealthy));
dataHealthy.medial.std_y = std(max_data.medial.y(indHealthy));

dataHealthy.image = zeros(size(image_list{1}{map_index}));
for i = 1:numel(indHealthy)
    dataHealthy.image = dataHealthy.image + image_list{indHealthy(i)}{map_index};
end

dataHealthy.image = dataHealthy.image./numel(indHealthy);

sz = size(dataHealthy.image);
mid_row = round(.5*sz(1));

contourf(dataHealthy.image, 20);
colormap(jet(256))
hold on
% OA and Lateral
loc_dat = dataHealthy.lateral;
plot(loc_dat.mean_x, mid_row + loc_dat.mean_y, '+k');
plot(loc_dat.mean_x + loc_dat.std_x * [-1, 1], mid_row + loc_dat.mean_y * [1, 1], '-k')
text(loc_dat.mean_x + loc_dat.std_x + 2, mid_row + loc_dat.mean_y, 'nonOA', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');

% OA and Medial
loc_dat = dataHealthy.medial;
plot(loc_dat.mean_x, loc_dat.mean_y, '+k');
plot(loc_dat.mean_x + loc_dat.std_x * [-1, 1], loc_dat.mean_y * [1, 1], '-k')
text(loc_dat.mean_x + loc_dat.std_x + 2, loc_dat.mean_y, 'nonOA', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
hold off
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);
waitforbuttonpress;

%%
sz = getappdata(handles.axes1, 'size');
mid_row = round(.5*sz(1));

contourf(image);
colormap(jet(256))
hold on
if numel(indHealthy) > 0
    % Healthy and Lateral
    loc_dat = dataHealthy.lateral;
    plot(loc_dat.mean_x, mid_row + loc_dat.mean_y, '+k');
    plot(loc_dat.mean_x + loc_dat.std_x * [-1, 1], mid_row + loc_dat.mean_y * [1, 1], '-k')
    text(loc_dat.mean_x + loc_dat.std_x + 2, mid_row + loc_dat.mean_y, 'nonOA', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');

    % Healthy and Medial
    loc_dat = dataHealthy.medial;
    plot(loc_dat.mean_x, loc_dat.mean_y, '+k');
    plot(loc_dat.mean_x + loc_dat.std_x * [-1, 1], loc_dat.mean_y * [1, 1], '-k')
    text(loc_dat.mean_x + loc_dat.std_x + 2, loc_dat.mean_y, 'nonOA', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
end

if numel(indOA) > 0
    % OA and Lateral
    loc_dat = dataOA.lateral;
    plot(loc_dat.mean_x, mid_row + loc_dat.mean_y, '+k');
    plot(loc_dat.mean_x + loc_dat.std_x * [-1, 1], mid_row + loc_dat.mean_y * [1, 1], '-k')
    text(loc_dat.mean_x + loc_dat.std_x + 2, mid_row + loc_dat.mean_y, 'OA', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    
    % OA and Medial
    loc_dat = dataOA.medial;
    plot(loc_dat.mean_x, loc_dat.mean_y, '+k');
    plot(loc_dat.mean_x + loc_dat.std_x * [-1, 1], loc_dat.mean_y * [1, 1], '-k')
    text(loc_dat.mean_x + loc_dat.std_x + 2, loc_dat.mean_y, 'OA', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
end

hold off
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);

data = struct('OA', dataOA, 'nonOA', dataHealthy);
save('average_density_data.mat', 'data');



% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


hMax = getappdata(0, 'hMax');

switch eventdata.NewValue.String
    case 'Bone Density';
        map_index = 1;
    case 'Cartilage Thickness';
        map_index = 2;
end
set(handles.pushbutton7, 'String', ['Average ', eventdata.NewValue.String])
setappdata(hMax, 'map_index', map_index);

index = getappdata(hMax, 'index');

image_list = getappdata(hMax, 'image_list');
current_image = image_list{index};
current_image = current_image{map_index};

contourf(current_image);
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);

max_data = getappdata(hMax, 'max_data');
max_data = max_data{map_index};

if max_data.lateral.loaded(index)
    x = max_data.lateral.x(index);
    y = max_data.lateral.y(index);
    
    sz = getappdata(handles.axes1, 'size');
    mid_row = round(.5*sz(1));
    
    hold on
    plot(x, y + mid_row, '+k', 'MarkerSize',10);
    text(x + 2, y + mid_row, 'Lateral', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end

if max_data.medial.loaded(index)
    x = max_data.medial.x(index);
    y = max_data.medial.y(index);
    
    hold on
    plot(x, y, '+k', 'MarkerSize',20);
    text(x + 2, y, 'Medial', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end
