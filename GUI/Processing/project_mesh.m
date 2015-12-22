function [ output_args ] = project_mesh( data )

% current_folder = pwd;
% 
% folder = getappdata(0, 'folder');
% folder = uigetdir(folder,'Folder selection');
% 
% if folder ~= 0
%     cd(strcat(folder, '/meshData'));
%     setappdata(0, 'folder', folder);
%     
%     file_names = dir('*.mat');
%     [file_names, ~] = sortrows({file_names.name}');
%     meshData_filenames = strcat(folder, '/meshData/', file_names);
%     scanData_filenames = strcat(folder, '/scanData/', file_names);
%     
%     cd(current_folder);
%     
% end

i = 1;
load('/Users/hugobabel/Desktop/TM CHUV/Data/All_New/meshData/A20197E_meshData.mat');
% load('/Users/hugobabel/Desktop/TM CHUV/Data/All_New/scanData/U61307X_scanData.mat');
load('A20197E_scanData.mat')
load('average_density_data.mat');
%%

mean_medial_x = data.nonOA.medial.mean_x;
mean_medial_y = data.nonOA.medial.mean_y;

x_resolution = mean(diff(scanData.X_Cube(:,1,1)));
y_resolution = mean(diff(scanData.Y_Cube(1,:,1)));

% Temporary workaround! THIS SHOULD BE medCartTriangles
v_ind_medial = unique(meshData.tibia.medSubBoneTriangles);

ind_X_medial = round(meshData.tibia.vertices(v_ind_medial,1)/x_resolution);
ind_Y_medial = round(meshData.tibia.vertices(v_ind_medial,2)/y_resolution);

[nrow, ncol, ~] = size(scanData.DicomCube);
% mat = zeros(nrow, ncol);
% mat(ind_X_medial + (ind_Y_medial-1) * nrow) = 1;

[ cart_mask, ~, ~, limits ] = get_cart_mask(nrow, ncol, ind_X_medial, ind_Y_medial );
% ful% cart_mask = cart_mask;

cart_mask = cart_mask(limits(1):limits(2), limits(3):limits(4));

%%
density_map = meshData.tibia.subBoneDensityMap;

dm_colsum = sum(density_map, 1, 'omitnan')>0;
dm_min = find(dm_colsum, 1);
dm_max = find(dm_colsum(1:round(.5*size(density_map,2))), 1, 'last');
dm_rows = [dm_min, dm_max];

dm_rowsum = sum(density_map, 2, 'omitnan')>0;
dm_min = find(dm_rowsum, 1);
dm_max = find(dm_rowsum, 1, 'last');
dm_cols = [dm_min, dm_max];

density_map = density_map(dm_cols(1):dm_cols(2),dm_rows(1):dm_rows(2));

%%
mean_medial_row = mean_medial_x / size(density_map,2) * size(cart_mask,2);
mean_medial_col = mean_medial_y / size(density_map,1) * size(cart_mask,1);

% Plot to check
% figure(1)
% subplot(1,2,1)
% imshow(cart_mask); 
% hold on; 
% plot(mean_medial_col, mean_medial_row, 'r+', 'Markersize', 20);
% hold off;
% axis equal
% 
% 
% subplot(1,2,2)
% imshow(density_map)
% hold on
% plot(mean_medial_y, mean_medial_x, 'r+', 'Markersize', 20)
% hold off
% axis equal

sagittal_soi = round(mean_medial_col + limits(3));

coronal_soi = round(mean_medial_row + limits(1));

sagittal_image = mat2gray(squeeze(scanData.DicomCube(sagittal_soi,:,:)));
coronal_image = mat2gray(squeeze(scanData.DicomCube(:,coronal_soi,:)));

% sagittal_image(squeeze(scanData.mask(sagittal_soi,:,:)) == 0) = 0;
% coronal_image(squeeze(scanData.mask(:, coronal_soi, :)) == 0) = 0;

image = imrotate(coronal_image,90);
mask = imrotate(squeeze(scanData.mask(:, coronal_soi, :)),90);

    %% Params
    
    cort_layer = 10;
    roi_height = 50;
    
    [score , roi] = get_roi('medial', limits(3), limits(4), image, masque, cort_layer, roi_height);
    

end

