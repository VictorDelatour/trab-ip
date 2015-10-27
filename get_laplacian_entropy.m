function [ entropy ] = get_laplacian_entropy( image, ind )

nrow = size(image, 1);

laplacian = image(ind+1) + image(ind-1) + image(ind+nrow) + image(ind-nrow);
laplacian = laplacian - 4*image(ind);
laplacian = mat2gray(laplacian);

% lap_image = zeros(nrow, ncol);
% lap_image(ind) = laplacian;


mod_image = sqrt(laplacian).*image(ind);
mod_image = mat2gray(mod_image);

% m_image = zeros(nrow, ncol);
% m_image(ind) = mod_image;


ng = 256;
P = histcounts(round(mod_image*ng), 'BinMethod', 'integers')/numel(ind);
P = P(P~=0);
entropy = -sum(P.*log2(P));


end

