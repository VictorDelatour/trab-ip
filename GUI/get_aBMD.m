function [bone_surf_map, rowInd, colInd, mat, limits] = get_aBMD( data, region )
    
    
    masque_t = data.masque_t;
    ProcessedData = data.ProcessedData;
    
    [nrow, ncol, ~] = size(ProcessedData.DicomCube);
    
    x_resolution = mean(diff(ProcessedData.X_Cube(1,:,1)));
    y_resolution = mean(diff(ProcessedData.Y_Cube(:,1,1)));
    
    %% Get indices of lateral and medial cartilages
    
    v_ind_lateral = unique(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.triangles);
    v_ind_medial = unique(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.triangles);
    
    mean_lateral_x = mean(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,1));     
    mean_medial_x = mean(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1));
    
    ind_X_medial = round(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1)/x_resolution);
    ind_Y_medial = round(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,2)/y_resolution);
    
    ind_X_lateral = round(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,1)/x_resolution);
    ind_Y_lateral = round(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,2)/y_resolution);
    
    if mean_lateral_x > mean_medial_x
        ProcessedData.DicomCube = flip(ProcessedData.DicomCube,2);
        masque_t = flip(masque_t,2);    
        ind_X_medial = size(ProcessedData.DicomCube, 1) + 1 - ind_X_medial;
        ind_X_lateral = size(ProcessedData.DicomCube,1) + 1 - ind_X_lateral;
    end
    
    %%
    
    if strcmp(region, 'medial')
        [mat, rowInd, colInd, limits] = get_cart_projection_mask(nrow, ncol, ind_X_medial, ind_Y_medial);
    elseif strcmp(region, 'lateral')
        [mat, rowInd, colInd, limits] = get_cart_projection_mask(nrow, ncol, ind_X_lateral, ind_Y_lateral);
    end
        
    %% Get a map of the bone surface
    [bone_surf_map, rowInd, colInd] = get_bone_surf_map( mat, masque_t, rowInd, colInd );
    
end

