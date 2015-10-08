function [ FD ] = FractalDimension( image )

[nx, ny] = size(image);
center = .5*([nx, ny]+1);
FD = zeros(2,1);

freq = sqrt((repmat(1:nx, ny, 1)-center(1)).^2 + (repmat((1:ny)', 1, nx)-center(2)).^2);
v_freq = floor(min(min(freq))):ceil(max(max(freq)));
num_freq = zeros(1, numel(v_freq));
sum_freq = zeros(size(num_freq));




%% Fourier transforms
F = fft2(image);
F = fftshift(F); % Center FFT

S = abs(F); %power spectrum

%%
for i = 1:numel(freq)
    t = freq(i);
    t_hi = ceil(t);
    t_lo = floor(t);
    alpha = t_hi - t;
    num_freq([t_lo, t_hi]+1) = num_freq([t_lo, t_hi]+1) + [alpha, 1-alpha];
    sum_freq([t_lo, t_hi]+1) = sum_freq([t_lo, t_hi]+1) + [alpha, 1-alpha]*S(i);
end

average = sum_freq./num_freq;
coarse = round(10.^[.5, 1]+1);
fine = round(10.^[1.0, 1.5]+1);

P_coarse = polyfit(log10(v_freq(coarse(1):coarse(2))), log10(average(coarse(1):coarse(2))),1);
P_fine = polyfit(log10(v_freq(fine(1):fine(2))), log10(average(fine(1):fine(2))),1);



yv_coarse = log10(v_freq(coarse(1):coarse(2)))*P_coarse(1) + P_coarse(2);
yv_fine = log10(v_freq(fine(1):fine(2)))*P_fine(1) + P_fine(2);

%%
plot(log10(v_freq), log10(average), '+r'); 
xlabel('$\log_{10}(f)$', 'interpreter', 'latex');
ylabel('$\log_{10}S(f)$', 'interpreter', 'latex');
h_coarse = line(log10(v_freq(coarse(1):coarse(2))), yv_coarse);
h_fine = line(log10(v_freq(fine(1):fine(2))), yv_fine);

set(h_coarse, 'color', [0 0 0]);
set(h_fine, 'color', [0 0 0]);

%%

FD(1) = .5 * (7 - abs(P_coarse(1)));
FD(2) = .5 * (7 - abs(P_fine(1)));

%%

% F = abs(F); % Get the magnitude
% F = log(F+1); % Use log, for perceptual scaling, and +1 since log(0) is undefined
% F = mat2gray(F); % Use mat2gray to scale the image between 0 and 1
% 
% imshow(F,[]); % Display the result

end

