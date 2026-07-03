


path_to_raw_data = 'W:\mEC_tau_ephys\';
path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');

% PARAMETERS TO CHECK
m_per_bin = 0.02;
target_brain_region = string('mEC');
spike_sampling_rate = 30000;
pos_sampling_rate = 50;
%
% change test

for mouse = [string('MH498'),string('MH502'),string('MH503'),string('MH506'),string('MH508'),string('MH509')]
    [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_TTL_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);
    disp(mouse);
    for pathdata = list_sessions_cut_log
        
        disp(pathdata);
        TTL_type = list_TTL_log(1,find(list_sessions_cut_log==pathdata));
        pixels_per_meter = list_npixels_log(1,find(list_sessions_cut_log==pathdata));
        animal_folder_=strcat(path_to_raw_data,mouse,'\',pathdata,'\');
        tic;
        store_corrected_grid_score_and_scale(animal_folder_,TTL_type,pixels_per_meter,m_per_bin,target_brain_region,spike_sampling_rate,pos_sampling_rate);
        toc;
    end

end
