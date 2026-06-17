

function [pos, dir_head, list_clusters, list_clusters_spikes] = get_spikes_pos_from_raw_data_file(animal_folder_,recording_type,TTL_type,spike_sampling_rate,pos_sampling_rate)


%     [folder_names,pos_files,list_letter_recording,RE_recording_number] = get_folder_names_feb26(animal_folder_, VE_recording_number);
    
    concatenated_folder = get_concatenated_folder(animal_folder_);

    M_tmp=load(strcat(concatenated_folder,'\spikes_combi_meta.mat')); 

    M=M_tmp.M;
    M.combi.folder=concatenated_folder;
    M.animal_folder=animal_folder_;
    cd(M.combi.folder);

    %% function to separate individual recordings from neuropixels

    cut = 'n';
    part = 1;
    if cut == 'y'
        t=separate_combined_trial_data_pk_vr_select_folder_aft_2(M,part);
    elseif cut == 'n'
        t=separate_combined_trial_data_pk_vr_select_folder_bef(M,part);
    else
        disp('please choose if you want to read the cluster list from before or after manual cutting');
    end
    %%

    %% getting the trial limits in the raw data file. Will be used to find the waveforms later in this program.
    n_samples_trial = cellfun(@(A)A.bytes/2/M.n_channels_rec, {M.trial.datafile_dir}, 'Uni', 1);
    csum_n_spikes = cumsum(n_samples_trial);
    %%

    path_to_cluster_list_match = strcat(concatenated_folder,'\manual_firstpart\cell_list_kilo2.xlsx');
    [cluster_list_after_manual_cutting,cluster_list_after_kilo] = get_cluster_list_from_auto_to_manual2(path_to_cluster_list_match);

    if cut == 'y'
        indeks = cluster_list_after_manual_cutting;
    elseif cut == 'n'
        indeks = cluster_list_after_kilo; 
    else
        disp('please choose if you want to read the cluster list from before or after manual cutting');
    end

    recording_types = [];
    for n_trial = 1:2 %length(list_letter_recording)

        dir_head = t{n_trial}.angles;
        
        if isempty(dir_head)
            recording_types = [recording_types,string('VE')];
        else
            recording_types = [recording_types,string('RE')];
        end

    end
    
    n_trial = find(recording_types==recording_type);
%     rec_name=list_letter_recording(n_trial);


    % here get the spikes, pos, everything common between RE and VE
    klusters            =   t{n_trial}.spike_clusters;
    oeTimer             =   t{n_trial}.oeTimer;

    if TTL_type == 1
        delay = 0;
    elseif TTL_type == 2
        delay               =   t{n_trial}.delay_ms; 
    end

    sptime              =   t{n_trial}.spike_times; 
    pos                 =   t{n_trial}.xy1;
    dir_head              =   t{n_trial}.angles;
%             pos_z  = t{n_trial}.zpos;
%             pos_y  = t{n_trial}.ypos;
% 
%             licking_sig=t{n_trial}.licks;
%             reward_stamps=t{n_trial}.rewards;


    % Get trial length
    t{n_trial}.n_samples = length(oeTimer);
    n_rec=n_trial;

    %% get folder name and pos file name

    folder_name_cont= strcat(M.animal_folder,'\',M.trial(n_trial).name); 
    cd(folder_name_cont); 
    pos_filename = ls('*pos*'); % was pos_filename = ls('pos*');
    if size(pos_filename, 1) == 0
        error('Couldn''t find position data binary file.')
    elseif size(pos_filename, 1) > 1
        error('Too many possible position data binary files.');
    end

    %% Loop through each template to store the spikes and the waveforms
    
%     indeks=cells_to_store;
    list_clusters_spikes = cell(1,length(indeks));
    list_clusters = [];
    for i = 1:length(indeks)
        tic;
        cell_i = indeks(i);
        indz = sptime(klusters==cell_i); 

        %% getting the spike times for that cluster at 30kHz
        indz = sptime(klusters==cell_i); 
        tc = double(indz)/spike_sampling_rate; % in seconds

      % we substract the delay so spike times and
      % position are aligned.
      spk30k_tmp = round(spike_sampling_rate*(double(indz)/spike_sampling_rate - delay/1000)); % delay is in ms. 
      % now, like for version of neuropixels above, we
      % take an offset of 2 seconds at the beginning
      % and at the end of the recording.
      % so 2*spike_sampling_rate is equal to 2 seconds.
      indexes_spikes_alignedwithpos = find(spk30k_tmp < ((size(pos,1)/pos_sampling_rate)*spike_sampling_rate)-(2*spike_sampling_rate) & spk30k_tmp > (2*spike_sampling_rate));
      % spk30k_tmp is expressed in n samples at 30kHz
      % sampling frequency.
      spikes_stamps=spk30k_tmp(indexes_spikes_alignedwithpos);
%       spikes_stamps=spk30k;

      list_clusters = [list_clusters,cell_i];
      list_clusters_spikes{1,i} = spikes_stamps;

    end
  
end 