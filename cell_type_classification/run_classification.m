
function run_classification(animal_folder_,TTL_type,pixels_per_meter,m_per_bin)

    concatenated_folder = get_concatenated_folder(animal_folder_);
    if ~exist(strcat(concatenated_folder,'\cell_type_classification\classification_scores.mat'),'file')
        mkdir(strcat(concatenated_folder,'\cell_type_classification\'));
        
        % get the spikes and position for all the cells selected by
        % Bombcell
        
%         animal_folder_ = 'W:\mEC_tau_ephys\MH503\030824\';
        recording_type = string('RE');
        TTL_type = 2;
        target_brain_region = string('mEC');
        spike_sampling_rate=30000;
        pos_sampling_rate=50;
        pixels_per_m = 539;
        [pos, dir_head, list_clusters, list_clusters_spikes] = get_spikes_pos_from_raw_data_file(animal_folder_,recording_type,TTL_type,spike_sampling_rate,pos_sampling_rate);
        
        % generate the rate maps, calculate the scores and estimate the
        % cell types
        rate_maps = cell(1,length(list_clusters));
        scores = NaN(7,length(list_clusters));
        for cell_i = 1:length(list_clusters)
            spikes_stamps = [list_clusters_spikes{1,cell_i}];
            [BC_score,GC_score,SI_score,HD_score,cell_type,smooth_r_map] = get_cell_RE_classification(pos,dir_head,spikes_stamps,spike_sampling_rate,pos_sampling_rate,target_brain_region,pixels_per_m,m_per_bin);
            scores(1,cell_i)=BC_score;
            scores(2,cell_i)=GC_score;
            scores(3,cell_i)=SI_score;
            scores(4,cell_i)=HD_score;
            scores(7,cell_i)=char(cell_type);
            rate_maps{1,cell_i} = smooth_r_map;
            clear BC_score GC_score SI_score HD_score cell_type smooth_r_map;
        end
        
        % store the spikes, pos, rate maps, scores and cell types
        cd(strcat(concatenated_folder,'\cell_type_classification\'));
        save('classification_scores.mat','rate_maps','scores','list_clusters','list_clusters_spikes');

        
        
    end    
end