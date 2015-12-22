function [ image, mask, limits ] = select_image( meshData, scanData, pos, density_size )

x_resolution = abs(mean(diff(scanData.X_Cube(:,1,1))));
y_resolution = abs(mean(diff(scanData.Y_Cube(1,:,1))));

v_ind_medial = unique(meshData.medSubBoneTriangles);

ind_X_medial = round(meshData.vertices(v_ind_medial,1)/x_resolution);
ind_Y_medial = round(meshData.vertices(v_ind_medial,2)/y_resolution);

[nrow, ncol, ~] = size(scanData.DicomCube);

[ cart_mask, ~, ~, limits ] = get_cart_mask(nrow, ncol, ind_X_medial, ind_Y_medial );

cart_mask = cart_mask(limits(1):limits(2), limits(3):limits(4));

mean_medial_row = pos.x / density_size(2) * size(cart_mask,2);
% mean_medial_col = pos.y / density_size(1) * size(cart_mask,1);

soi = round(mean_medial_row + limits(1));
image = imrotate(mat2gray(squeeze(scanData.DicomCube(:,soi,:))),90);
mask = imrotate(squeeze(scanData.mask(:,soi,:)),90);

limits = limits(3:4);

end

