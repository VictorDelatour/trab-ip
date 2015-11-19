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

cd(current_dir);

n_files = numel(file_names);

xv = zeros(n_files,1);
yv = zeros(size(xv));

%%
for i = 1:n_files
    
    fprintf('%s\n', file_names{i});
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
    
    ind_X = round(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,1)/x_resolution);
    ind_Y = round(ProcessedData.FinalMesh.Tibia.Cartilage.Submeshes.Medial.vertices(v_ind_medial,2)/y_resolution);
    
    if mean_lateral_x > mean_medial_x
        ProcessedData.DicomCube = flip(ProcessedData.DicomCube,2);
        masque_t = flip(masque_t,2);    
        ind_X = size(ProcessedData.DicomCube,1) + 1 - ind_X;
    end

    %% Fill inside of mat
    
    mat = zeros(size(ProcessedData.DicomCube,1), size(ProcessedData.DicomCube,2));
    mat(ind_Y + ind_X*size(ProcessedData.DicomCube,1)) = 1;
    
    row_min = find(sum(mat,2)>0,1);
    row_max = find(sum(mat,2)>0, 1, 'last');
    
    for row = row_min:row_max
        mat(row, find(mat(row,:)>0,1):find(mat(row,:)>0, 1, 'last')) = 1;
    end
    
    rowInd = [];
    colInd = [];
    col_min = find(sum(mat,1)>0,1);
    col_max = find(sum(mat,1)>0, 1, 'last');
    
    for col = col_min:col_max
        nzRows = find(mat(:,col)>0,1):find(mat(:,col)>0, 1, 'last');
        mat(nzRows, col) = 1;
        
        rowInd = [rowInd, nzRows];
        colInd = [colInd, col*ones(1, numel(nzRows))];
    end
    
    % The mask shoudl be filled and [I,J] contains all pixels 
    
    %%
    
    bone_surf_map = nan(size(mat));

    for ind = 1:numel(rowInd)
        res = find(masque_t(rowInd(ind), colInd(ind),:)>0, 1, 'last');
        if numel(res) > 0
            bone_surf_map(rowInd(ind), colInd(ind)) = find(masque_t(rowInd(ind), colInd(ind),:)>0, 1, 'last');
        end
    end
   
   
    %%
%     npts = 7;
    npts = 5;
    density_map = nan(size(mat));
    r = 3;
        
    circle_list = find( (repmat(1:2*r+1, 2*r+1, 1)-(r+1)).^2 + (repmat([1:2*r+1]', 1, 2*r+1)-(r+1)).^2 <= r^2);
    [Ic, Jc] = ind2sub([2*r+1, 2*r+1], circle_list);
    [nrow, ncol, ~] = size(ProcessedData.DicomCube);
    
    for ind = 1:numel(rowInd)
        
        index_list = (colInd(ind)-1 + Jc-(r+1))*nrow + (rowInd(ind) + Ic - (r+1));
        index_list = index_list(index_list > 0 & index_list < numel(ProcessedData.DicomCube));
        index_list = index_list(~isnan(bone_surf_map(index_list)));
        index_list = index_list(mat(index_list)>0); % To discard points out of mesh, but is it necessary?
        %             density_map(rowInd(ind), colInd(ind)) = sum(sum(ProcessedData.DicomCube(bsxfun(@plus, index_list, (height - (0:npts-1))*nrow*ncol))));
        if numel(index_list)>0
            density_map(rowInd(ind), colInd(ind)) = sum(sum(ProcessedData.DicomCube(bsxfun(@plus, index_list, bsxfun(@minus, bone_surf_map(index_list), 0:npts-1)*nrow*ncol))));
        end
        
%         height = bone_surf_map(rowInd(ind), colInd(ind));
%         if ~isnan(height)
%             density = 0;
%             for row = -.5*(npts-1):.5*(npts-1)
%                 for col =  -.5*(npts-1):.5*(npts-1)
%                     density = density + sum(ProcessedData.DicomCube(rowInd(ind) + row, colInd(ind) + col, height - (0:npts-1)));
%                 end
%             end
%             density_map(rowInd(ind), colInd(ind)) = density;
%         end
    end
    
    %%
    
    density_map = density_map(row_min:row_max, col_min:col_max);

    [~, index] = max(density_map(:));
    [maxRow, maxCol] = ind2sub(size(density_map), index);

    figure(1);
    imshow(mat2gray(density_map)); 
    hold on;
    plot(maxCol, maxRow,'r.','MarkerSize',20)
    hold off
    if i < numel(file_names)
        fprintf('Press for next image\n');
        waitforbuttonpress
    end
    
    xv(i) = maxRow/size(density_map,1);
    yv(i) = maxCol/size(density_map,2);
    
    
end

fprintf('Done\n');

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

xv_meanOA = median(xv(OA));
xv_stdOA = std(xv(OA));

yv_meanOA = median(yv(OA));
yv_stdOA = std(yv(OA));


xv_meanNOA = median(xv(~OA));
xv_stdNOA = std(xv(~OA));

yv_meanNOA = median(yv(~OA));
yv_stdNOA = std(yv(~OA));


figure(1)
plot(xv(OA), yv(OA), 'ro', xv(~OA), yv(~OA), 'bx');
hold on
plot(xv_meanOA, yv_meanOA, 'ko', xv_meanNOA, yv_meanNOA, 'kx');

plot(xv_meanOA + [-1 1]*xv_stdOA, yv_meanOA*ones(2,1), '-r');
plot(xv_meanOA*ones(2,1), yv_meanOA + [-1 1]*yv_stdOA, '-r');

plot(xv_meanNOA + [-1 1]*xv_stdNOA, yv_meanNOA*ones(2,1), '-b');
plot(xv_meanNOA*ones(2,1), yv_meanNOA + [-1 1]*yv_stdNOA, '-b');
hold off

%%






end
