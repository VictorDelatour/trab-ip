function [ row, col ] = get_density(image, mask, ind_X, ind_Y, region)
    %% Get mask of points to consider
   
    
    [nrow, ncol, ~] = size(image);
    
    [mat, rowInd, colInd, limits] = get_cart_projection_mask(nrow, ncol, ind_X, ind_Y);
    
    %% Get a map of the bone surface
    [bone_surf_map, rowInd, colInd] = get_bone_surf_map( mat, mask, rowInd, colInd );
    
    %% Get surface density map:
    
    radius = 3;
    depth = 10;

    surf_density_map = get_density_map(bone_surf_map, mat, image, rowInd, colInd, depth, radius);
    
    [row, col] = get_max_density_coord(surf_density_map, limits);
    
    
    %% Get depth bone density
    
    n_depth = floor(min(bone_surf_map(:)-1)./depth);
    maxLocation = zeros(min(n_depth, 3)+1,2);
    maxLocation(1,:) = [row, col];
    
    se = strel('disk', 8);
    
    for n = 1:min(n_depth, 3)
        
        depth_mask = get_depth_mask(bone_surf_map, mask, n * depth, rowInd, colInd);
        
        depth_mask = imerode(depth_mask, se);
        
        [depth_rowInd, depth_colInd] = ind2sub(size(bone_surf_map), find(depth_mask>0));
        depth_density_map = get_density_map(bone_surf_map - n * depth, depth_mask, image, depth_rowInd, depth_colInd, depth, radius);
%         
%         figure(2);
%         imshow(mat2gray(depth_density_map))
%         hold on
%         contour(depth_density_map);
%         hold off
%         waitforbuttonpress;
        [depthRow, depthCol] = get_max_density_coord(depth_density_map, limits);
        maxLocation(n+1,:) = [depthRow, depthCol];
        
        
    end
        
%%

close all

figure(1);
plot(maxLocation(1,2), maxLocation(1,1), 'sr', maxLocation(2:end, 2), maxLocation(2:end, 1), 'db');
axis([0 1 0 1]);
xlabel('Lateral - Medial');
waitforbuttonpress





end

