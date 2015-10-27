function [sig_vars] = plot_and_test(view, region, data, factor)

nvar = size(data,2) - 2;
nrow = size(data,1);

OA = (1:nrow) .* factor';
OA = OA(OA>0);

non_OA = (1:nrow) .* (~factor)';
non_OA = non_OA(non_OA>0);

var_list = data.Properties.VariableNames;
sig_and_p = zeros(2, nvar);

%%

for variable = 1:nvar
    
    var_data = double(table2array(data(:, var_list(variable))));
    
    [P, H] = ranksum(var_data(OA), var_data(non_OA));
    fig_title = strcat('[',view,', ', region, '] : ', var_list(variable));
    if P < .05
        if P <.01
            fig_title = strcat('$', fig_title, '^{**}', sprintf(' (p = %.3f)',P),'$');
        else
            fig_title = strcat('$', fig_title, '^{*}', sprintf(' (p = %.3f)',P),'$');
        end
    else
        fig_title = strcat('$', fig_title, sprintf(' (p = %.3f)',P),'$');
    end
            
    
    figure(1);
    boxplot(var_data, data.OA)
    title(fig_title, 'Interpreter', 'LaTeX');
    waitforbuttonpress;
   
    sig_and_p(:,variable) = [H, P];
    
end

close(1);

sig_vars = var_list(sig_and_p(1,:) == 1); % Doesn't show anything


end

