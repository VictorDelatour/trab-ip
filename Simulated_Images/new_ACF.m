function [distance, ratio ] = new_ACF( image )

[nx, ny] = size(image);
% distance = 0:nx-1;
% ratio = zeros(nx,1);

acf = zeros(nx, ny);

for dx = 0:nx-1
    for dy = 0:ny-1
        card = 1/( (nx-dx)*(ny-dy) );
        idx = 1:(nx-dx);
        idy = 1:(ny-dy);
        
        acf(dx+1, dy+1) = card * sum(sum(image(idx, idy).*image(idx+dx, idy+dy)));
        
    end
end

acf = acf / sum(acf(:));

figure(1)
imshow(mat2gray(acf));
title('Autocorrelation matrix');
axis equal;

%% Plot partial autocorrelation functions
nel = min(round(.75 * min(nx, ny)),50);
acf_x = sum(acf, 1);
acf_y = sum(acf, 2)';

figure(2)
subplot(2,1,1)
plot(1:nel, acf_x(1:nel), 1:nel, acf_y(1:nel));
title('Partial autocorrelation functions');
legend('a_x', 'a_y', 'Location', 'Best');
legend boxoff
xlabel('Distance'); ylabel('Autocorrelation');


ratio = acf_x(1:nel) ./ acf_y(1:nel);

subplot(2,1,2)
plot(1:nel, ratio(1:nel));
hold on
plot(1:nel, ones(nel,1)*mean(ratio(1:nel)), '--r');
hold off
title('Ratio of partial autocorrelation functions');
legend('Ratio', '\mu', 'Location', 'Best');
legend boxoff
xlabel('Distance'); ylabel('Ratio');




end

