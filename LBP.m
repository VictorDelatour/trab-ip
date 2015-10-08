function [ entropy ] = LBP( image )

[nrow, ncol] = size(image);
bin = zeros(3,3);
weights = [1 2 4; 8 0 16; 32 64 128];
idx = -1:1;
idy = -1:1;

mod_image = zeros(nrow-2, ncol-2);

for i = 2:nrow-1
    for j = 2:ncol-1
        bin = image(i + idx, j + idy)>=image(i,j);
        mod_image(i-1, j-1) = sum(sum(bin.*weights));
    end
end

figure(1);
imshow(mat2gray(image));

figure(2);
imshow(mat2gray(mod_image));

H = histogram(mod_image, 'BinMethod', 'integers');
P = H.Values./sum(H.Values);
P = P(P~=0);
entropy = -sum(P.*log2(P));



end

