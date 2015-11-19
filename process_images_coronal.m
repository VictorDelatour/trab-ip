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

function  process_images_coronal( folder )

current_dir = pwd;

cd(folder);
file_names = dir('*.mat');
file_names = {file_names.name};

cd(current_dir);

n_files = numel(file_names);

v_statnames = fieldnames(get_main_stats(rand(3), ones(3)));
n_stats = numel(v_statnames);
n_points = 50;

stat_data = cell(n_stats,1);
for stat = 1:n_stats
    stat_data{stat} = zeros(n_points, n_files);
end

%%
for i = 1:n_files
    
    fprintf('%s, %i of %i\n', file_names{i}, i, n_files );
    file_name = strcat(folder, file_names{i});
    
    data = load(file_name, 'masque_t', 'ProcessedData');
    
    masque_t = data.masque_t;
    ProcessedData = data.ProcessedData;
    
    x_resolution = max(abs(mean(diff(ProcessedData.X_Cube(1,:,1)))), abs(mean(diff(ProcessedData.X_Cube(:,1,1)))));
    y_resolution = max(abs(mean(diff(ProcessedData.Y_Cube(1,:,1)))), abs(mean(diff(ProcessedData.Y_Cube(:,1,1)))));

    
    %% Get slices of reference for the mediolateral and anterioposterior axis
    
    v_ind_lateral = unique(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.triangles);
    v_ind_medial = unique(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.triangles);
    
    mean_lateral_x = mean(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,1));    
    mean_medial_x = mean(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1));

    
    %% Define slices and indices of interest
    
    idx_min_lateral = round(min(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,1))/x_resolution);
    idx_max_lateral = round(max(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Lateral.vertices(v_ind_lateral,1))/x_resolution);
   
    idx_min_medial = round(min(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1))/x_resolution);
    idx_max_medial = round(max(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1))/x_resolution);
    
    %% Flip data if lateral on the wrong side
    
    % Too heavy, flip only the image!
    if mean_lateral_x > mean_medial_x
        ProcessedData.DicomCube = flip(ProcessedData.DicomCube,2);
        masque_t = flip(masque_t,2);
        
        ncol = size(ProcessedData.DicomCube, 2);
        
        len = idx_max_lateral - idx_min_lateral;
        idx_max_lateral = ncol + 1 - idx_min_lateral;
        idx_min_lateral = idx_max_lateral - len;
        
        len = idx_max_medial - idx_min_medial;
        idx_min_medial = ncol + 1 - idx_max_medial;
        idx_max_medial = idx_min_medial + len;
    end
    
    %% Params
    
    cort_layer = 10;
    roi_height = 40;
    
    vstats = zeros(idx_max_medial-idx_min_medial+1, n_stats);
    vscore = zeros(idx_max_medial-idx_min_medial+1, 1);
    
    %% Loop over slices of interest
    
    for slice = idx_min_medial:idx_max_medial
        fprintf('Slice %i of %i\n', slice-idx_min_medial+1, size(vstats,1));
        image = mat2gray(imrotate(squeeze(ProcessedData.DicomCube(:,slice,:)),90));
        mask = imrotate(squeeze(masque_t(:,slice,:)),90);
%         image(mask==0) = 0;
        
        idx_min_sagittal = 1;
        idx_max_sagittal = size(image, 2);
                
        
        [score, roi_sagittal_medial] = get_roi('sagittal', idx_min_sagittal, idx_max_sagittal, image, mask, cort_layer, roi_height);
        [~, bin_roi_sagittal_medial] = get_roi('sagittal', idx_min_medial, idx_max_medial, binarize(mat2gray(image)), mask, cort_layer, roi_height);
        
        vscore(slice-idx_min_medial+1) = score;
        vstats(slice-idx_min_medial+1,:) = cell2mat(struct2cell(get_main_stats(roi_sagittal_medial, bin_roi_sagittal_medial)))';
 
    end
    
    %%
    thresh = .1;
    if median(vscore) > thresh
        vstats(:,:) = 0;
        fprintf('Data %s is not valid\n', file_names{i});
    end
    
    xv = linspace(idx_min_medial, idx_max_medial, n_points)';
    for stat = 1:n_stats
        stat_data{stat}(:,i) = interp1(idx_min_medial:idx_max_medial, vstats(:,stat), xv);
    end    
    
end

%%
for i = 1:n_files
    file_names{i} = file_names{i}(1:7);
end

%%
file = strcat(folder, 'Prestudy_Data.xlsx');
[num, txt, raw] = xlsread(file);

used_files = intersect(txt(:,1), file_names(:));

OA = zeros(numel(used_files), 1);
to_process = [];

for i = 1:numel(used_files)
    OA(i) = strcmp( txt(strcmp(used_files(i), txt(:,1)),2), 'OA');
end

OA = logical(OA);
full_OA = OA;

%%

xv = 1:size(stat_data{1},1);

for stat = 1:n_stats
    stats = stat_data{stat}(:, range(stat_data{stat})>0);
    OA = full_OA(range(stat_data{stat})>0);
    
    plot(xv, mean(stats(:,OA),2), '-or', xv, mean(stats(:,~OA),2), '-ob')
    title(v_statnames(stat));
    legend('OA', 'non-OA');
    hold on
    plot(xv, mean(stats(:, OA),2)+std(stats(:, OA),0,2), '--r', xv, mean(stats(:, OA),2)-std(stats(:, OA),0,2), '--r')
    plot(xv, mean(stats(:, ~OA),2)+std(stats(:, ~OA),0,2), '--b', xv, mean(stats(:, ~OA),2)-std(stats(:, ~OA),0,2), '--b')
    hold off
    waitforbuttonpress
    
%     boxplot(rms(stat_data{stat}(:, range(stat_data{1})>0),1), OA)
%     title(sprintf('%s: RMS', v_statnames{stat}));
%     waitforbuttonpress

    boxplot(mean(stat_data{stat}(:, range(stat_data{1})>0),1), OA)
    title(sprintf('%s: mean', v_statnames{stat}));
    waitforbuttonpress
end


end
