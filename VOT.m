function  VOT( image, radius )

[nrow, ncol] = size(image);

r2 = radius^2;

n_angle = 10;
f_angle = n_angle/360;

ind = find(~isnan(image));

[I, J] = ind2sub([nrow, ncol], ind);

data = cell(n_angle, 2*radius);
nCells = numel(data);
index = ones(n_angle, 2*radius);

% init_cell
for i = 1:nCells
    data{i} = -ones(1,1);
end

%% Compute matrix

for idx = 1:numel(I)
    i = I(idx); j = J(idx);
    fprintf('%i of %i\n', idx, numel(I));
    
    loc_ind = ind( (I-i).^2+(J-j).^2 < r2 & ~(I==i & J == j));
    [loc_I, loc_J] = ind2sub( size(image), loc_ind);
    
    for loc_idx = 1:numel(loc_ind)
        
        loc_i = loc_I(loc_idx); loc_j = loc_J(loc_idx);
        loc_diff = abs(image(loc_i, loc_j)-image(loc_ind)); % Get gray value difference
        loc_dist = sqrt( (loc_I - loc_i).^2 + (loc_J - loc_j).^2);
        loc_ang = round(f_angle*(atan2d(loc_J-j, loc_I-i)+270))+1;
        loc_ang(loc_ang > n_angle) = 1;
        
        sub_ind = loc_dist > 0 & loc_J >= loc_j & (loc_J ~= loc_j | loc_I >= loc_i);
        
        loc_ang = loc_ang(sub_ind);
        loc_diff = loc_diff(sub_ind);
        loc_dist = round(loc_dist(sub_ind));
        
        for k = 1:numel(loc_diff)
            ap = loc_ang(k);
            dp = loc_dist(k);
            if numel(data{ap, dp}) < index(ap, dp)+1
                temp = data{ap, dp};
                data{ap, dp} = -ones(numel(temp)+10,1);
                data{ap, dp}(1:numel(temp))=temp;
            end
            data{ap, dp}(index(ap, dp)) = loc_diff(k);
            index(ap, dp) = index(ap, dp) + 1;
        end
        
    end
end
        

%% Compute variance and Hurst coefficients

variance = zeros(n_angle, 2*radius);

n_scale = 2*radius-4;

v_dist = 1:2*radius;
v_ang = ((1:n_angle)./f_angle)./180*pi;

hurst_var = zeros(n_angle, n_scale);




%%
for ap = 1:n_angle
    
    % Compute variance for each angular "slice"
    for dp = 1:2*radius
        data{ap, dp} = data{ap, dp}(data{ap, dp}~=-1);
        if numel(data{ap, dp})~=0
            variance(ap, dp) = var(data{ap, dp});
        else
            variance(ap, dp) = NaN;
        end
    end
    
    % Get coef by linear regression for each loglog data
    hurst_var(ap, :) = get_hurst_coef(v_dist, variance(ap,:), 'VOT');
    
    % Compute R^2 for linear regression
%     resid = log(max_diff(ap, ind))-pval;
%     SSresid = sum(resid.^2);
%     SStotal = (numel(resid)-1) * var(log(max_diff(ap, ind)));
%     rsq = 1- SSresid/SStotal;
%     rsq_adj = 1-SSresid/SStotal * (numel(resid)-1)/(numel(resid)-numel(pfit));
    
%     if rsq_adj > .95
%         hurst_dif(ap) = pfit(1);
%     else
%         hurst_dif(ap) = NaN;
%     end
    
    
end

%%

[FD_VOT, S_tr_VOT, S_td_VOT] = get_OT_vars(hurst_var, 'VOT');


end