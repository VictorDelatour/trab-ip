function [ depth_mask ] = get_depth_mask( bone_surf_map, mask, depth, rowInd, colInd )
    
    [nrow, ncol] = size(bone_surf_map);

    
    depth_mask = zeros(nrow, ncol);
    t = mask(rowInd + (colInd-1) * nrow + (max(bone_surf_map(rowInd + (colInd - 1) * nrow) - 1 - depth, 1) * nrow * ncol)) > 0;
    depth_mask(rowInd(t) + (colInd(t)-1)*nrow) = 1;


end

