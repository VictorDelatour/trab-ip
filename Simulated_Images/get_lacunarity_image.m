function [ image ] = get_lacunarity_image( nrow, ncol )

matrix = round(rand(nrow, ncol));
lacunarity = get_lacunarity(matrix);

matrix = zeros(nrow, ncol);
ind = [bsxfun(@plus, 1:2:nrow, (1:2:ncol)' * nrow), bsxfun(@plus, 2:2:nrow, (0:2:ncol-1)' * nrow)];
matrix(ind(:)) = 1;
imshow(matrix);
lacunarity = get_lacunarity(matrix);


end

