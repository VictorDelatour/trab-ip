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
    
    ml_stats = zeros(n_files, 28);
    ap_stats = zeros(n_files, 28);
    
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
        
        slice_ap_lateral = round(mean_lateral_x/x_resolution);
        slice_ap_medial = round(mean_medial_x/x_resolution);
        
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
            
            slice_ap_lateral = ncol + 1 - slice_ap_lateral;
            slice_ap_medial = ncol + 1 - slice_ap_medial;
            
        end
        
        
        %% Anterio-posterior
        
        cort_layer = 10;
        roi_height = 30;
        
        
        image = imrotate(squeeze(ProcessedData.DicomCube(:,slice_ap_lateral,:)),90);
        mask = imrotate(squeeze(masque_t(:,slice_ap_lateral,:)),90);
        
        [roi_ap_lateral] = get_roi('antepost', 1, size(image,2), image, mask, cort_layer, roi_height);
        
%         figure(1);
%         imshow(mat2gray(roi_ap_lateral));
%         title('AP-lateral');
%         waitfor(1);
        
        image = imrotate(squeeze(ProcessedData.DicomCube(:,slice_ap_medial,:)),90);
        mask = imrotate(squeeze(masque_t(:,slice_ap_medial,:)),90);
        
        [roi_ap_medial] = get_roi('antepost', 1, size(image,2), image, mask, cort_layer, roi_height);
 
%         figure(2);
%         imshow(mat2gray(roi_ap_medial));
%         title('AP-medial');
%         waitfor(2);
        
        %% Get ROIs
        

        %% Get left ROI
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_lateral,:,:));
        image = imrotate(image, 90); % Image is rotated
        mask = imrotate(squeeze(masque_t(slice_ml_lateral,:,:)),90);
        
        roi_ml_lateral = get_ml_roi(idx_min_lateral, idx_max_lateral, image, mask, cort_layer, roi_height);
        
%         figure(1);
%         imshow(mat2gray(roi_ml_lateral));
%         title('ML-lateral');
%         waitfor(1);

        
        %% Get right ROI
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_medial,:,:));
        image = imrotate(image, 90); % Image is rotated
        mask = imrotate(squeeze(masque_t(slice_ml_medial,:,:)),90);
               
        roi_ml_medial = get_ml_roi(idx_min_medial, idx_max_medial, image, mask, cort_layer, roi_height);
        
%         figure(1);
%         imshow(mat2gray(roi_ml_medial));
%         title('ML-medial');
%         waitfor(1);
        
        
   %% Process each ROI to get information     
                
        stats_ml_lateral = get_stats(roi_ml_lateral);
        stats_ml_medial = get_stats(roi_ml_medial);
        
        stats_ap_lateral = get_stats(roi_ap_lateral);
        stats_ap_medial = get_stats(roi_ap_medial);
        
        %%
        
        n_stats = numel(fieldnames(stats_ml_lateral));
        
        ml_stats(i, 1:n_stats) = cell2mat(struct2cell(stats_ml_lateral));
        ml_stats(i, (n_stats+1):end) = cell2mat(struct2cell(stats_ml_medial));
        
        ap_stats(i, 1:n_stats) = cell2mat(struct2cell(stats_ap_lateral));
        ap_stats(i, (n_stats+1):end) = cell2mat(struct2cell(stats_ap_medial));
%        
    end   
    
    %% Combine statistical data to dataset
    
    lateral_ml_stats = mat2dataset(ml_stats(:, 1:n_stats));
    medial_ml_stats = mat2dataset(ml_stats(:, (n_stats+1):end));
    lateral_ap_stats = mat2dataset(ap_stats(:, 1:n_stats));
    medial_ap_stats = mat2dataset(ap_stats(:, (n_stats+1):end));
    
    lateral_ml_stats.Properties.VarNames = fieldnames(stats_ml_lateral);
    medial_ml_stats.Properties.VarNames = fieldnames(stats_ml_medial);
    lateral_ap_stats.Properties.VarNames = fieldnames(stats_ap_lateral);
    medial_ap_stats.Properties.VarNames = fieldnames(stats_ap_medial);
    
    lateral_ml_stats.file = file_names(:);
    
    for i = 1:n_files
        lateral_ml_stats.file{i} = lateral_ml_stats.file{i}(1:7);
    end
        
    medial_ml_stats.file = lateral_ml_stats.file;
    lateral_ap_stats.file = lateral_ml_stats.file;
    medial_ap_stats.file = lateral_ml_stats.file;

    
    
    %% Save to file
    
    export(lateral_ml_stats, 'file', strcat(folder, 'lateral_ml_stats.txt'));
    export(medial_ml_stats, 'file', strcat(folder, 'medial_ml_stats.txt'));
    export(lateral_ap_stats, 'file', strcat(folder, 'lateral_ap_stats.txt'));
    export(medial_ap_stats, 'file', strcat(folder, 'medial_ap_stats.txt'));
    
end
