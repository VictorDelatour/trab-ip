function plot_and_test(data, factor)

nvar = size(data,2) - 2;
nrow = size(data,1);

OA = (1:nrow) .* factor';
OA = OA(OA>0);

non_OA = (1:nrow) .* (~factor)';
non_OA = non_OA(non_OA>0);

var_list = data.Properties.VarNames;
sig_and_p = zeros(2, nvar);

%%

for variable = 1:nvar
    
    var_data = double(data(:, var_list(variable)));
    
    figure(1);
    boxplot(var_data, data.OA)
    title(var_list(variable));
    waitforbuttonpress;
    
    [H, P] = ranksum(var_data(OA), var_data(non_OA));
    
    sig_and_p(:,variable) = [H, P];
    
end

var_list(sig_and_p(2,:) == 1) % Doesn't show anything


end

