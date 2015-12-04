function plot_density_map( density_map, limits )

    density_map = density_map(limits(1):limits(2), limits(3):limits(4));
    [~, index] = max(density_map(:));
    [maxRow, maxCol] = ind2sub(size(density_map), index);

%%
    nlines = 10;

    imshow(mat2gray(density_map)); 
    hold on; 
    [~,h] = contour(density_map, nlines); 
    plot(maxCol, maxRow,'r.','MarkerSize',20); 
    hold off


end

