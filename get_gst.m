function [H, H_norm] = get_gst( grad_x, grad_y )

    gst = zeros(2,2);

    gst(1,1) = sum(sum(grad_x.*grad_x));
    gst(2,1) = sum(sum(grad_y.*grad_x));
    gst(1,2) = gst(2,1);
    gst(2,2) = sum(sum(grad_y.*grad_y));

    [~,D] = eig(gst);
    
    H = diag(D);
    H_norm = H./sum(H);
    
end