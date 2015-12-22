function [ lacunarity ] = new_lacunarity( image )

    [nrow, ncol] = size(image);
    
    nboxes = floor(min(log2(nrow), log2(ncol)));
    
    data = cell(nboxes+1,1);
    p = 2.^(0:nboxes);
    for i = 1:nboxes+1
        data{i} = zeros(1,p(i).^2+1);
    end
    
    lacunarity = struct;
    
    %%
    
    for j = 1:ncol
        for i = 1:nrow
            loc_nboxes = min(floor(log2(min(ncol-j+1, nrow-i+1))), nboxes); 
            
            for ind = 0:loc_nboxes
                nnz_sq = nnz(image(i:(i+2^ind-1), j:(j+2^ind-1)));
                data{ind+1}(nnz_sq + 1) = data{ind+1}(nnz_sq + 1) + 1;
            end
            
        end
    end
    
    %%
    
    vlacunarity = zeros(nboxes + 1, 2);
    
    for len = 0:nboxes
         
        % Gliding box lacunarity
        data{len + 1} = data{len + 1}/sum(data{len + 1});
        vlacunarity(len + 1, 1) = sum( ((0:(2^len)^2).^2).*data{len+1} ) / sum((0:(2^len)^2).*data{len+1}).^2;
        
        % Complementary lacunarity
        data{len + 1} = flip(data{len + 1});
        vlacunarity(len + 1, 2) = sum( ((0:(2^len)^2).^2).*data{len+1} ) / sum((0:(2^len)^2).*data{len+1}).^2;
        
    end
    
    lacunarity.glidingbox = vlacunarity(:,1);
    lacunarity.complementary = vlacunarity(:,2);
    
    % Get normalized lacunarity
    lacunarity.normalized = 2 - sum(1./vlacunarity,2);
    
end

