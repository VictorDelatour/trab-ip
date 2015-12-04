function fullpathname = get_file(handles)

index = get(handles.listbox1, 'Value');
filenames = get(handles.listbox1, 'String');
folderpath = getappdata(handles.pushbutton1,'folderpath');
filename = char(filenames(index));
fullpathname = strcat(folderpath,'/', filename);


end
