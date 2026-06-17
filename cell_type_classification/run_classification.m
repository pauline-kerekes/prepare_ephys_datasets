
function run_classification(ephysKilosortPath)

    if ~exist(strcat(ephysKilosortPath,'\cell_type_classification\classification_scores.mat'),'file')
        mkdir(strcat(ephysKilosortPath,'\cell_type_classification\'));
        
        animal_folder_ = 'W:\mEC_tau_ephys\MH503\030824\';
        recording_type = string('RE');
        TTL_type=2;
        spike_sampling_rate=30000;
        pos_sampling_rate=50;
        [pos, list_clusters, list_clusters_spikes] = get_spikes_pos_from_raw_data_file(animal_folder_,recording_type,TTL_type,spike_sampling_rate,pos_sampling_rate);
        
    end    
end