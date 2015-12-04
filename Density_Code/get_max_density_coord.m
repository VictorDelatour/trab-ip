function [row, col] = get_max_density_coord( density_map, limits )

    density_map = density_map(limits(1):limits(2), limits(3):limits(4));
    [~, index] = max(density_map(:));
    [maxRow, maxCol] = ind2sub(size(density_map), index);

%%
    nlines = 10;

    figure(1); 
    imshow(mat2gray(density_map)); 
    hold on; 
    [~,h] = contour(density_map, nlines); 
    LevelList = h.LevelList;
    plot(maxCol, maxRow,'r.','MarkerSize',20); 
    hold off

    [click_col, click_row] = ginput(1);


    %%
    density_mask = density_map;
    
    thresh = density_mask(round(click_row), round(click_col));
    if thresh > max(LevelList)
        thresh = max(LevelList);
    else
        thresh = LevelList(max(find(LevelList>thresh,1)-1,1));
    end
    
    density_mask(isnan(density_mask) | density_mask < thresh) = 0;
    
    density_mask = mat2gray(density_mask);
    density_mask(density_mask>0) = 1;
   
    CC = bwconncomp(density_mask);
    if numel(CC.PixelIdxList) > 1
        [~,idx] = max(cellfun(@numel,CC.PixelIdxList));
        to_erase = [1:idx-1, idx+1:numel(CC.PixelIdxList)];
        for ind = to_erase
            density_mask(CC.PixelIdxList{ind}) = 0;
        end
    end
    
    figure(1)
    imshow(density_mask);
    waitforbuttonpress
    
    %%
        
    figure(1); 
    imshow(mat2gray(density_map)); 
    hold on; 
    contour(density_map, nlines);
    
    density_map = mat2gray(density_map);
    nzInd = find(density_mask>0);
    [nzRow, nzCol] = ind2sub(size(density_mask), nzInd);
    row = sum(nzRow.*density_map(nzInd))/sum(density_map(nzInd));
    col = sum(nzCol.*density_map(nzInd))/sum(density_map(nzInd));
    
    %%
 
    plot(maxCol, maxRow,'r.','MarkerSize',20); 
    plot(col, row,'r+','MarkerSize',20); 
    hold off
    waitforbuttonpress
    
    row = row / size(density_map,1);
    col = col / size(density_map,2);
    

end

