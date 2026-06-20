
%%

path_to_raw_data = 'W:\mEC_tau_ephys\';

% PARAMETERS TO CHECK BEFORE RUNNING
use_waveforms = 'n';
neuropixelsVersion = 2; % VERY IMPORTANT
kilosortVersion = 2;
min_spikes = 300;
step = 10; % how close are the waveforms displayed (will be used for the manual check stage)


for mouse = [string('MH502')]
    % mouse=string('mHYK18'); % CHECK IF THE FUNCTION TO GENERATE THE MATS IS THE ONE YOU WANT
    path_to_cutting_log = strcat('D:\Projects\AD\Batch_mEC_ephys\read_data\cutting_log_AD_mec_batch21_HH_update');
    [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_TTL_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);


%     for pathdata = list_sessions_cut_log % [string('010426'),string('020426'),string('030426')]
% 
%         ephysKilosortPath = string(strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\concatenated_file\')); 
%         if ~exist(ephysKilosortPath)
%             disp(pathdata);
%     %         keyboard;
%         end
%     end

    for pathdata = list_sessions_cut_log % [string('010426'),string('020426'),string('030426')]
        
        disp(pathdata);
        ephysKilosortPath = char(strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\concatenated_file')); % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
        run_bombcell(ephysKilosortPath, use_waveforms, neuropixelsVersion, kilosortVersion, min_spikes, step);

    end
    
end
%%
%     ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\150326\concatenated_file'; % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
%     use_waveforms = 'n';
%     neuropixelsVersion = 2;
%     kilosortVersion = 2;
%     min_spikes = 300;
% 
%     run_bombcell(ephysKilosortPath, use_waveforms, neuropixelsVersion, kilosortVersion, min_spikes);


% string('150326'),string('160326'),string('170326'),string('180326'),

% string('260326'),string('270326'),string('280326'),string('290326'),string('300326'),string('310326'),