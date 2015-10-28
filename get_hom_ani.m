function [homogeneity, anisotropy] = get_hom_ani(image, ind, grad_x, grad_y)

    [nrow, ncol] = size(image);
    homogeneity = zeros(2,1);
    anisotropy = zeros(2,1);
    p_roi = 1/numel(ind);
    
    %% Compute homogeneity measure
    homogeneity(1) = std(image(ind));
    homogeneity(2) = sqrt(p_roi*sum( (image(ind) - .25*(image(ind+1) + image(ind-1) + image(ind+nrow) + image(ind-nrow))).^2));

    %% Compute anisotropy
    
    v = zeros(2,1);
    v(1) = p_roi * sum(grad_x(ind));
    v(2) = p_roi * sum(grad_y(ind));
    %% Global
    
    anisotropy(1) = sum(abs(atan2(v(2),v(1))-atan2(grad_y(ind), grad_x(ind))));
    anisotropy(1) = anisotropy(1)/numel(ind);
    
%     for i = 1:numel(ind)
%         anisotropy(1) = anisotropy(1) + abs(atan2(v(2), v(1))-atan2(grad_y(ind(i)), grad_x(ind(i))));
%     end
    
    %% Local
    p8 = 1/8;
        
    grad_x = grad_x(2:end-1,2:end-1);
    grad_y = grad_y(2:end-1,2:end-1);
    
    ind_gx = get_indices(grad_x); 
    ind_gy = get_indices(grad_y);
    ind2 = intersect(ind_gx, ind_gy); % Clean way of doing it
    
    nrow = size(image,1)-2; % Actual #rows of image(2:end-1,2:end-1)
    cross = [1 -1 nrow -nrow];
   
    %%
    v_loc = zeros(2,1);
    for i = 1:numel(ind2)
        
        v_loc(1) = p8 * sum( grad_x(ind2(i)+cross) - grad_x(ind2(i)) );
        v_loc(2) = p8 * sum( grad_y(ind2(i)+cross) - grad_y(ind2(i)) );
        anisotropy(2) = anisotropy(2) + abs(atan2(v(2), v(1)) - atan2(v_loc(2), v_loc(1)));
    end
    
    %%
    anisotropy(2) = anisotropy(2)/numel(ind2);

    
end