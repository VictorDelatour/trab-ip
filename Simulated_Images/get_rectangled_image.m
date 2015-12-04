function [ matrix ] = get_rectangled_image( nrow, ncol, nrectangles , rec_nrow, rec_ncol)

    matrix = zeros(nrow, ncol);
    
    
    for i = 1:nrectangles
        
        row = round(rand*nrow);
        col = round(rand*ncol);
        
        
        matrix(row:(row + rec_nrow-1), col) = 1;
        matrix(row:(row + rec_nrow-1), col + rec_ncol-1) = 1;
        matrix(row, col + (0:rec_ncol-1)) = 1;
        matrix(row + rec_nrow-1, col + (0:rec_ncol-1)) = 1;
        
        
        matrix(row + (0:rec_nrow-1), col) = 1;
        matrix(row + (0:rec_nrow-1), col + rec_ncol-1) = 1;
        matrix(row, col + (0:rec_ncol-1)) = 1;
        matrix(row + rec_nrow-1, col + (0:rec_ncol-1)) = 1;
        
    end


end

