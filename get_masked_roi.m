function [roi] = get_masked_roi(mask, cort_layer, roi_height)

    roi = mask;

    %% Delete upper part of image along border
    roi((cort_layer+1):end,:) = max(roi((cort_layer+1):end,:) + (roi(1:(end-cort_layer),:)-1),0);
    roi(1:cort_layer,:) = 0;
    roi(end,:) = 1;

    %% Delete lower part of image along border
    roi((roi_height+1):end,:) = roi((roi_height+1):end,:) - roi(1:end-(roi_height),:);

end
