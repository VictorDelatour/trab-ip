function [ cart_mask, limits ] = get_cartilage_projection( meshData, scanData )

    x_resolution = mean(diff(scanData.X_Cube(:,1,1)));
    y_resolution = mean(diff(scanData.Y_Cube(1,:,1)));

    v_ind_medial = unique(meshData.medSubBoneTriangles);

    ind_X_medial = round(meshData.vertices(v_ind_medial,1)/x_resolution);
    ind_Y_medial = round(meshData.vertices(v_ind_medial,2)/y_resolution);

    [nrow, ncol, ~] = size(scanData.DicomCube);

    [ cart_mask, ~, ~, limits ] = get_cart_mask(nrow, ncol, ind_X_medial, ind_Y_medial );

    cart_mask = cart_mask(limits(1):limits(2), limits(3):limits(4));

end

