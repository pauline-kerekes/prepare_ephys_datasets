
animal_folder_ = 'W:\mEC_tau_ephys\MH503\020924\';

TTL_type = 2; % VERY IMPORTANT
pixels_per_meter = 539;
m_per_bin = 0.02;
target_brain_region = string('mEC');
spike_sampling_rate = 30000;
pos_sampling_rate = 50;

run_classification(animal_folder_,TTL_type,pixels_per_meter,m_per_bin,target_brain_region,spike_sampling_rate,pos_sampling_rate);