%
% function process_images( folder )
%
% Author1:      H. Babel (hugo.babel@epfl.ch)
% Function:     Process_images
%
% Description:  Reads all .mat files contained in the given folder,
% computes the region of interest (ROI) for the coronal and
% sagittal slices of the tibia, and computes anisotropy,
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

coronal_stats = zeros(n_files, 52);
sagittal_stats = zeros(n_files, 52);

n_plots = ceil(sqrt(n_files));

% Indices for the plots
i_sagittal_medial = 1;
i_sagittal_lateral = 2;
i_coronal_medial = 3;
i_coronal_lateral = 4;



%%
for i = 1:n_files
    
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
    
    %% Define slices and indices of interest
    
    % Medio-lateral image of interest based on center of mass
    slice_coronal_lateral = round(mean_lateral_y/y_resolution);
    slice_coronal_medial = round(mean_medial_y/y_resolution);
    
    slice_sagittal_lateral = round(mean_lateral_x/x_resolution);
    slice_sagittal_medial = round(mean_medial_x/x_resolution);
    
    ncol = size(ProcessedData.DicomCube, 2);
    
    plane_ind = find(abs(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,2)-mean_lateral_y)<=y_resolution);
    
    idx_min_lateral = round(min(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral(plane_ind),1))/x_resolution);
    idx_max_lateral = round(max(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral(plane_ind),1))/x_resolution);
    
    plane_ind = find(abs(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,2)-mean_medial_y)<=y_resolution);
    
    idx_min_medial = round(min(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial(plane_ind),1))/x_resolution);
    idx_max_medial = round(max(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial(plane_ind),1))/x_resolution);
    
    %% Flip data if lateral on the wrong side
    
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
        
        temp = slice_sagittal_lateral;
        slice_sagittal_lateral = ncol + 1 - slice_sagittal_medial;
        slice_sagittal_medial = ncol + 1 - temp;
    end
    
    %% Params
    
    cort_layer = 10;
    roi_height = 50;
    
    %% Sagittal lateral
    
    image = imrotate(squeeze(ProcessedData.DicomCube(:,slice_sagittal_lateral,:)),90);
    mask = imrotate(squeeze(masque_t(:,slice_sagittal_lateral,:)),90);
    
    [score_s_l , roi_sagittal_lateral] = get_roi('sagittal', 1, size(image,2), image, mask, cort_layer, roi_height);
    [~, bin_roi_sagittal_lateral] = get_roi('sagittal', 1, size(image,2), binarize(mat2gray(image)), mask, cort_layer, roi_height);
    
    %% Sagittal medial
    
    image = imrotate(squeeze(ProcessedData.DicomCube(:,slice_sagittal_medial,:)),90);
    mask = imrotate(squeeze(masque_t(:,slice_sagittal_medial,:)),90);
    
    [score_s_m, roi_sagittal_medial] = get_roi('sagittal', 1, size(image,2), image, mask, cort_layer, roi_height);
    [~, bin_roi_sagittal_medial] = get_roi('sagittal', 1, size(image,2), binarize(mat2gray(image)), mask, cort_layer, roi_height);
    
    %% Coronal Lateral
    
    image = imrotate(squeeze(ProcessedData.DicomCube(slice_coronal_lateral,:,:)), 90);
    mask = imrotate(squeeze(masque_t(slice_coronal_lateral,:,:)),90);
    
    [score_c_l, roi_coronal_lateral] = get_roi('lateral', idx_min_lateral, idx_max_lateral, image, mask, cort_layer, roi_height);
    [~, bin_roi_coronal_lateral] = get_roi('lateral', idx_min_lateral, idx_max_lateral, binarize(mat2gray(image)), mask, cort_layer, roi_height);
    
    %% Coronal Medial
    
    image = imrotate(squeeze(ProcessedData.DicomCube(slice_coronal_medial,:,:)),90);
    mask = imrotate(squeeze(masque_t(slice_coronal_medial,:,:)),90);
    
    [score_c_m, roi_coronal_medial] = get_roi('medial', idx_min_medial, idx_max_medial, image, mask, cort_layer, roi_height);
    [~, bin_roi_coronal_medial] = get_roi('medial', idx_min_medial, idx_max_medial, binarize(mat2gray(image)), mask, cort_layer, roi_height);
    
    %% Can we proceed with stats?
    
    thresh = .1;
    
    if max([score_s_l, score_s_m, score_c_l, score_c_m])>= thresh;
