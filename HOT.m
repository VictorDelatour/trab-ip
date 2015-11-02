function [FD, S_tr, S_td] = HOT(image, radius)

[nrow, ncol] = size(image);

r2 = radius^2;

n_angle = 10;
f_angle = (n_angle-1)/360;

ind = find(~isnan(image));

[I, J] = ind2sub([nrow, ncol], ind);

max_matrix = -ones(n_angle, 2*radius-1);

%% Compute HOT image

for idx = 1:numel(I)
    i = I(idx); j = J(idx);
%     fprintf('%i of %i\n', idx, numel(I));
    
    % Get all indices in search region
    loc_ind = ind( (I-i).^2+(J-j).^2 < r2 & ~(I==i & J == j));
    [loc_I, loc_J] = ind2sub( size(image), loc_ind);
    
    for loc_idx = 1:numel(loc_ind)
        
        loc_i = loc_I(loc_idx); loc_j = loc_J(loc_idx);
        loc_diff = abs(image(loc_i, loc_j)-image(loc_ind)); % Get gray value difference
        loc_dist = sqrt( (loc_I - loc_i).^2 + (loc_J - loc_j).^2);
        
        loc_ang = atan2d(loc_J-j, loc_I-i)+270; % Compute angle
        loc_ang(loc_ang>=360) = loc_ang(loc_ang>=360)-360;
        loc_ang = round(f_angle*loc_ang)+1;
        
        sub_ind = loc_dist > 0;
        
        loc_ang = loc_ang(sub_ind);
        loc_diff = loc_diff(sub_ind);
        loc_dist = round(loc_dist(sub_ind));
        
        max_matrix(loc_ang + (loc_dist-1)*n_angle) = max(max_matrix(loc_ang + (loc_dist-1)*n_angle), loc_diff);
        
    end
    
end

%% Compute hurst coefficients by linear regression

max_matrix = max_matrix/std2(image(ind));

%%
xv = 1:(2*radius);
hurst_coef = zeros(n_angle,1);

for ap = 1:n_angle
    
    ap_ind = max_matrix(ap,:)>0;
    ap_ind(1:4) = 0; % Remove four first distances
    
    if max(ap_ind) > 0
        
        pfit = polyfit(log(xv(ap_ind)), log(max_matrix(ap, ap_ind)), 1);
        pval = polyval(pfit, log(xv(ap_ind)));
        
        resid = log(max_matrix(ap, ap_ind))-pval;
        SSresid = sum(resid.^2);
        SStotal = (numel(resid)-1) * var(log(max_matrix(ap, ap_ind)));
        rsq = 1- SSresid/SStotal;
        rsq_adj = 1-SSresid/SStotal * (numel(resid)-1)/(numel(resid)-numel(pfit));
        
%         figure(1);
%         plot(log(xv(ap_ind)), log(max_matrix(ap, ap_ind)), 'o', log(xv(ap_ind)), pval, '-r' );
%         title(sprintf('Linear fit R^2=%.3f\n', rsq));
%         waitforbuttonpress;
        
        hurst_coef(ap) = pfit(1);
    else
        hurst_coef(ap) = NaN;
    end
    
end

%%

if mean(hurst_coef)>0 && sum(hurst_coef>0)/numel(hurst_coef) > .5
    hurst_coef(hurst_coef<0) = 1e-10;
    [FD, S_tr, S_td] = get_OT_vars(hurst_coef, 'HOT');
else
    FD = NaN;
    S_tr = NaN;
    S_td = NaN;
end

end

