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

function  process_folder( folder )

current_dir = pwd;

cd(folder);
file_names = dir('*.mat');
file_names = {file_names.name};

n_files = numel(file_names);

row_medial = zeros(n_files,1);
col_medial = zeros(size(row_medial));

row_lateral = zeros(size(row_medial));
col_lateral = zeros(size(row_medial));

%%
for i = 1:n_files
    file_names{i} = file_names{i}(1:7);
end

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

file_names = dir('*.mat');
file_names = {file_names.name};

cd(current_dir);

%%
for i = 1:n_files
    
    fprintf('%s, OA: %i\n', file_names{i}, OA(i));
    file_name = strcat(folder, file_names{i});
    
    data = load(file_name, 'masque_t', 'ProcessedData');
    
    masque_t = data.masque_t;
    ProcessedData = data.ProcessedData;
    
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
        ind_X_medial = size(ProcessedData.DicomCube,1) + 1 - ind_X_medial;
        ind_X_lateral = size(ProcessedData.DicomCube,1) + 1 - ind_X_lateral;
    end
    
    %% Medial
    
    fprintf('\nMedial... ');
    
    [row, col] = get_density(ProcessedData.DicomCube, masque_t, ind_X_medial, ind_Y_medial, 'medial');

    row_medial(i) = row;
    col_medial(i) = col;
    
    %% Lateral
    
    fprintf('\nLateral... ');
    
    [row, col] = get_density(ProcessedData.DicomCube, masque_t, ind_X_lateral, ind_Y_lateral, 'lateral');

    row_lateral(i) = row;
    col_lateral(i) = col;
    
end

fprintf('Done\n');


%%

xv = col_medial;
yv = row_medial;

figure(2)
plot(xv(OA), yv(OA), 'ro', xv(~OA), yv(~OA), 'bx');
axis([0 1 0 1]);
title('Medial');
xlabel('Lateral - Medial');
hold on
plot(median(xv(OA)), median(yv(OA)), 'ko', median(xv(~OA)), median(yv(~OA)), 'kx');

plot(median(xv(OA)) + [-1 1]*std(xv(OA)), median(yv(OA))*ones(2,1), '-r');
plot(median(xv(OA))*ones(2,1), median(yv(OA)) + [-1 1]*std(yv(OA)), '-r');

plot(median(xv(~OA)) + [-1 1]*std(xv(~OA)), median(yv(~OA))*ones(2,1), '-b');
plot(median(xv(~OA))*ones(2,1), median(yv(~OA)) + [-1 1]*std(yv(~OA)), '-b');
hold off

%%

xv = 1 - col_lateral;
yv = row_lateral;

figure(2)
plot(xv(OA), yv(OA), 'ro', xv(~OA), yv(~OA), 'bx');
axis([0 1 0 1]);
title('Lateral');
xlabel('Lateral - Medial');
hold on
plot(median(xv(OA)), median(yv(OA)), 'ko', median(xv(~OA)), median(yv(~OA)), 'kx');

plot(median(xv(OA)) + [-1 1]*std(xv(OA)), median(yv(OA))*ones(2,1), '-r');
plot(median(xv(OA))*ones(2,1), median(yv(OA)) + [-1 1]*std(yv(OA)), '-r');

plot(median(xv(~OA)) + [-1 1]*std(xv(~OA)), median(yv(~OA))*ones(2,1), '-b');
plot(median(xv(~OA))*ones(2,1), median(yv(~OA)) + [-1 1]*std(yv(~OA)), '-b');
hold off

end
