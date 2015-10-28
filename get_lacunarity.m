function [ lacunarity ] = get_lacunarity( image )

    [nrow, ncol] = size(image);
    
    max_bloc_size = ceil(sqrt(.5*(nrow+ncol)));
    
    bin_image = binarize(image);
    
    data = zeros(max_bloc_size, max_bloc_size.^2 + 1); % +1 for 0 nnz in square
    %%
    
    for j = 1:ncol
        for i = 1:nrow
            
            loc_max_bloc_size = min(min(ncol-j+1, nrow-i+1), max_bloc_size);
            
            for len = 1:loc_max_bloc_size
                nnz_sq = nnz(bin_image(i:(i+len-1), j:(j+len-1)));
                data(len, nnz_sq + 1) = data(len, nnz_sq + 1) + 1;
            end
            
        end
    end
    
    %%
    vlacunarity = zeros(max_bloc_size, 2);
    
    for len = 1:max_bloc_size
         
        % Gliding box lacunarity
        data(len, 1:len^2+1) = data(len, 1:len^2+1)/sum(data(len, 1:len^2+1));
        vlacunarity(len,1) = sum(((0:len^2).^2).*data(len, 1:len^2+1)) / sum( (0:len^2).*data(len, 1:len^2+1)).^2;
        
        % Complementary lacunarity
        data(len, 1:len^2+1) = flip(data(len, 1:len^2+1));
        vlacunarity(len,2) = sum(((0:len^2).^2).*data(len, 1:len^2+1)) / sum( (0:len^2).*data(len, 1:len^2+1)).^2;
        
    end
    
    % Get normalized lacunarity
    lacunarity = 2 - sum(1./vlacunarity,2);

end

