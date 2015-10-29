function [ lacunarity ] = get_lacunarity( image )

    [nrow, ncol] = size(image);
    
    max_bloc_size = ceil(sqrt(.5*(nrow+ncol)));
    
    bin_image = binarize(image);
    
    data = cell(max_bloc_size,1);
    for i = 1:max_bloc_size
        data{i} = zeros(1,i.^2+1);
    end
    
    %%
    
    for j = 1:ncol
        for i = 1:nrow
            
            loc_max_bloc_size = min(min(ncol-j+1, nrow-i+1), max_bloc_size);
            
            for len = 1:loc_max_bloc_size
                % What should be done if there are some NaNs in the region?
                if sum(sum(isnan(bin_image(i:(i+len-1), j:(j+len-1))))) == 0
                    nnz_sq = nnz(bin_image(i:(i+len-1), j:(j+len-1)));
                    data{len}(nnz_sq + 1) = data{len}(nnz_sq + 1) + 1;
                end
            end
            
        end
    end
    
    %%
    vlacunarity = zeros(max_bloc_size, 2);
    
    for len = 1:max_bloc_size
         
        % Gliding box lacunarity
        data{len} = data{len}/sum(data{len});
        vlacunarity(len,1) = sum(((0:len^2).^2).*data{len}) / sum( (0:len^2).*data{len}).^2;
        
        % Complementary lacunarity
        data{len} = flip(data{len});
        vlacunarity(len,2) = sum(((0:len^2).^2).*data{len}) / sum( (0:len^2).*data{len}).^2;
        
    end
    
    % Get normalized lacunarity
    lacunarity = 2 - sum(1./vlacunarity,2);

end