%         nslices = nslices-1;
        continue
    end
    
    %% Plot
    %{
            figure(i_sagittal_lateral)
            subplot(n_plots, n_plots, i);
            imshow(mat2gray(roi_sagittal_lateral));
            title(strcat(file_names{i}(1:7), '-s-l'));
        
        
            figure(i_sagittal_medial)
            subplot(n_plots, n_plots, i);
            imshow(mat2gray(roi_sagittal_medial));
            title(strcat(file_names{i}(1:7), '-s-m'));
        
            figure(i_coronal_lateral)
            subplot(n_plots, n_plots, i);
            imshow(mat2gray(roi_coronal_lateral));
            title(strcat(file_names{i}(1:7), '-c-l'));
        
            figure(i_coronal_medial)
            subplot(n_plots, n_plots, i);
            imshow(mat2gray(roi_coronal_medial));
            title(strcat(file_names{i}(1:7), '-c-m'));
        
            % Binary version
            figure(i_sagittal_lateral+4)
            subplot(n_plots, n_plots, i);
            imshow(bin_roi_sagittal_lateral);
            title(strcat(file_names{i}(1:7), '-s-l'));
        
        
            figure(i_sagittal_medial+4)
            subplot(n_plots, n_plots, i);
            imshow(bin_roi_sagittal_medial);
            title(strcat(file_names{i}(1:7), '-s-m'));
        
            figure(i_coronal_lateral+4)
            subplot(n_plots, n_plots, i);
            imshow(bin_roi_coronal_lateral);
            title(strcat(file_names{i}(1:7), '-c-l'));
        
            figure(i_coronal_medial+4)
            subplot(n_plots, n_plots, i);
            imshow(bin_roi_coronal_medial);
            title(strcat(file_names{i}(1:7), '-c-m'));
    %}
    
    %% Process each ROI to get information
    
    stats_coronal_lateral = get_stats(roi_coronal_lateral, bin_roi_coronal_lateral);
    stats_coronal_medial = get_stats(roi_coronal_medial, bin_roi_coronal_medial);
    
    stats_sagittal_lateral = get_stats(roi_sagittal_lateral, bin_roi_sagittal_lateral);
    stats_sagittal_medial = get_stats(roi_sagittal_medial, bin_roi_sagittal_medial);
    
    %%
    
    n_stats = numel(fieldnames(stats_coronal_lateral));
    
    coronal_stats(i, 1:n_stats) = cell2mat(struct2cell(stats_coronal_lateral))';
    coronal_stats(i, (n_stats+1):end) = cell2mat(struct2cell(stats_coronal_medial))';
    
    sagittal_stats(i, 1:n_stats) = cell2mat(struct2cell(stats_sagittal_lateral))';
    sagittal_stats(i, (n_stats+1):end) = cell2mat(struct2cell(stats_sagittal_medial))';
    
end


%% Combine statistical data to dataset
lateral_coronal_stats = array2table(coronal_stats(:, 1:n_stats), 'VariableNames', fieldnames(stats_coronal_lateral));
medial_coronal_stats = array2table(coronal_stats(:, (n_stats+1):end), 'VariableNames', fieldnames(stats_coronal_medial));
lateral_sagittal_stats = array2table(sagittal_stats(:, 1:n_stats), 'VariableNames', fieldnames(stats_sagittal_lateral));
medial_sagittal_stats = array2table(sagittal_stats(:, (n_stats+1):end), 'VariableNames', fieldnames(stats_sagittal_medial));

lateral_coronal_stats.file = file_names(:);

for i = 1:n_files
    lateral_coronal_stats.file{i} = lateral_coronal_stats.file{i}(1:7);
end

medial_coronal_stats.file = lateral_coronal_stats.file;
lateral_sagittal_stats.file = lateral_coronal_stats.file;
medial_sagittal_stats.file = lateral_coronal_stats.file;



%% Save to file

writetable(lateral_coronal_stats, strcat(folder, 'lateral_coronal_stats.txt'));
writetable(medial_coronal_stats, strcat(folder, 'medial_coronal_stats.txt'));
writetable(lateral_sagittal_stats, strcat(folder, 'lateral_sagittal_stats.txt'));
writetable(medial_sagittal_stats, strcat(folder, 'medial_sagittal_stats.txt'));

end
