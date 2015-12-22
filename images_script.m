cd '/Users/hugobabel/Desktop/TM CHUV/trab-ip/';

%%
folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/';

%%

% Attention! Inner radius = 4, outer radius = 16!
warning('OFF', 'images:graycomatrix:scaledImageContainsNan');
process_images(folder);

%% Plot

% hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/sagittal_medial_rois_cut_50.fig');
% waitfor(1)

% hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/sagittal_lateral_rois_cut_50.fig');
% waitfor(1)

% hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/coronal_medial_rois_cut_50.fig');
% waitfor(1)

% hgload('/Users/hugobabel/Desktop/TM CHUV/trab-ip/Figures/coronal_lateral_rois_cut_50.fig');
% waitfor(1)

%% Read datasets
lateral_coronal_stats = readtable(strcat(folder, 'lateral_coronal_stats.txt'));
medial_coronal_stats = readtable(strcat(folder, 'medial_coronal_stats.txt'));
lateral_sagittal_stats = readtable(strcat(folder, 'lateral_sagittal_stats.txt'));
medial_sagittal_stats = readtable(strcat(folder, 'medial_sagittal_stats.txt'));

% ind_FD_HOT = find(strcmp(lateral_coronal_stats.Properties.VariableNames, 'FD_HOT'));

%% OA and non-OA separation

file = strcat(folder, 'Prestudy_Data.xlsx');
[num, txt, raw] = xlsread(file);

used_files = intersect(txt(:,1), lateral_coronal_stats.file);
used_vars = 1:size(lateral_coronal_stats,2)-1;
used_vars = used_vars(1:(end-6));
% used_vars = used_vars([1:ind_FD_HOT-1, ind_FD_HOT+1:end]);

OA = zeros(numel(used_files), 1);
to_process = [];

for i = 1:numel(used_files)
    OA(i) = strcmp( txt(strcmp(used_files(i), txt(:,1)),2), 'OA'); 
    row = find(strcmp(used_files(i), lateral_coronal_stats.file));
    
    if ~isempty(row)
        if max(table2array(lateral_coronal_stats(row,used_vars)))>0
            to_process = [to_process, row];
        end
    end
end

%% Add OA to lateral stats

lateral_coronal_stats.OA = OA;
medial_coronal_stats.OA = OA;
lateral_sagittal_stats.OA = OA;
m_sagittal_stats.OA = OA;

OA = OA(to_process);

lateral_coronal_stats = lateral_coronal_stats(to_process, [used_vars, end]);
lateral_sagittal_stats = lateral_sagittal_stats(to_process, [used_vars, end]);
medial_coronal_stats = medial_coronal_stats(to_process, [used_vars, end]);
medial_sagittal_stats = medial_sagittal_stats(to_process, [used_vars, end]);

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
