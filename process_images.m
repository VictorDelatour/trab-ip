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

function process_images( folder )
    
    current_dir = pwd;
    
    cd(folder);
    file_names = dir('*.mat');
    file_names = {file_names.name};
    
    cd(current_dir);
    
    for im_name = file_names
         
        fprintf('%s\n', im_name{1});
        file_name =  strcat(folder, im_name{1});
        % You shouldn't poof variable, i.e. you should add a lhs to load
        load(file_name, 'masque_t', 'ProcessedData', 't_carttm', 'v_carttm');
        
        
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
        
 
        %%
        
%         image = squeeze(ProcessedData.DicomCube(slice_ml_l,:,:));
%         image = imrotate(image, 90);
%         mask = imrotate(squeeze(masque_t(slice_ml_l,:,:)),90);
%         figure(4)
%         imshow(mat2gray(image));
%         waitforbuttonpress;
%         
%         image = squeeze(ProcessedData.DicomCube(slice_ml_r,:,:));
%         image = imrotate(image, 90);
%         mask = imrotate(squeeze(masque_t(slice_ml_r,:,:)),90);
%         figure(4)
%         imshow(mat2gray(image));
% %         waitforbuttonpress;
%         waitfor(4)
        
        %% Get ROIs
        % Left
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_l,:,:));
        image = imrotate(image, 90); % Image is rotated
        mask = imrotate(squeeze(masque_t(slice_ml_l,:,:)),90);
        
        idx_min_l = 1;
        idx_max_l = round(x_max/x_resolution);
        
        roi_l = get_rois(idx_min_l, idx_max_l, image, mask);
        
        %% Right
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_r,:,:));
        image = imrotate(image, 90); % Image is rotated
        mask = imrotate(squeeze(masque_t(slice_ml_r,:,:)),90);
        
        ncol = size(image,2);
        
        idx_min_r = round(min(x_uni(x_uni>x_max))/x_resolution);
        idx_max_r = ncol;
        
        roi_r = get_rois(idx_min_r, idx_max_r, image, mask);
        
        
   %% Process each ROI to get information     

        
       
    end   
    
    %% Combine statistical data and save to file
    
end
