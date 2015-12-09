function image = load_image(hObject, index)

loaded_images = getappdata(hObject, 'loaded_images');
image_list = getappdata(hObject, 'image_list');

if loaded_images(index)
    image = image_list{index};
else
    
    full_file_names = getappdata(hObject, 'full_file_names');
    
    fprintf('Loading data... ');
    data = load(full_file_names{index});
    fprintf('Loaded\n');

    image = imrotate(mat2gray(data.meshData.femur.cartThicknessMap), 90);
    
    image_list{index} = image;
    loaded_images(index) = true;
    
    setappdata(hObject, 'image_list', image_list);
    setappdata(hObject, 'loaded_images', loaded_images);
    
end

end

