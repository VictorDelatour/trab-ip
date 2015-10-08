function process_images( folder )
    
    current_dir = pwd;
    
    cd(folder);
    file_names = dir('*.mat');
    file_names = {file_names.name};
    
    cd(current_dir);
    
    for im_name = file_names
        
        
        
        fprintf('%s\n', im_name{1});
        file_name =  strcat(folder, im_name{1});
        load(file_name, 'masque_t', 'ProcessedData', 't_carttm', 'v_carttm');
        
        x_res = mean(diff(ProcessedData.X_Cube(1,:,1)));
        y_res = mean(diff(ProcessedData.Y_Cube(:,1,1)));
        z_res = mean(diff(ProcessedData.Z_Cube(1,1,:)));
        
        % Insert code to compute slice of reference
        v_ind = unique(t_carttm);

        v = v_carttm(v_ind,:);
        
        x_uni = unique(v_carttm(v_ind,1));
        
        x_max = x_uni(find(diff(x_uni)>2, 1));
        ind_left = v(:,1)<=x_max;
 
               
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

        %%
        slice_ml_l = round(mean_l(2)/y_res);
        slice_ml_r = round(mean_r(2)/y_res);
        
        slice_ap_l = round(mean_l(1)/x_res);
        slice_ap_r = round(mean_r(1)/x_res);
        
 
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
        image = imrotate(image, 90);
        mask = imrotate(squeeze(masque_t(slice_ml_l,:,:)),90);
        
        [nrow, ncol] = size(image);
        
        idx_min_l = 1;
        idx_max_l = round(x_max/x_res);
        
        roi_l = get_rois(idx_min_l, idx_max_l, image, mask);
        
        %% Right
        
        image = squeeze(ProcessedData.DicomCube(slice_ml_r,:,:));
        image = imrotate(image, 90);
        mask = imrotate(squeeze(masque_t(slice_ml_r,:,:)),90);
        
        idx_min_r = round(min(x_uni(x_uni>x_max))/x_res);
        idx_max_r = ncol;
        
        roi_r = get_rois(idx_min_r, idx_max_r, image, mask);
        
        
        
%         [roi_left, roi_right] = get_rois(double(image), double(mask));
%         roi_left = double(roi_left);
% %         waitforbuttonpress;
% %         close all
        
       
    end
    
end



