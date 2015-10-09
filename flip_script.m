cd '/Users/hugobabel/Desktop/TM CHUV/trab-ip/';

%%
to_flip_folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/To_Flip/';
flipped_folder = '/Users/hugobabel/Desktop/TM CHUV/Data/Prestudy/';

current_dir = pwd;

cd(to_flip_folder);
file_names = dir('*.mat');
file_names = {file_names.name};

cd(current_dir);

for data_name = file_names
    
    fprintf('%s\n', data_name{1});
    file_name =  data_name{1};
   
    flip_data_ml(file_name, to_flip_folder, flipped_folder);
    
end