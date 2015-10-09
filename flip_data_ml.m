function flip_data_ml(file_name, to_flip_folder, flipped_folder )
%%
    file = strcat(to_flip_folder, file_name);

    data_struct = load(file, 'masque_t', 'ProcessedData', 'v_carttm');
    
%     slice = 256;
    
    ProcessedData.DicomCube = flip(ProcessedData.DicomCube,2);
    masque_t = flip(masque_t,2);

%     im_flip = squeeze(ProcessedData.DicomCube(slice,:,:));
%     ma_flip = squeeze(masque_t(slice,:,:));
    
%     figure(1);
%     imshow(mat2gray(im_flip));
    
%     figure(2);
%     imshow(ma_flip);
%     waitfor(2)
%     close all
    
%     x_res = mean2(diff(ProcessedData.X_Cube(1,:,:)));
    
    x_min = min(ProcessedData.X_Cube(:));
    x_max = max(ProcessedData.X_Cube(:));
   
%     figure(2);
%     showfig(v_carttm, t_carttm);
    
    v_carttm(:,1) = x_min + (x_max - v_carttm(:,1));
        
%     figure(3);
%     showfig(v_carttm, t_carttm);
    
%     waitfor(3)
    
%     close all
    
    save_file = strcat(flipped_folder, file_name(1:(end-4)), '_flipped', file_name((end-3):end));
    
    save(save_file, 'masque_t', 'ProcessedData', 't_carttm', 'v_carttm');
    
    
    

end

