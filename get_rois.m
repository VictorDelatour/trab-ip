function [roi] = get_rois(idx_min, idx_max, image, mask, cort_layer, roi_height)
    
    [nrow, ncol] = size(image);
    
    min_co = max(find(sum(mask, 1)>0, 1), idx_min);
    max_co = min(find(sum(mask, 1)>0, 1, 'last'), idx_max);
    
    min_ro = max(find(sum(mask(:,min_co:max_co), 2)>0, 1), 1);
    max_ro = min(find(sum(mask(:,min_co:max_co), 2)>0, 1, 'last'), nrow);
    
    im_cut = image(min_ro:max_ro, min_co:max_co);
    ma_cut = mask(min_ro:max_ro, min_co:max_co);
    
    len = size(im_cut, 2);
    
    if idx_min == 1         % Left part of the tibia
        cols = [round(.25*len), len];
    elseif idx_max == ncol  % Right part of the tibia
        cols = 1 + [0, round(.75*len)];
    end
    
    
    row = size(ma_cut,1);
    while (sum(ma_cut(row,:)==0)>0)
        ma_cut(row,:) = 1;
        row = row - 1;
    end


    %%
    m_roi = get_masked_roi(ma_cut(:, cols(1):cols(2)), cort_layer, roi_height);

    roi = im_cut(:, cols(1):cols(2));
    roi(m_roi==0) = 0;

    figure(1)
    imshow(mat2gray(roi));
    waitfor(1);



end

function [roi] = get_masked_roi(mask, shift, height)

    roi = mask;

    %% Delete upper part of image along border
    roi((shift+1):end,:) = max(roi((shift+1):end,:) + (roi(1:(end-shift),:)-1),0);
    roi(1:shift,:) = 0;
    roi(end,:) = 1;

    %% Delete lower part of image along border
    roi((shift+height+1):end,:) = roi((shift+height+1):end,:) - roi(1:end-(shift+height),:);
end

