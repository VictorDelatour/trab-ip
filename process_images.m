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
    stats = zeros(n_files, 18);
    
    %%
    for i = 1:numel(file_names)
         
        fprintf('%s\n', file_names{i});
        file_name =  strcat(folder, file_names{i});
        
        data = load(file_name, 'masque_t', 'ProcessedData', 't_carttm', 'v_carttm');
        
        masque_t = data.masque_t;
        ProcessedData = data.ProcessedData;
        t_carttm = data.t_carttm;
        v_carttm = data.v_carttm;
        
        x_resolution = mean(diff(ProcessedData.X_Cube(1,:,1)));
        y_resolution = mean(diff(ProcessedData.Y_Cube(:,1,1)));
        z_resolution = mean(diff(ProcessedData.Z_Cube(1,1,:)));
        
        %% Get slices of reference for the mediolateral and anterioposterior axis
        v_ind = unique(t_carttm); % list all used vertices in the cartilage triangulation

        v = v_carttm(v_ind,:); % get posititions of listed vertices
        
        x_uni = unique(v_carttm(v_ind,1)); % get all x coordinates used
        
        % The medial and lateral spine are separated by a gap. diff(x_uni)
        % should remain very small for all x's except the one at the gap
        x_max = x_uni(find(diff(x_uni)>2, 1));  
        ind_left = v(:,1)<=x_max; % left indices
 
        % Compute center of mass for left and right cartilages       
        mean_l = [mean(v(ind_left,1)), mean(v(ind_left,2)), mean(v(ind_left,3))];
        mean_r = [mean(v(~ind_left,1)), mean(v(~ind_left,2)), mean(v(~ind_left,3))];
        
        %% Plot to check 
        
%         figure(1)
%         showfig(v_carttm, t_carttm);
%         waitfor(1)
%         figure(1)
%         plot3(v(ind_left,1), v(ind_left,2), v(ind_left,3), 'bx'); 
%         hold on; 
%         plot3(mean_l(1), mean_l(2), mean_l(3), 'ro');
%         hold off;
%         waitfor(1)
% 
%         
%         figure(2)
%         plot3(v(~ind_left,1), v(~ind_left,2), v(~ind_left,3), 'bx'); 
%         hold on; 
%         plot3(mean_r(1), mean_r(2), mean_r(3), 'ro');
%         hold off;
%         waitfor(2)

        %% Medio-lateral image of interest based on center of mass
        slice_ml_l = round(mean_l(2)/y_resolution);
        slice_ml_r = round(mean_r(2)/y_resolution);
        
        %% Anterio-posterior (not used yet)
%         slice_ap_l = round(mean_l(1)/x_res);
%         slice_ap_r = round(mean_r(1)/x_res);
        
 
        %% Plot left and right ml slices
        
%         image = squeeze(ProcessedData.DicomCube(slice_ml_l,:,:));
%         image = imrotate(image, 90);
%         mask = imrotate(squeeze(masque_t(slice_ml_l,:,:)),90);
%         figure(1)
%         imshow(mat2gray(image));
%         waitfor(1)
%         
%         image = squeeze(ProcessedData.DicomCube(slice_ml_r,:,:));
%         image = imrotate(image, 90);
%         mask = imrotate(squeeze(masque_t(slice_ml_r,:,:)),90);
%         figure(1)
%         imshow(mat2gray(image));
%         waitfor(1)
        
        %% Get ROIs
        
        cort_layer = 10;
        roi_height = 30;
        
        %% Get left ROI
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_l,:,:));
        image = imrotate(image, 90); % Image is rotated
        mask = imrotate(squeeze(masque_t(slice_ml_l,:,:)),90);
        
        idx_min_l = 1;
        idx_max_l = round(x_max/x_resolution);
        
        roi_l = get_ml_roi(idx_min_l, idx_max_l, image, mask, cort_layer, roi_height);

        
        %% Get right ROI
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_r,:,:));
        image = imrotate(image, 90); % Image is rotated
        mask = imrotate(squeeze(masque_t(slice_ml_r,:,:)),90);
        
        ncol = size(image,2);
        
        idx_min_r = round(min(x_uni(x_uni>x_max))/x_resolution);
        idx_max_r = ncol;
        
        roi_r = get_ml_roi(idx_min_r, idx_max_r, image, mask, cort_layer, roi_height);
        
        
   %% Process each ROI to get information     
                
        stats_l = get_stats(roi_l);
        stats_r = get_stats(roi_r);
        
        %%
        stats(i, 1:9) = cell2mat(struct2cell(stats_l));
        stats(i, 10:end) = cell2mat(struct2cell(stats_r));
       
    end   
    
    %% Combine statistical data to dataset
    
    l_stats = mat2dataset(stats(:, 1:9));
    r_stats = mat2dataset(stats(:, 10:end));
    
    l_stats.Properties.VarNames = fieldnames(stats_l);
    r_stats.Properties.VarNames = fieldnames(stats_r);
    
    l_stats.file = file_names(:);
    
    for i = 1:n_files
        l_stats.file{i} = l_stats.file{i}(1:7);
    end
    
    
    r_stats.file = l_stats.file;
    
    
    l_stats.OA = [0; 0; 1; 1; 1; 1; 1; 0; 0; 0];
    r_stats.OA = l_stats.OA;
    
    
    %% Save to file
    
    export(l_stats, 'file', strcat(folder, 'l_stats.txt'));
    export(r_stats, 'file', strcat(folder, 'r_stats.txt'));
    
end
