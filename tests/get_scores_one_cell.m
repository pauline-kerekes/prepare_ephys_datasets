

folder_session = 'W:\mEC_tau_ephys\MH502\030824\concatenated_file';
load(strcat(folder_session,'\cell_type_classification\classification_scores.mat'));
clusters = scores{:,["clusters"]};

disp('the cell type displayed below corresponds to the one before manual check');
cluster_to_check = 1136;
scores(find(clusters==cluster_to_check),:)

