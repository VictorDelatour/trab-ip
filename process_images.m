% 
% function process_images( folder )
% 
% Author1:      H. Babel (hugo.babel@epfl.ch) 
% Function:     Process_images
% 
% Description:  Reads all .mat files contained in the given folder,
% computes the region of interest (ROI) for the medio-lateral and
% antero-posterior slices of the tibia, and computes anisotropy,
% homogeneity, contrast, energy, entropy and other statistical parameters
% based on these two ROIs
% 
% param[in]     folder	Folder name containing the list of .mat files 
% 
% Return     : none 
% 
% Examples of Usage: 
% 
% folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/';
% process_images(folder);
% 

function  process_images( folder )
    
    current_dir = pwd;
    
    cd(folder);
    file_names = dir('*.mat');
    file_names = {file_names.name};
    
    cd(current_dir);
    
    n_files = numel(file_names);
    n_roi = 2;
    
%     contrast_GLCM = zeros(n_files, n_roi);
%     correlation_GLCM = zeros(n_files, n_roi);
%     energy_GLCM = zeros(n_files, n_roi);
%     homogeneity_GLCM = zeros(n_files, n_roi);
%     entropy_GLCM = zeros(n_files, n_roi);
%     glob_homogeneity = zeros(n_files, n_roi);
%     loc_homogeneity = zeros(n_files, n_roi);
%     glob_anisotropy = zeros(n_files, n_roi);
    
%     stats = struct();
    stats = zeros(n_files, 28);
    
    %%
    for i = 1:numel(file_names)
         
        fprintf('%s\n', file_names{i});
        file_name = strcat(folder, file_names{i});
        
        data = load(file_name, 'masque_t', 'ProcessedData');
        
        masque_t = data.masque_t;
        ProcessedData = data.ProcessedData;
        
        x_resolution = mean(diff(ProcessedData.X_Cube(1,:,1)));
        y_resolution = mean(diff(ProcessedData.Y_Cube(:,1,1)));
%         z_resolution = mean(diff(ProcessedData.Z_Cube(1,1,:)));
        
        %% Get slices of reference for the mediolateral and anterioposterior axis
        
        v_ind_lateral = unique(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.triangles);
        v_ind_medial = unique(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.triangles);

        mean_lateral_x = mean(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,1));
        mean_lateral_y = mean(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,2));
        
        mean_medial_x = mean(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1));
        mean_medial_y = mean(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,2));
        
        %% Flip data if necessary
        
        % Medio-lateral image of interest based on center of mass
        slice_ml_lateral = round(mean_lateral_y/y_resolution);
        slice_ml_medial = round(mean_medial_y/y_resolution);
        
        ncol = size(ProcessedData.DicomCube, 2);
        
        idx_min_lateral = round(min(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,1))/x_resolution);
        idx_max_lateral = round(max(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,1))/x_resolution);
        idx_min_medial = round(min(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1))/x_resolution);
        idx_max_medial = round(max(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1))/x_resolution);
        
        %%
%         image = imrotate(squeeze(ProcessedData.DicomCube(slice_ml_lateral,:,:)),90);
        % Too heavy, flip only the image!
        if mean_lateral_x > mean_medial_x
            ProcessedData.DicomCube = flip(ProcessedData.DicomCube,2);
            masque_t = flip(masque_t,2);
    
            len = idx_max_lateral - idx_min_lateral;
            idx_max_lateral = ncol + 1 - idx_min_lateral;
            idx_min_lateral = idx_max_lateral - len;
            
            len = idx_max_medial - idx_min_medial;
            idx_min_medial = ncol + 1 - idx_max_medial;
            idx_max_medial = idx_min_medial + len;
            
        end
        
        %% Plot to check 
        
        
        %% Anterio-posterior
        slice_ap_lateral = round(mean_lateral_x/x_resolution);
        image = imrotate(squeeze(ProcessedData.DicomCube(:,slice_ap_lateral,:)),90);
        mask = imrotate(squeeze(masque_t(:,slice_ap_lateral,:)),90);
        
        image(mask == 0) = 0;
        
        figure(1);
        imshow(mat2gray(image));
        
        [roi] = get_roi('antepost', 1, size(image,2), image, mask, cort_layer, roi_height);
        
        
        slice_ap_medial = round(mean_medial_x/x_resolution);
        image = imrotate(squeeze(ProcessedData.DicomCube(:,slice_ap_medial,:)),90);
        mask = imrotate(squeeze(masque_t(:,slice_ap_medial,:)),90);
        
        image(mask == 0) = 0;
        
        figure(2);
        imshow(mat2gray(image));
 
        
        %% Get ROIs
        
        cort_layer = 10;
        roi_height = 30;
        
        %% Get left ROI
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_lateral,:,:));
        image = imrotate(image, 90); % Image is rotated
        mask = imrotate(squeeze(masque_t(slice_ml_lateral,:,:)),90);
        
        roi_lateral = get_ml_roi(idx_min_lateral, idx_max_lateral, image, mask, cort_layer, roi_height);
        
        figure(1);
        imshow(mat2gray(roi_lateral));
        waitfor(1);

        
        %% Get right ROI
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_medial,:,:));
        image = imrotate(image, 90); % Image is rotated
        mask = imrotate(squeeze(masque_t(slice_ml_medial,:,:)),90);
               
        roi_medial = get_ml_roi(idx_min_medial, idx_max_medial, image, mask, cort_layer, roi_height);
        
        figure(1);
        imshow(mat2gray(roi_medial));
        waitfor(1);
        
        
   %% Process each ROI to get information     
                
        stats_lateral = get_stats(roi_lateral);
        stats_medial = get_stats(roi_medial);
        
        %%
        
        n_stats = numel(fieldnames(stats_lateral));
        
        stats(i, 1:n_stats) = cell2mat(struct2cell(stats_lateral));
        stats(i, (n_stats+1):end) = cell2mat(struct2cell(stats_medial));
%        
    end   
    
    %% Combine statistical data to dataset
    
    lateral_stats = mat2dataset(stats(:, 1:n_stats));
    medial_stats = mat2dataset(stats(:, (n_stats+1):end));
    
    lateral_stats.Properties.VarNames = fieldnames(stats_lateral);
    medial_stats.Properties.VarNames = fieldnames(stats_medial);
    
    lateral_stats.file = file_names(:);
    
    for i = 1:n_files
        lateral_stats.file{i} = lateral_stats.file{i}(1:7);
    end
        
    medial_stats.file = lateral_stats.file;
    
    lateral_stats.OA = [0; 0; 0; 1;... %ends with AH77
     1; 0; 0; 0; 1;... %ends with BT10
     1; 1; 1; 1; 0;... %ends with H362
     1; 1; 0; 1; 0;... %ends with P296
     0; 0; 1; 0;];
    
    medial_stats.OA = lateral_stats.OA;
    
    
    %% Save to file
    
    export(lateral_stats, 'file', strcat(folder, 'lateral_stats.txt'));
    export(medial_stats, 'file', strcat(folder, 'medial_stats.txt'));
    
end
