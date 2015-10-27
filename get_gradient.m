function[grad_x, grad_y] = get_gradient(image, ind)
    
    [nrow, ncol] = size(image);

    grad_x = NaN(nrow, ncol);
    grad_y = NaN(nrow, ncol);

    %% Safe to compute gradient:
    
    grad_x(ind) = .5 * (image(ind+nrow) - image(ind-nrow));
    grad_y(ind) = .5 * (image(ind+1) - image(ind-1));
    
end