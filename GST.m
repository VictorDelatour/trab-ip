function [ V, D ] = GST( image )

[nrow, ncol] = size(image);

gradx = zeros(size(image));
grady = gradx;

image = roi_left;

id = find(~isnan(image));


%% Delete indices on the borders

id = id(mod(id, nrow) > 1);
id = id( (id > nrow) & (id <= nrow*(ncol-1)) );
%% Delete indices with NaNs as neighbors

id = id(~isnan(image(id+1)) & ~isnan(image(id-1)));
id = id(~isnan(image(id+nrow)) & ~isnan(image(id+nrow)));

%% Safe to compute gradient:
image = mat2gray(image);
gradx = .5 * (image(id+nrow) - image(id-nrow));
grady = .5 * (image(id+1) - image(id-1));

GST = zeros(2,2);

GST(1,1) = sum(sum(gradx.*gradx));
GST(2,1) = sum(sum(grady.*gradx));
GST(1,2) = GST(2,1);
GST(2,2) = sum(sum(grady.*grady));

[V,D] = eig(GST);



end

