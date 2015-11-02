function get_local_GLCM( image )

mask_size = 7;
len = .5*(mask_size - mod(7,2));

[nrow, ncol] = size(image);

index = 1:nrow*ncol;
[I, J] = ind2sub(size(image), index(~isnan(image(:))) );

contrast_image = nan(size(image));
correlation_image = nan(size(image));
energy_image = nan(size(image));
homogeneity_image = nan(size(image));
entropy_image = nan(size(image));

%%

for p = 1:numel(I)
    stats = zeros(5,1);
    
    loc_image = image(max(I(p)-len,1):min(I(p)+len,nrow), max(J(p)-len,1):min(J(p)+len,ncol));
    
    glcm = graycomatrix(loc_image, 'Symmetric', true, 'Offset', [0, 1]);
    stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
    glcm = glcm./sum(glcm(:));
    stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));
    
    glcm = graycomatrix(loc_image, 'Symmetric', true, 'Offset', [-1, 1]);
    stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
    glcm = glcm./sum(glcm(:));
    stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));
    
    glcm = graycomatrix(loc_image, 'Symmetric', true, 'Offset', [-1, 0]);
    stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
    glcm = glcm./sum(glcm(:));
    stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));
    
    glcm = graycomatrix(loc_image, 'Symmetric', true, 'Offset', [-1, -1]);
    stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
    glcm = glcm./sum(glcm(:));
    stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));
    
    stats = stats * .25;
    
    contrast_image(I(p), J(p)) = stats(1);
    correlation_image(I(p), J(p)) = stats(2);
    energy_image(I(p), J(p)) = stats(3);
    homogeneity_image(I(p), J(p)) = stats(4);
    entropy_image(I(p), J(p)) = stats(5);
       
end

%%

figure(1)
imshow(mat2gray(contrast_image));
title('Contrast');
waitforbuttonpress;
close(1);

figure(1)
imshow(mat2gray(correlation_image));
title('Correlation');
waitforbuttonpress;
close(1);

figure(1)
imshow(mat2gray(energy_image));
title('Energy');
waitforbuttonpress;
close(1);

figure(1)
imshow(mat2gray(homogeneity_image));
title('Homogeneity');
waitforbuttonpress;
close(1);

figure(1)
imshow(mat2gray(entropy_image));
title('Entropy');
waitforbuttonpress;
close(1);



end

