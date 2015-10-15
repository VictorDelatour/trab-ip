cd '/Users/hugobabel/Desktop/TM CHUV/trab-ip/';

%%
folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/';


%%
process_images(folder);

%% Read datasets

l_stats = dataset('file',strcat(folder, 'l_stats.txt'));
r_stats = dataset('file',strcat(folder, 'r_stats.txt'));

%%

data = l_stats;
factor = data.OA;
data.OA = nominal(data.OA, {'non-OA', 'OA'});

plot_and_test(data, factor);

%%

data = r_stats;
factor = data.OA;
data.OA = nominal(data.OA, {'non-OA', 'OA'});

plot_and_test(data, factor);
