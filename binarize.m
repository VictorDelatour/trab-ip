function [ bin_image ] = binarize(image)

filter = fspecial('gaussian', [10, 10], 21);
filtered_image = imfilter(image, filter, 'replicate');

bin_image = image-filtered_image;
bin_image = bin_image + .5;
bin_image(bin_image > .5) = 1;
bin_image(bin_image <=.5) = 0;

end

