function [ map ] = get_hierarchical_map(m, probability, type )

%%

P = ones(3,1);
switch lower(type)
    case 'same'
        P = probability * P;
    case 'top'
        P(1) = probability;
    case 'middle'
        P(2) = probability;
    case 'bottom'
        P(3) = probability;
    case 'random'
        temp = rand(m^3);
        map = zeros(m^3);
        map(temp < probability) = 1;

        return
end

%%

map = zeros(m^3);

ind = sort(randsample(m^2, round(P(1)*m^2)));
[row, col] = ind2sub([6 6], ind);

for i = 1:numel(row)
    rowmin = (row(i)-1)*m^2;
    colmin = (col(i)-1)*m^2;
%     map(rowmin + (1:m^2), colmin + (1:m^2)) = 1;
    
    ind = sort(randsample(m^2, round(P(2)*m^2)));
    [lrow, lcol] = ind2sub([6 6], ind);
    
    rowindices = [];
    for j = 1:numel(lrow)
        lrowmin = rowmin + (lrow(j)-1)*m;
        lcolmin = colmin + (lcol(j)-1)*m;
%         rowindices = union(rowindices, rowmin + (lrow(j)-1)*m + (1:m));
%         map(lrowmin + (1:m), lcolmin + (1:m)) = 1;
        
        ind = sort(randsample(m^2, round(P(3)*m^2)));
        [l2row, l2col] = ind2sub([6 6], ind);
        
        for k = 1:numel(l2row)
            l2rowmin = lrowmin + (l2row(k)-1);
            l2colmin = lcolmin + (l2col(k)-1);
            
            map(l2rowmin + 1, l2colmin + 1) = 1;
            
        end
            
        
    end
    
end

% imshow(map); 
    
end

