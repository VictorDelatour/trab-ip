function [ av_stats ] = get_stats( image )

    g_image = mat2gray(image);
    g_image(isnan(image)) = NaN;

    %% Compute Gray level co-occurrence matrix and probabilities
    
    ind = get_indices(g_image);
    
    stats = get_average_glcm(g_image);
    
    [grad_x, grad_y] = get_gradient(g_image, ind);
    [homogeneity, anistropy] = get_hom_ani(g_image, ind, grad_x, grad_y);
    
    
%     av_stats = struct('Constrast', stats(1), 'Correlation', stats(2), 'Energy', stats(3), 'Homogeneity',stats(4), 'Entropy',stats(5))

end

function [ind] = get_indices(image)

    [nrow, ncol] = size(image);
    ind = find(~isnan(image));

    %% Delete indices on the borders

    ind = ind(mod(ind, nrow) > 1);
    ind = ind( (ind > nrow) & (ind <= nrow*(ncol-1)) );
    
    %% Delete indices with NaNs as neighbors

    ind = ind(~isnan(image(ind+1)) & ~isnan(image(ind-1)));
    ind = ind(~isnan(image(ind+nrow)) & ~isnan(image(ind+nrow)));

end

function [stats] = get_average_glcm(image)

    stats = get_glcm(image, [0,1]) + get_glcm(image, [-1,1]);
    stats = stats + get_glcm(image, [-1,0]) + get_glcm(image, [-1,-1]);
    stats = stats * .25;

end

function [stats] = get_glcm(image, offset)
    
    stats = zeros(5,1);
    
    glcm = graycomatrix(image, 'Symmetric', true, 'Offset', offset);
    stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
    glcm = glcm./sum(glcm(:));
    stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));

end

function[grad_x, grad_y] = get_gradient(image, ind)
    
    [nrow, ncol] = size(image);

    grad_x = NaN(nrow, ncol);
    grad_y = NaN(nrow, ncol);

    %% Safe to compute gradient:
    
    grad_x(ind) = .5 * (image(ind+nrow) - image(ind-nrow));
    grad_y(ind) = .5 * (image(ind+1) - image(ind-1));
    
end

function [ V, D ] = get_gst( grad_x, grad_y )

    gst = zeros(2,2);

    gst(1,1) = sum(sum(grad_x.*grad_x));
    gst(2,1) = sum(sum(grad_y.*grad_x));
    gst(1,2) = gst(2,1);
    gst(2,2) = sum(sum(grad_y.*grad_y));

    [V,D] = eig(gst);

end

function [homogeneity, anistropy] = get_hom_ani(image, ind, grad_x, grad_y)

    [nrow, ncol] = size(image);
    homogeneity = zeros(2,1);
    anisotropy = zeros(2,1);
    p_roi = 1/numel(ind);
    
    %% Compute homogeneity measure
    homogeneity(1) = std(image(ind));
    homogeneity(2) = sqrt(p_roi*sum(image(ind) - .25*(image(ind+1) + image(ind-1) + image(ind+nrow) + image(ind+ncol))));

    %% Compute anisotropy
    
    v = zeros(2,1);
    v(1) = p_roi * sum(grad_x);
    v(2) = p_roi * sum(grad_y);
    
    %% Global
    
    for i = ind
        anisotropy(1) = anisotropy(1) + abs(atan2(v(2), v(1))-atan2(grad_y(i), grad_x(i)));
    end
    
    %% Local
    p8 = 1/8;
    
    % The region used to compute the local anisotropy is similar to the one
    % we'd use if we were doing a 2nd order derivative of the gray-level
    % image
    
    ind2 = get_indices(image(2:end-1, 2:end-1)); 
    cross = [1 -1 nrow -nrow];
    v_loc = zeros(2,1);
    
    for i = ind2
        v_loc(1) = p8 * sum(grad_x(i+cross)-grad_x(i));
        v_loc(2) = p8 * sum(grad_y(i+cross)-grad_y(i));
        anisotropy(2) = anisotropy(2) + abs(atan2(v(2), v(1)) - atan2(v_loc(2), v_loc(1)));
    end

    
end


