function  VOT( image, radius )

[nrow, ncol] = size(image);

r2 = radius^2;

n_angle = 10;
f_angle = n_angle/360;


data = cell(n_angle, radius);
nCells = numel(data);
index = ones(n_angle, radius);

% init_cell
for i = 1:nCells
   data{i} = -ones(1,1); 
end

X = repmat(1:nrow,ncol,1);
Y = repmat((1:ncol)',1, nrow);
%% Compute matrix

for i = 1:nrow
    fprintf('%i of %i\n', i, nrow);
    for j = 1:ncol
        
        
        ind = find((X-i).^2+(Y-j).^2<r2 &  ~(X==i & Y==j)); % Use logical indexing instead?
        
        dist = round(sqrt((X(ind)-i).^2+(Y(ind)-j).^2));
        angle = round(f_angle*(atan2d(Y(ind)-j, X(ind)-i)+180))+1; % !!! Check the angle!
        
        angle(angle>n_angle) = 1; % Set 0 \equiv 360,
        
        for p = 1:numel(ind)
            
            ap = angle(p); % !!! Check the angle!
            dp = dist(p);
            
            % If no more storage, expand vector
            if numel(data{ap, dp}) < index(ap, dp) + 1
                temp = data{ap, dp};
                data{ap, dp} = -ones(numel(temp)+10,1);
                data{ap, dp}(1:numel(temp))=temp;
            end
            
            data{ap, dp}(index(ap, dp)) = abs(image(X(ind(p)), Y(ind(p)))- image(i,j));
            
            index(ap, dp) = index(ap, dp) + 1;
              
        end
        
    end
end

%% Compute variance and Hurst coefficients

variance = zeros(n_angle, radius);
max_diff = zeros(n_angle, radius);

n_scale = radius-4;

v_dist = 1:radius;
v_ang = ((1:n_angle)./f_angle)./180*pi;

hurst_var = zeros(n_angle, n_scale);
% hurst_dif = zeros(n_angle, n_scale);
hurst_dif = zeros(n_angle,1);

im_sd = std(image(:));

%%
for ap = 1:n_angle
    
    % Compute variance for each angular "slice"
    for dp = 1:radius
        data{ap, dp} = data{ap, dp}(data{ap, dp}~=-1);
        if numel(data{ap, dp})~=0
            variance(ap, dp) = var(data{ap, dp});
            max_diff(ap, dp) = max(data{ap, dp});
        else
            variance(ap, dp) = NaN;
            max_diff(ap, dp) = NaN;
        end
    end
    
    % Original HOT method divides by sd of all pixel brightness values
    max_diff(ap,:) = max_diff(ap,:) / im_sd;
    
    
    % Get coef by linear regression for each loglog data
    hurst_var(ap, :) = get_hurst_coef(v_dist, variance(ap,:), 'VOT');
    

    % HOT coef are computed by fitting a linear regression for every angle
    ind = find(~isnan(max_diff(ap,:)));
    pfit = polyfit(log(v_dist(ind)), log(max_diff(ap,ind)), 1);
    pval = polyval(pfit, log(v_dist(ind)));
    
    figure(1);
    plot(log(v_dist(ind)), log(max_diff(ap,ind)), 'o', log(v_dist(ind)), pval, '-r' );
    waitforbuttonpress;
    
    % Compute R^2 for linear regression
    resid = log(max_diff(ap, ind))-pval;
    SSresid = sum(resid.^2);
    SStotal = (numel(resid)-1) * var(log(v_dist(ind)));
    rsq = 1- SSresid/SStotal;
    rsq_adj = 1-SSresid/SStotal * (numel(resid)-1)/(numel(resid)-numel(pfit));
    
    if rsq_adj > .95
        hurst_dif(ap) = pfit(1);
    else
        hurst_dif(ap) = NaN;
    end
    
    
end

%%

[FD_VOT, S_tr_VOT, S_td_VOT] = get_OT_vars(hurst_var, 'VOT');

[FD_HOT, S_tr_HOT, S_td_HOT] = get_OT_vars(hurst_dif, 'HOT');

end