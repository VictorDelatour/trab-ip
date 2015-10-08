function [distance, ratio ] = ACF( image )

[nx, ny] = size(image);
distance = 0:nx-1;
ratio = zeros(nx,1);

% Loop on all distances
for d = 0:nx-1
    sx = 0;
    sy = 0;
    
    for dy = 0:ny-1
        % Compute a(d_x, d_y) with fixed d_x
        card = 1/( (nx-d)*(ny-dy) );
        idx = 1:(nx-d);
        idy = 1:(ny-dy);
        sx = sx + card * sum(sum(image(idx, idy).*image(idx+d, idy+dy)));
    end
    
    for dx = 0:nx-1
        % Compute a(d_x, d_y) with fixed d_y
        card = 1/( (nx-dx)*(ny-d) );
        idx = 1:(nx-dx);
        idy = 1:(ny-d);
        sy = sy + card * sum(sum(image(idx, idy).*image(idx+dx, idy+d)));
    end
    
    ratio(d+1) = sx/sy;
    
end


end

