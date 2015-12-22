function [ image, mask, roi, limits ] = load_data( files, pos, density_size, index )

    h = waitbar(0,'Loading files...');
    
    meshData = load(files.mesh{index});
    meshData = meshData.meshData.tibia;
    
    waitbar(.5,h);
    
    scanData = load(files.scan{index});
    scanData = scanData.scanData;
    
    waitbar(1,h);
    close(h);
    
    %% Compute and store image
    [image, mask, limits] = select_image(meshData, scanData, pos, density_size);
    
    %% Compute and store ROI
    
    cort_layer = 10;
    roi_height = 50;
    
    [~ , roi] = get_roi('medial', limits(1), limits(2), image, mask, cort_layer, roi_height);
    


end

