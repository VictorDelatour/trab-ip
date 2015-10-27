function [ind] = get_indices(image)

    [nrow, ncol] = size(image);
    ind = find(~isnan(image));

    %% Delete indices on the borders

    ind = ind(mod(ind, nrow) > 1);
    ind = ind( (ind > nrow) & (ind <= nrow*(ncol-1)) );
    
    %% Delete indices with NaNs as neighbors

    ind = ind(~isnan(image(ind+1)) & ~isnan(image(ind-1)));
    ind = ind(~isnan(image(ind+nrow)) & ~isnan(image(ind-nrow)));

end