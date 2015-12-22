type = {'top', 'middle', 'bottom', 'same', 'random'};
P = [.0278, .5, .9167];
m = 6;

nlog = floor(log2(m^3));

for index = 1:numel(P)
    
    h = figure(index);
    hold on
    
    for t = 1:numel(type)
        
        if strcmp(type{t}, 'same')
            p = P(index)^(1/3);
        else
            p = P(index);
        end
        
        fprintf('Probability %i, Type %i\n', index, t);
        
        image = get_hierarchical_map(m, p, type{t});
        
        lacunarity = new_lacunarity(image);
        
        subplot(2,1,1)
        loglog(2.^(0:nlog), lacunarity.glidingbox, '-o');
        hold on
        
        subplot(2,1,2)
        semilogx(2.^(0:nlog), lacunarity.normalized, '-o');
        hold on

         
    end
    subplot(2,1,1);
    title(['\Lambda_{GB} ', sprintf('P = %.4f', P(index))]);
    legend(type, 'Location', 'Best')
    legend boxoff
    set(gca, 'XScale', 'log', 'YScale', 'log')
    
    subplot(2,1,2)
    title(['\Lambda ', sprintf('P = %.4f', P(index))]);
    legend(type, 'Location', 'Best');
    legend boxoff
    set(gca, 'XScale', 'log', 'YScale', 'linear')

    
    hold off
    
    
end