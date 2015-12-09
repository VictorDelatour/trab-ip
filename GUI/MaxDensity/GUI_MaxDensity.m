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
    full_file_names = strcat(folder, '/', file_names);
    
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
    
    lateral = struct('loaded', false(numel(file_names),1), 'x', zeros(numel(file_names),1), 'y', zeros(numel(file_names),1));
    medial = struct('loaded', false(numel(file_names),1), 'x', zeros(numel(file_names),1), 'y', zeros(numel(file_names),1));
    max_density = struct('lateral', lateral, 'medial', medial);
    setappdata(hMax, 'max_density', max_density);
        
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

max_density = getappdata(hMax, 'max_density');
index = getappdata(hMax, 'index');

if max_density.lateral.loaded(index)
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
current_image = flipud(image_list{index});
current_image = current_image(mid_row:end,:);

[nrow, ncol] = size(current_image);


[~,h] = contourf(current_image); 
% clabel(c,h);
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

% imshow(flipud(current_image));
% hold on
% plot(col, (nrow-row+1),'r+','MarkerSize',20); 
% hold off
% waitforbuttonpress

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

% imshow(flipud(current_image));
% hold on
% plot(col, (nrow-row+1),'r+','MarkerSize',20); 
% hold off

nzInd = find(current_image>0);
[nzRows, nzCols] = ind2sub(size(current_image), nzInd);

row = sum(nzRows.*current_image(nzInd))/sum(current_image(nzInd));
col = sum(nzCols.*current_image(nzInd))/sum(current_image(nzInd));

% imshow(flipud(current_image));
% hold on
% plot(col, (nrow-row+1),'r+','MarkerSize',20); 
% hold off
% waitforbuttonpress

current_image = flipud(image_list{index});
current_image = current_image(mid_row:end,:);

contourf(current_image); 
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);
hold on
plot(col, row, 'k+', 'MarkerSize',20);
hold off

max_density.lateral.loaded(index) = true;
max_density.lateral.x(index) = col;
max_density.lateral.y(index) = row;

setappdata(hMax, 'max_density', max_density);

% --- Executes on button press in pushbutton4.
% --- Button for medial density
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');

max_density = getappdata(hMax, 'max_density');
index = getappdata(hMax, 'index');

if max_density.medial.loaded(index)
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
current_image = flipud(image_list{index});
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

% imshow(flipud(current_image));
% hold on
% plot(col, (nrow-row+1),'r+','MarkerSize',20); 
% hold off
% waitforbuttonpress

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

% imshow(flipud(current_image));
% hold on
% plot(col, (nrow-row+1),'r+','MarkerSize',20); 
% hold off

nzInd = find(current_image>0);
[nzRows, nzCols] = ind2sub(size(current_image), nzInd);

row = sum(nzRows.*current_image(nzInd))/sum(current_image(nzInd));
col = sum(nzCols.*current_image(nzInd))/sum(current_image(nzInd));

% imshow(flipud(current_image));
% hold on
% plot(col, (nrow-row+1),'r+','MarkerSize',20); 
% hold off
% waitforbuttonpress

current_image = flipud(image_list{index});
current_image = current_image(1:mid_row,:);

contourf(current_image); 
colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);
hold on
plot(col, row, 'k+', 'MarkerSize',20);
hold off

max_density.medial.loaded(index) = true;
max_density.medial.x(index) = col;
max_density.medial.y(index) = row;

setappdata(hMax, 'max_density', max_density);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hMax = getappdata(0, 'hMax');

index = getappdata(hMax, 'index');
image_list = getappdata(hMax, 'image_list');
current_image = flipud(image_list{index});

contourf(current_image); 
% colormap(jet(256));
set(handles.axes1,'DataAspectRatio',[1 1 1]);
set(handles.axes1,'YTick',[]);
set(handles.axes1,'XTick',[]);

max_density = getappdata(hMax, 'max_density');

if max_density.lateral.loaded(index)
    x = max_density.lateral.x(index);
    y = max_density.lateral.y(index);
    
    sz = getappdata(handles.axes1, 'size');
    mid_row = round(.5*sz(1));
    
    hold on
    plot(x, y + mid_row, '+k', 'MarkerSize',10);
    text(x + 2, y + mid_row, 'Lateral', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end

if max_density.medial.loaded(index)
    x = max_density.medial.x(index);
    y = max_density.medial.y(index);
    
    hold on
    plot(x, y, '+k', 'MarkerSize',20);
    text(x + 2, y, 'Medial', 'Color','black', 'FontSize',14, 'FontWeight', 'bold');
    hold off
end


