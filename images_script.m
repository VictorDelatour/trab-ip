cd '/Users/hugobabel/Desktop/TM CHUV/trab-ip/';

%%
folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/';


%%
process_images(folder);

%% Plot 

hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/sagittal_medial_rois_cut.fig');
waitfor(1)

H = hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/sagittal_lateral_rois_cut.fig');
waitfor(1)

H = hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/coronal_medial_rois_cut.fig');
waitfor(1)

H = hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/coronal_lateral_rois_cut.fig');
waitfor(1)

%% Read datasets

lateral_ml_stats = dataset('file',strcat(folder, 'lateral_coronal_stats.txt'));
medial_ml_stats = dataset('file',strcat(folder, 'medial_coronal_stats.txt'));
lateral_ap_stats = dataset('file',strcat(folder, 'lateral_sagittal_stats.txt'));
medial_ap_stats = dataset('file',strcat(folder, 'medial_sagittal_stats.txt'));

%% OA and non-OA separation

    
OA = [0; 0; 0; 1;... %ends with AH77
    1; 0; 0; 0; 1;... %ends with BT10
    1; 1; 1; 1; 0;... %ends with H362
    1; 1; 0; 1; 0;... %ends with P296
    0; 0; 1; 0;];

%% Coronal - lateral


data = lateral_ml_stats;
data.OA = nominal(OA, {'non-OA', 'OA'});

sig_vars = plot_and_test('Coronal', 'Lateral', data, OA);

%% Coronal - medial

data = medial_ml_stats;
data.OA = nominal(OA, {'non-OA', 'OA'});

sig_vars = plot_and_test('Coronal', 'Medial',data, OA);

%% Sagittal - lateral

data = lateral_ap_stats;
data.OA = nominal(OA, {'non-OA', 'OA'});

sig_vars = plot_and_test('Sagittal', 'Lateral',data, OA);

%% Sagittal - medial

data = medial_ap_stats;
data.OA = nominal(OA, {'non-OA', 'OA'});

sig_vars = plot_and_test('Sagittal', 'Medial',data, OA);
