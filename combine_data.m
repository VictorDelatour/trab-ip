code_folder = '/Users/hugobabel/Desktop/TM CHUV/trab-ip/';
cd(code_folder);

folder_names = dir('/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/Exclusion/TO CHECK/');
folder_names = {folder_names(4:end).name};

%%

main_folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/Exclusion/TO CHECK/';
save_folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/';


for i = 1:numel(folder_names)
    
    fprintf('%s\n', folder_names{i});
    
    data_file = strcat(main_folder, folder_names{i}, '/Data.mat');
    processed_data_file = strcat(main_folder, folder_names{i}, '/ProcessedData.mat');
    
    fprintf('Loading file...\n');
    load(data_file);
    load(processed_data_file);
    fprintf('Loaded\n');
    
    v_bonetm = ProcessedData.FinalMesh.Tibia.Bone.Submeshes.MedSubchondral.vertices;
    t_bonetm = [ProcessedData.FinalMesh.Tibia.Bone.Submeshes.MedSubchondral.triangles;ProcessedData.FinalMesh.Tibia.Bone.Submeshes.LatSubchondral.triangles];

    VC = Data.Segment2.Substructure1.mesh{1};
    TC = Data.Segment2.Substructure1.mesh{2};

    fprintf('Computing mask\n');
    [ masque_t ] = get_mask( v_bonetm,t_bonetm, VC, TC, ProcessedData.X_Cube,ProcessedData.Y_Cube,ProcessedData.Z_Cube);
    fprintf('Computed\n');
    
    % Segment 2 = Tibia

    
    fprintf('Saving file\n');
    save_file = strcat(save_folder, folder_names{i}, '.mat');
    save(save_file, 'ProcessedData', 'masque_t', '-v7.3');
    fprintf('Saved\n\n');
    
end

