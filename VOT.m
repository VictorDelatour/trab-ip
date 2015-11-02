function [FD, S_tr, S_td] = VOT( image, radius )

[nrow, ncol] = size(image);

r2 = radius^2;

n_angle = 10;
f_angle = (n_angle-1)/360;

ind = find(~isnan(image));

[I, J] = ind2sub([nrow, ncol], ind);

mean_matrix = zeros(n_angle, 2*radius-1);
var_matrix = zeros(n_angle, 2*radius-1);

data = cell(n_angle, 2*radius-1);
nCells = numel(data);
index = zeros(n_angle, 2*radius-1);

% init_cell
for i = 1:nCells
    data{i} = -ones(1,1);
end

%% Compute mean

for idx = 1:numel(I)
    i = I(idx); j = J(idx);
%     fprintf('%i of %i\n', idx, numel(I));
    
    loc_ind = ind( (I-i).^2+(J-j).^2 < r2 & ~(I==i & J == j));
    [loc_I, loc_J] = ind2sub( size(image), loc_ind);
    
    for loc_idx = 1:numel(loc_ind)
        
        loc_i = loc_I(loc_idx); loc_j = loc_J(loc_idx);
        loc_diff = abs(image(loc_i, loc_j)-image(loc_ind)); % Get gray value difference
        loc_dist = sqrt( (loc_I - loc_i).^2 + (loc_J - loc_j).^2); % Get distance
        
        loc_ang = atan2d(loc_J-j, loc_I-i)+270; % Compute angle
        loc_ang(loc_ang>=360) = loc_ang(loc_ang>=360)-360;
        loc_ang = round(f_angle*loc_ang)+1;
                
        sub_ind = loc_dist > 0; % & loc_J >= loc_j & (loc_J ~= loc_j | loc_I >= loc_i);
        
        loc_ang = loc_ang(sub_ind);
        loc_diff = loc_diff(sub_ind);
        loc_dist = round(loc_dist(sub_ind));
        
        % This can (AND MUST!) be done in a matricial fashion
        for k = 1:numel(loc_diff)
            ap = loc_ang(k);
            dp = loc_dist(k);
            
            mean_matrix(ap, dp) = mean_matrix(ap, dp) + loc_diff(k);
            index(ap, dp) = index(ap, dp) + 1;
        end
        
    end
end

mean_matrix(mean_matrix>0) = mean_matrix(mean_matrix>0)./index(mean_matrix>0);
        
%% Compute variance

for idx = 1:numel(I)
    i = I(idx); j = J(idx);
%     fprintf('%i of %i\n', idx, numel(I));
    
    loc_ind = ind( (I-i).^2+(J-j).^2 < r2 & ~(I==i & J == j));
    [loc_I, loc_J] = ind2sub( size(image), loc_ind);
    
    for loc_idx = 1:numel(loc_ind)
        
        loc_i = loc_I(loc_idx); loc_j = loc_J(loc_idx);
        loc_diff = abs(image(loc_i, loc_j)-image(loc_ind)); % Get gray value difference
        loc_dist = sqrt( (loc_I - loc_i).^2 + (loc_J - loc_j).^2);
        
        loc_ang = atan2d(loc_J-j, loc_I-i)+270; % Compute angle
        loc_ang(loc_ang>=360) = loc_ang(loc_ang>=360)-360;
        loc_ang = round(f_angle*loc_ang)+1;
        
        sub_ind = loc_dist > 0;% & loc_J >= loc_j & (loc_J ~= loc_j | loc_I >= loc_i);
        
        loc_ang = loc_ang(sub_ind);
        loc_diff = loc_diff(sub_ind);
        loc_dist = round(loc_dist(sub_ind));
        
        % This can (AND MUST!) be done in a matricial fashion
        for k = 1:numel(loc_diff)
            ap = loc_ang(k);
            dp = loc_dist(k);
            
            var_matrix(ap, dp) = var_matrix(ap, dp) + (loc_diff(k)-mean_matrix(ap,dp)).^2;
        end
        
    end
end

%%
var_matrix(mean_matrix>0) = var_matrix(mean_matrix>0)./index(mean_matrix>0);
        
%% Compute variance and Hurst coefficients

% n_scale = (2*radius-1)-4;

v_dist = 1:(2*radius-1);
% v_ang = ((1:n_angle)./f_angle)./180*pi;

% hurst_var = zeros(n_angle, n_scale);

%%
% for ap = 1:n_angle
%     % Get coef by linear regression for each loglog data
%     hurst_var(ap, :) = get_hurst_coef(v_dist, var_matrix(ap,:), 'VOT');
% end

%%
hurst_coef = zeros(n_angle,1);

for ap = 1:n_angle
    ap_ind = true(1,2*radius-1);
    ap_ind(1:4) = 0; % Remove four first distances
    
        
    pfit = polyfit(log(v_dist(ap_ind)), log(var_matrix(ap, ap_ind)), 1);
    pval = polyval(pfit, log(v_dist(ap_ind)));
    
    resid = log(var_matrix(ap, ap_ind))-pval;
    SSresid = sum(resid.^2);
    SStotal = (numel(resid)-1) * var(log(var_matrix(ap, ap_ind)));
    rsq = 1- SSresid/SStotal;
    rsq_adj = 1-SSresid/SStotal * (numel(resid)-1)/(numel(resid)-numel(pfit));
    
%     figure(1);
%     plot(log(v_dist(ap_ind)), log(var_matrix(ap, ap_ind)), 'o', log(v_dist(ap_ind)), pval, '-r' );
%     title(sprintf('Linear fit R^2=%.3f\n', rsq));
%     waitforbuttonpress;
    
    hurst_coef(ap) = pfit(1);

    
end



%%

[FD, S_tr, S_td] = get_OT_vars(hurst_coef, 'HOT');

% [FD_VOT, S_tr_VOT, S_td_VOT] = get_OT_vars(hurst_var, 'VOT');


end