function [ mat, rowInd, colInd, limits ] = get_cart_mask(nrow, ncol, ind_X, ind_Y )

mat = zeros(nrow, ncol);
mat(ind_X + (ind_Y-1)*nrow) = 1;

row_min = find(sum(mat,2)>0,1);
row_max = find(sum(mat,2)>0, 1, 'last');

for row = row_min:row_max
    mat(row, find(mat(row,:)>0,1):find(mat(row,:)>0, 1, 'last')) = 1;
end

rowInd = [];
colInd = [];
col_min = find(sum(mat,1)>0,1);
col_max = find(sum(mat,1)>0, 1, 'last');

for col = col_min:col_max
    nzRows = find(mat(:,col)>0,1):find(mat(:,col)>0, 1, 'last');
    mat(nzRows, col) = 1;
    
    rowInd = [rowInd, nzRows];
    colInd = [colInd, col*ones(1, numel(nzRows))];
end

limits = [row_min, row_max, col_min, col_max];


end

