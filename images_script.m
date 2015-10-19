cd '/Users/hugobabel/Desktop/TM CHUV/trab-ip/';

%%
folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/';


%%
process_images(folder);

%% Read datasets

lateral_stats = dataset('file',strcat(folder, 'lateral_stats.txt'));
medial_stats = dataset('file',strcat(folder, 'medial_stats.txt'));

%%

data = lateral_stats;
factor = data.OA;
data.OA = nominal(data.OA, {'non-OA', 'OA'});

plot_and_test(data, factor);

%%

data = medial_stats;
factor = data.OA;
data.OA = nominal(data.OA, {'non-OA', 'OA'});

plot_and_test(data, factor);
