function [ av_stats ] = GLCM( image )


%% Compute Gray level co-occurrence matrix and probabilities
g_image = mat2gray(image);
g_image(isnan(image)) = NaN;

stats = zeros(5,1);

% Write small function to avoid writing 
glcm = graycomatrix(g_image, 'Symmetric', true, 'Offset', [0, 1]);
stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
glcm = glcm./sum(glcm(:));
stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));

glcm = graycomatrix(g_image, 'Symmetric', true, 'Offset', [-1, 1]);
stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
glcm = glcm./sum(glcm(:));
stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));

glcm = graycomatrix(g_image, 'Symmetric', true, 'Offset', [-1, 0]);
stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
glcm = glcm./sum(glcm(:));
stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));

glcm = graycomatrix(g_image, 'Symmetric', true, 'Offset', [-1, -1]);
stats(1:4) = stats(1:4) + cell2mat(struct2cell(graycoprops(glcm, 'all')));
glcm = glcm./sum(glcm(:));
stats(5) = sum(-log(glcm(:)+1e-16).*glcm(:));

stats = stats * .25;

av_stats = struct('Constrast', stats(1), 'Correlation', stats(2), 'Energy', stats(3), 'Homogeneity',stats(4), 'Entropy',stats(5))

end

