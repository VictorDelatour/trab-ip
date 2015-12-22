% 
% function [roi] = get_roi(idx_min, idx_max, image, mask, cort_layer, roi_height)
% 
% Author1:      H. Babel (hugo.babel@epfl.ch) 
% Function:     Get_roi
% 
% Description:  Given two boundaries along the mediolateral (ML) axis, the
% function returns the masked region of interest (ROI) at a depth below the
% cortical bone given by cort_layer, and a height of roi_height. The width
% of the ROI is given as 75% of the length between the outermost medial
% (resp. lateral) point of the bone and the medial (resp. lateral) spine.
%
% param[in]     idx_min     lowest index along the ML axis
% param[in]     idx_max     largest index along the ML axis
% param[in]     image     	nrow x ncol matrix containing the image
% param[in]     mask    	nrow x ncol matrix containing the binary mask
% param[in]     cort_layer  depth of the cortical bone
% param[in]     roi_height  height of the ROI
% 
% param[out]    roi         n x m matrix containing the masked ROI
% 
% Examples of Usage: 
% 
% 

function [score, roi] = get_roi(region, idx_min, idx_max, image, mask, cort_layer, roi_height)
    
    [nrow, ~] = size(image);
    
    % Keep only largest connected component (CC):
    CC = bwconncomp(mask);
    if numel(CC.PixelIdxList) > 1
        [~,idx] = max(cellfun(@numel,CC.PixelIdxList));
        to_erase = [1:idx-1, idx+1:numel(CC.PixelIdxList)];
        for ind = to_erase
            mask(CC.PixelIdxList{ind}) = 0;
        end
    end
    
    % Get dimensions for the region of interest
    min_co = max(find(sum(mask, 1)>0, 1), idx_min);
    max_co = min(find(sum(mask, 1)>0, 1, 'last'), idx_max);
    
    min_ro = max(find(sum(mask(:,min_co:max_co), 2)>0, 1), 1);
    max_ro = min(find(sum(mask(:,min_co:max_co), 2)>0, 1, 'last'), nrow);
    
    im_cut = image(min_ro:max_ro, min_co:max_co);
    ma_cut = mask(min_ro:max_ro, min_co:max_co);
    

    
    len = size(im_cut, 2);
        
    if strcmp(region, 'sagittal')
        cols = round([.125*len, .875*len]);
        
        row_b = find(diff(sum(ma_cut>0,2))<0,1);
        ma_cut(row_b+1:end,:) = 1;
    else
        if strcmp(region, 'lateral') % Careful, this is probably new
            cols = 1 + [0, round(.75*len)];
        elseif strcmp(region, 'medial')
            cols = [round(.25*len), len];
        else
            % Output error message
        end
        
        row = size(ma_cut,1);
        while row > 1
            one_max = find(ma_cut(row,:)==1, 1, 'last');
            if sum(ma_cut(row, 1:one_max)) == one_max
                ma_cut(row:end, 1:one_max) = 1;
                break;
            end
            
            row = row - 1;

        end
    end
    
    %%
    m_roi = get_masked_roi(ma_cut(:, cols(1):cols(2)), cort_layer, roi_height);

    min_ro = max(find(sum(m_roi, 2)>0, 1), 1);
    max_ro = min(find(sum(m_roi, 2)>0, 1, 'last'), size(m_roi,1));
    
    % Should it include mat2gray or not?
    roi = im_cut(min_ro:max_ro, cols(1):cols(2));
%     roi = mat2gray(im_cut(min_ro:max_ro, cols(1):cols(2)));
        
    roi(m_roi(min_ro:max_ro,:)==0) = NaN;
    roi(ma_cut(min_ro:max_ro, cols(1):cols(2))==0) = NaN;
    
    %% Compute acceptability score
    % Measure # cols s.t. height of roi is not ~ maximal
    score = sum(sum(m_roi(min_ro:max_ro,:)>0,1) < .9*roi_height)/size(roi,2); % 

end

% 
% function [roi] = get_ml_roi(idx_min, idx_max, image, mask, cort_layer, roi_height)
% 
% Author1:      H. Babel (hugo.babel@epfl.ch) 
% Function:     Get_ml_roi
% 
% Description:  Given the mask, the function uses binary operation to
% create a band of height roi_height at a depth cort_layer beneat the
% cortical bone, with the same limit as the upper interface.
%
% param[in]     mask    	nrow x ncol matrix containing the binary mask
% param[in]     cort_layer  depth of the cortical bone
% param[in]     roi_height  height of the ROI
% 
% param[out]    roi         n x m matrix containing the masked ROI
% 
% Examples of Usage: 
% 
% 

% function [roi] = get_masked_roi(mask, cort_layer, roi_height)
% 
%     roi = mask;
% 
%     %% Delete upper part of image along border
%     roi((cort_layer+1):end,:) = max(roi((cort_layer+1):end,:) + (roi(1:(end-cort_layer),:)-1),0);
%     roi(1:cort_layer,:) = 0;
%     roi(end,:) = 1;
% 
%     %% Delete lower part of image along border
%     roi((cort_layer+roi_height+1):end,:) = roi((cort_layer+roi_height+1):end,:) - roi(1:end-(cort_layer+roi_height),:);
% end

