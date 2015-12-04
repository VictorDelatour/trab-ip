function varargout = GUI_aBMD(varargin)
% GUI_ABMD MATLAB code for GUI_aBMD.fig
%      GUI_ABMD, by itself, creates a new GUI_ABMD or raises the existing
%      singleton*.
%
%      H = GUI_ABMD returns the handle to a new GUI_ABMD or the handle to
%      the existing singleton*.
%
%      GUI_ABMD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ABMD.M with the given input arguments.
%
%      GUI_ABMD('Property','Value',...) creates a new GUI_ABMD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_aBMD_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_aBMD_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_aBMD

% Last Modified by GUIDE v2.5 03-Dec-2015 16:44:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_aBMD_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_aBMD_OutputFcn, ...
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


% --- Executes just before GUI_aBMD is made visible.
function GUI_aBMD_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_aBMD (see VARARGIN)

% Choose default command line output for GUI_aBMD
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(0, 'hGUI_aBMD', gcf);

setappdata(handles.figure1, 'loaded_value', -1);

% UIWAIT makes GUI_aBMD wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_aBMD_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_dir = pwd;

folder = getappdata(0, 'folder'); % Check for previous folder
folder = uigetdir(folder,'Folder selection'); % Open in previous folder

if folder ~= 0
    cd(folder);

    file_names = dir('*.mat');
    [file_names, ~] = sortrows({file_names.name}');
    handles.file_names = file_names;
    guidata(handles.figure1, handles)
    set(handles.listbox1, 'String', handles.file_names, 'Value', 1);
    
    setappdata(0, 'folder', folder);
end

cd(current_dir);

setappdata(handles.pushbutton1, 'folderpath', folder);



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile({'*.xls; *.xlsx', 'Excel Files (*.xls,*.xlsx)'},'Select the OA file');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GUI_Map

hGUI_Map = getappdata(0, 'hGUI_Map');
setappdata(hGUI_Map, 'region', 'medial');

% hGUI_Map = getappdata(0, 'hGUI_Map');
% setappdata(hGUI_Map





% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GUI_Map

hGUI_Map = getappdata(0, 'hGUI_Map');
setappdata(hGUI_Map, 'region', 'lateral');


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index = get(handles.listbox1, 'Value');
loaded_index = getappdata(handles.figure1, 'loaded_value');
fprintf('Loaded data index: %i\n Current index: %i \n', loaded_index, index);
if loaded_index ~= index
    full_path_name = get_file(handles);
    fprintf('Loading data\n');
    data = load(full_path_name, 'masque_t', 'ProcessedData');
    fprintf('Data loaded\n');
    
%     figure(2);
%     imshow(mat2gray(squeeze(data.ProcessedData.DicomCube(:,:,150))));

    hGUI_aBMD = getappdata(0, 'hGUI_aBMD');
    
    setappdata(hGUI_aBMD, 'data', data);
    setappdata(handles.figure1, 'loaded_value', index);
    set(handles.pushbutton3, 'Enable', 'on');
    set(handles.pushbutton4, 'Enable', 'on');
    
end
