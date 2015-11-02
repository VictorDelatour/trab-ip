function [distance, ratio] = get_ACF( image )
%%
[nrow, ncol] = size(image);
dmax = min(nrow, ncol);
distance = 0:dmax-1;
ratio = zeros(dmax,1);

index = 1:nrow*ncol;
index = index(~isnan(image));
num_el = numel(image);

% Loop on all distances
for d = 0:dmax-1
    sx = 0;
    sy = 0;
    
    for dy = 0:ncol-1
        % Get indices such for summation
        ind = index(index + d + dy*nrow <= num_el);
        ind = ind(~isnan(image(ind+d + dy*nrow)));
        
        % Compute a(d_x, d_y) with fixed d_x
        card = 1/max(numel(ind),1);
        sx = sx + card * sum(image(ind).*image(ind + d + dy*nrow));
    end
    
    for dx = 0:nrow-1
        % Get indices such for summation
        ind = index(index + dx + d*nrow <= num_el);
        ind = ind(~isnan(image(ind+dx + d*nrow)));
        
        % Compute a(d_x, d_y) with fixed d_y
        card = 1/max(numel(ind),1);
        sy = sy + card * sum(image(ind).*image(ind + dx + d*nrow));
    end
    
    ratio(d+1) = sx/sy;
    
end


end

