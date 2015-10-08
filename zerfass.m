function [ homogeneity, anisotropy ] = zerfass( image )

homogeneity = zeros(2,1);
anisotropy = zeros(2,1);

[nx, ny] = size(image);
idx = 2:nx-1;
idy = 2:ny-1;
p_voi = 1/(numel(idx)*numel(idy));

%% Compute global and local homogeneity

homogeneity(1) = std2(image);
homogeneity(2) = sqrt(p_voi*sum(sum( (image(idx,idy)-.25*(image(idx+1, idy) + image(idx-1, idy) + image(idx, idy+1) + image(idx, idy-1))).^2)));

%% Compute anisotropy

% Compute gradient

grad_x = .5*(image(idx+1, idy) - image(idx-1, idy));
grad_y = .5*(image(idx, idy+1) - image(idx, idy-1));

v = zeros(2,1);
v(1) = p_voi*sum(sum(grad_x));
v(2) = p_voi*sum(sum(grad_y));
p8 = 1/8;
id3 = -1:1;

%% Global anisotropy
for i = idx-1
    for j = idy-1
        anisotropy(1) = anisotropy(1) + abs(atan2(v(2), v(1)) - atan2(grad_y(i,j), grad_x(i,j)));
    end
end

%% Local anisotropy
for i = idx(2:end-1)-1
    for j = idy(2:end-1)-1
        
        v_loc(1) = p8 * (sum(sum(grad_x(i+id3, j+id3)))-grad_x(i,j));
        v_loc(2) = p8 * (sum(sum(grad_y(i+id3, j+id3)))-grad_y(i,j));
        anisotropy(2) = anisotropy(2) + abs(atan2(v(2), v(1)) - atan2(v_loc(2), v_loc(1)));
    end
end

%% Normalization
anisotropy = anisotropy * p_voi;


end

