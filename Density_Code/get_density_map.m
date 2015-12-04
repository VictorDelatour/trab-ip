function [ density_map ] = get_density_map( bone_surf_map, mat, image, rowInd, colInd, depth, radius )

    [nrow, ncol] = size(bone_surf_map);
    
    density_map = nan(size(bone_surf_map));
        
    circle_list = find(strel('disk', 5, 0).getnhood); % Simpler, cleaner
%     circle_list = find( (repmat(1:2*radius+1, 2*radius+1, 1)-(radius+1)).^2 + (repmat([1:2*radius+1]', 1, 2*radius+1)-(radius+1)).^2 <= radius^2);
    [Ic, Jc] = ind2sub([2*radius+1, 2*radius+1], circle_list);

    
    for ind = 1:numel(rowInd)
        
        index_list = (colInd(ind)-1 + Jc-(radius+1))*nrow + (rowInd(ind) + Ic - (radius+1)); % Circle around current position
        index_list = index_list(index_list > 0 & index_list < numel(image)); % Discard out of bound elements
        index_list = index_list(~isnan(bone_surf_map(index_list))); % Discard NaNs in data
        index_list = index_list(mat(index_list)>0); % Discard out of mask elements

        if numel(index_list)>0
            indices = bsxfun(@minus, bone_surf_map(index_list), 0:depth-1)*nrow*ncol;
            indices(indices<1) = NaN;
            indices = bsxfun(@plus, index_list, indices);
            density_map(rowInd(ind), colInd(ind)) = sum(image(indices(~isnan(indices))));
        end
        
    end

end

