function HOT(image, radius )

[nrow, ncol] = size(image);

r2 = radius^2;

n_angle = 10;
f_angle = n_angle/360;

ind = find(~isnan(image));

[I, J] = ind2sub([nrow, ncol], ind);

data = -ones(n_angle, 2*radius);
data2 = -ones(n_angle, 2*radius);

%% Compute HOT image

for idx = 1:numel(I)
    i = I(idx); j = J(idx);
    
    % Get all indices in search region
    loc_ind = ind( (I-i).^2+(J-j).^2 < r2 & ~(I==i & J == j));
    [loc_I, loc_J] = ind2sub( size(image), loc_ind); 
    
    for loc_idx = 1:numel(loc_ind)
       
       loc_i = loc_I(loc_idx); loc_j = loc_J(loc_idx);
       loc_diff = abs(image(loc_i, loc_j)-image(loc_ind)); % Get gray value difference
       loc_dist = sqrt( (loc_I - loc_i).^2 + (loc_J - loc_j).^2); 
       loc_ang = round(f_angle*(atan2d(loc_J-j, loc_I-i)+270))+1;
       loc_ang(loc_ang > n_angle) = 1;
       
       loc_ang = loc_ang(loc_dist>0);
       loc_diff = loc_diff(loc_dist>0);
       loc_dist = round(loc_dist(loc_dist>0));
       
       for k = 1:numel(loc_diff)
           data(loc_ang(k), loc_dist(k)) = max(data(loc_ang(k), loc_dist(k)), loc_diff(k));
       end

       data2(loc_ang + (loc_dist-1)*n_angle) = max(data2(loc_ang + (loc_dist-1)*n_angle), loc_diff);
       
    end
    
end

%% Compute hurst coefficients by linear regression

data = data/std2(image(ind));

%%
xv = 1:(2*radius);
hurst_coef = zeros(n_angle,1);

for ap = 1:n_angle
    
    ap_ind = data(ap,:)>0;
    ap_ind(1:4) = 0; % Remove four first distances
%     ap_ind(radius+1:end) = 0;
    
    if max(ap_ind) > 0 
        
        pfit = polyfit(log(xv(ap_ind)), log(data(ap, ap_ind)), 1);
        pval = polyval(pfit, log(xv(ap_ind)));

        resid = log(data(ap, ap_ind))-pval;
        SSresid = sum(resid.^2);
        SStotal = (numel(resid)-1) * var(log(data(ap, ap_ind)));
        rsq = 1- SSresid/SStotal;
        rsq_adj = 1-SSresid/SStotal * (numel(resid)-1)/(numel(resid)-numel(pfit));

        figure(1);
        plot(log(xv(ap_ind)), log(data(ap, ap_ind)), 'o', log(xv(ap_ind)), pval, '-r' );
        title(sprintf('Linear fit R^2=%.3f\n', rsq));
        waitforbuttonpress;

        hurst_coef(ap) = pfit(1);
    else
        hurst_coef(ap) = NaN;
    end
    
end

% v_angle = ((1:n_angle)./f_angle)./180*pi;
% 
% figure(1);
% polar([v_angle, v_angle(1)], [hurst_coef; hurst_coef(1)]');
% waitforbuttonpress
   

end

