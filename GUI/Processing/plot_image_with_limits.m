function plot_image_with_limits( hObject, image, mask, limits )

image(mask==0) = 0;
rowsum = sum(image>0, 2);
top = find(rowsum>0, 1);

colsum = sum(image>0, 1);
left = find(colsum>0, 1);
right = find(colsum>0, 1, 'last');

image = image(top:end, left:right);
limits = limits - left + 1;


% Set upper plot in GUI as current axes
axes(hObject);
imshow(image)
hold on
plot(limits(2)*ones(2,1), [1, size(image,1)], '-r')
plot(limits(1)*ones(2,1), [1, size(image,1)], '-r')
plot((limits(1) + round(diff(limits)*.25))*ones(2,1), [1, size(image,1)], '--r')
hold off

end

