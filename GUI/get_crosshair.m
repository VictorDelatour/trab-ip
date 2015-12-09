function [ output_args ] = get_crosshair( input_args )

    current_fig = gcf;
    figure(current_fig);
    
    waitfor(current_fig,'UserData');
    mode = get(current_fig,'UserData');
    mode


end

