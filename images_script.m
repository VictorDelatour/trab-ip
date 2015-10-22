cd '/Users/hugobabel/Desktop/TM CHUV/trab-ip/';

%%
folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/';


%%
process_images(folder);

%% Plot 

hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/sagittal_medial_rois_cut_50.fig');
waitfor(1)

hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/sagittal_lateral_rois_cut_50.fig');
waitfor(1)

hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/coronal_medial_rois_cut_50.fig');
waitfor(1)

hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/coronal_lateral_rois_cut_50.fig');
waitfor(1)

%% Read datasets

lateral_coronal_stats = dataset('file',strcat(folder, 'lateral_coronal_stats.txt'));
medial_coronal_stats = dataset('file',strcat(folder, 'medial_coronal_stats.txt'));
lateral_sagittal_stats = dataset('file',strcat(folder, 'lateral_sagittal_stats.txt'));
medial_sagittal_stats = dataset('file',strcat(folder, 'medial_sagittal_stats.txt'));

%% OA and non-OA separation

file = strcat(folder, 'Prestudy_Data.xlsx');
[num, txt, raw] = xlsread(file);

used_files = intersect(txt(:,1), lateral_coronal_stats.file);

OA = zeros(numel(used_files), 1);
to_process = [];

for i = 1:numel(used_files)
    OA(i) = strcmp( txt(strcmp(used_files(i), txt(:,1)),2), 'OA'); 
    row = find(strcmp(used_files(i), lateral_coronal_stats.file));
    
    if ~isempty(row)
        if table2array(dataset2table(lateral_coronal_stats(row,1:end-1)))>0
            to_process = [to_process, row];
        end
    end
end

%%


lateral_coronal_stats.OA = OA;
medial_coronal_stats.OA = OA;
lateral_sagittal_stats.OA = OA;
m_sagittal_stats.OA = OA;

OA = OA(to_process);

lateral_coronal_stats = lateral_coronal_stats(to_process,:);
lateral_sagittal_stats = lateral_sagittal_stats(to_process,:);
medial_coronal_stats = medial_coronal_stats(to_process,:);
medial_sagittal_stats = medial_sagittal_stats(to_process,:);
    
% OA = [0; 0; 0; 1;... %ends with AH77
%     1; 0; 0; 0; 1;... %ends with BT10
%     1; 1; 1; 1; 0;... %ends with H362
%     1; 1; 0; 1; 0;... %ends with P296
%     0; 0; 1; 0;];

%% Coronal - lateral


data = lateral_coronal_stats;
data.OA = nominal(OA, {'non-OA', 'OA'});

sig_vars = plot_and_test('Coronal', 'Lateral', data, OA);

%% Coronal - medial

data = medial_coronal_stats;
data.OA = nominal(OA, {'non-OA', 'OA'});

sig_vars = plot_and_test('Coronal', 'Medial',data, OA);

%% Sagittal - lateral

data = lateral_sagittal_stats;
data.OA = nominal(OA, {'non-OA', 'OA'});

sig_vars = plot_and_test('Sagittal', 'Lateral',data, OA);

%% Sagittal - medial

data = medial_sagittal_stats;
data.OA = nominal(OA, {'non-OA', 'OA'});

sig_vars = plot_and_test('Sagittal', 'Medial',data, OA);
