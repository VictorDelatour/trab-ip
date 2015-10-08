function [ R ] = HOT(image, num_dist, num_ang )

[nrow, ncol] = size(image);
ang = (360./num_ang).*(0:num_ang-1); % get angle vector
dist = 4 + (0:num_dist-1); % get dist vector

vec_ang = [cosd(ang);sind(ang)];

for x = 1:nrow
    for y = 1:ncol
        
        
        
        
        
        loc_ang
        for theta = ang
            for d = dist
                
            end
        end
    end
end



end

