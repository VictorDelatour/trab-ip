function [ bone_surf_map, rowInd, colInd ] = get_bone_surf_map( mat, mask, rowInd, colInd )

    nrow = size(mask, 1);
    
    bone_surf_map = nan(size(mat));

    for ind = 1:numel(rowInd)
        res = find(mask(rowInd(ind), colInd(ind),:)>0, 1, 'last');
        if numel(res) > 0
            bone_surf_map(rowInd(ind), colInd(ind)) = find(mask(rowInd(ind), colInd(ind),:)>0, 1, 'last');
        end
    end
    
    ind = ~isnan(bone_surf_map(rowInd + (colInd-1) * nrow));
    
    rowInd = rowInd(ind);
    colInd = colInd(ind);


end

