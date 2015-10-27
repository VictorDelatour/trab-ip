function [ FD, S_tr, S_td ] = get_OT_vars(hurst_coef, var)

[n_angle, n_scale] = size(hurst_coef);

f_angle = n_angle/360;
v_angle = ((1:n_angle)./f_angle)./180*pi;


FD_scale = zeros(n_scale, 1);
S_tr_scale = zeros(n_scale, 1);
S_td_scale = zeros(n_scale, 1);

for scale = 1:n_scale
   figure(1);
   polar([v_angle, v_angle(1)], [hurst_coef(:,scale); hurst_coef(1,scale)]');
   title(sprintf('%s: Scale %i\n', var, scale));
   waitforbuttonpress
   
   [x, y] = pol2cart(v_angle, hurst_coef(:, scale)');
   
   coef = fit_ellipse(x,y);
   
   [r_min, r_max, theta] = eval_ellipse(coef);
   
   FD_scale(scale) = 3-r_min/2;
   S_tr_scale(scale) = r_min/r_max;
   S_td_scale(scale) = theta;
   fprintf('Scale %i, FD = %f, S_tr = %f, S_td = %f\n', scale,  FD_scale(scale), S_tr_scale(scale), S_td_scale(scale));
end

if strcmp(var, 'VOT')
    FD = [mean(FD_scale(1:3)), mean(FD_scale(4:6)), mean(FD_scale(7:9))];
    S_tr = [mean(S_tr_scale(1:3)), mean(S_tr_scale(4:6)), mean(S_tr_scale(7:9))];
    S_td = round([mean(S_td_scale(1:3)), mean(S_td_scale(4:6)), mean(S_td_scale(7:9))]/pi*180);
elseif strcmp(var, 'HOT')
    FD = FD_scale;
    S_tr = S_tr_scale;
    S_td = S_td_scale;
else
    % error
end

end

