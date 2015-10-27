function [ hurst ] = get_hurst_coef(x, y, var)

    n_scale = numel(x) - 4; % Radius should be 13, with 9 scales
    hurst = zeros(1,n_scale);
    
    ind = find(~isnan(y));
    
    figure(1);
    plot(log(x(ind)), log(y(ind)), 'o');
    title(var);
    hold on
    
    for scale = 1:n_scale;
        
        x_scale = x(scale + (0:4));
        y_scale = y(scale + (0:4));
        
        ind = find(~isnan(y_scale));
        
        pfit = polyfit(log(x_scale(ind)), log(y_scale(ind)), 1);
        pval = polyval(pfit, log(x_scale(ind)));
        
        figure(1);
        plot(log(x_scale(ind)), pval, '-r');
        
        
        hurst(scale) = pfit(1);
        
    end
    
    hold off
    waitforbuttonpress
    

end

