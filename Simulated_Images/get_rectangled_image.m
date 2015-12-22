function [ matrix ] = get_rectangled_image( nrow, ncol, height, width, nrectangles)
    

    if nargin == 5 % Randomize rectangles

        matrix = zeros(nrow + 2*height, ncol + 2*width);
        sh = round(.5*height);
        sw = round(.5*width);
        
        lb = -1;
        ub = 1;
        len = ub-lb;

        for i = 1:nrectangles

            row = round(rand * (nrow-1))+1;
            col = round(rand * (ncol-1))+1;
            
            row = row + round(len*rand + lb);
            col = col + round(len*rand + lb);

            matrix(sh + (row:row + height-1), sw + col) = 1;
            matrix(sh + (row:row + height-1), sw + col + width-1) = 1;
            matrix(sh + row, sw + (col:col + width-1)) = 1;
            matrix(sh + row + height-1, sw +  (col:col + width-1)) = 1;

        end

        matrix = matrix(height:end-height, width:end-width);
        
    elseif nargin == 4 % Get map of cubes
        
        matrix = zeros(nrow, ncol);
        
        nr = fix( (nrow-1) /height);
        nc = fix( (ncol-1)/width);
        
        matrix(1 + (0:nr) .* height,:) = 1;
        matrix(:, 1 + (0:nc) .* width) = 1;
        
    end
        


end

