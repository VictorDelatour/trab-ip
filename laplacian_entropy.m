function [ entropy ] = laplacian_entropy( image )

[nrow, ncol] = size(image);

idx = 2:nrow-1;
idy = 2:ncol-1;

laplacian = image(idx+1, idy) + image(idx, idy+1) + image(idx-1, idy) + image(idx, idy-1);
laplacian = laplacian - 4*image(idx, idy);
laplacian = mat2gray(laplacian);


mod_image = sqrt(laplacian).*image(idx, idy);
mod_image = mat2gray(mod_image);


figure(1);
imshow(mod_image);
figure(2);
imshow(image);

ng = 256;
hist = round(mod_image*ng);
figure(3);
H = histogram(hist, 'BinMethod', 'integers');
P = H.Values./sum(H.Values);
P = P(P~=0);
entropy = -sum(P.*log2(P));


end

