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

%     image = imrotate(data.meshData.tibia.subBoneDensityMap, -90);
    image = cell(2,1);
    image{1} = imrotate(data.meshData.tibia.subBoneDensityMap, -90);
    image{2} = imrotate(data.meshData.tibia.cartThicknessMap, -90);
    
    image_list{index} = image;
    loaded_images(index) = true;
    
    setappdata(hObject, 'image_list', image_list);
    setappdata(hObject, 'loaded_images', loaded_images);
    
end

end

