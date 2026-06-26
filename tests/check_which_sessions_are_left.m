
%% check the sessions for cell selection
% parameters
path_to_raw_data = 'W:\mEC_tau_ephys\';
% mouse=string('mHYK20'); % CHECK IF THE FUNCTION TO GENERATE THE MATS IS THE ONE YOU WANT
for mouse = [string('mHYK12'),string('mHYK16'),string('mHYK18'),string('mHYK20'),string('MH498'),string('MH499'),string('MH502'),string('MH503'),string('MH506'),string('MH508'),string('MH509')]
    disp(mouse);
    path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');
    [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);

    % give the number of sessions that there is still to do
    sessions_all = 0;
    sessions_not_done = 0;
    for pathdata = list_sessions_cut_log %[string('260326'),string('270326'),string('280326'),string('290326'),string('300326'),string('310326')]
        %ephysKilosortPath = char(strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\concatenated_file')); %ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'; % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
        ephysKilosortPath = get_concatenated_folder(strcat(path_to_raw_data,mouse,'\',pathdata,'\'));

        if ~exist(strcat(ephysKilosortPath,'\manual_firstpart\cell_list_kilo2.xlsx'),'file')
            sessions_not_done = sessions_not_done+1;
        end
        sessions_all = sessions_all+1;
    end
    disp(strcat('you still have',{' '},num2str(sessions_not_done),'/',num2str(sessions_all),{' '},'sessions to check for that mouse'));
end



%% check the sessions for cell type classification manual check
% parameters
path_to_raw_data = 'W:\mEC_tau_ephys\';
% mouse=string('MH498'); % CHECK IF THE FUNCTION TO GENERATE THE MATS IS THE ONE YOU WANT
path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');

for mouse = [string('mHYK12'),string('mHYK16'),string('mHYK18'),string('mHYK20'),string('MH498'),string('MH499'),string('MH502'),string('MH503'),string('MH506'),string('MH508'),string('MH509')]
    [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);

    disp(mouse);
    % give the number of sessions that there is still to do
    sessions_all = 0;
    sessions_not_done = 0;
    for pathdata = list_sessions_cut_log %[string('260326'),string('270326'),string('280326'),string('290326'),string('300326'),string('310326')]
        %ephysKilosortPath = char(strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\concatenated_file')); %ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'; % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
        ephysKilosortPath = get_concatenated_folder(strcat(path_to_raw_data,mouse,'\',pathdata,'\'));

        if ~exist(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'),'file')
            sessions_not_done = sessions_not_done+1;
        end
        sessions_all = sessions_all+1;
    end
    disp(strcat('you still have',{' '},num2str(sessions_not_done),'/',num2str(sessions_all),{' '},'sessions to check for that mouse'));
end


%% check the sessions for cell type classification automatical
% parameters
path_to_raw_data = 'W:\mEC_tau_ephys\';
% mouse=string('MH506'); % CHECK IF THE FUNCTION TO GENERATE THE MATS IS THE ONE YOU WANT
path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');


for mouse = [string('mHYK12'),string('mHYK16'),string('mHYK18'),string('mHYK20'),string('MH498'),string('MH499'),string('MH502'),string('MH503'),string('MH506'),string('MH508'),string('MH509')]
    disp(mouse);
    [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);

    % give the number of sessions that there is still to do
    sessions_all = 0;
    sessions_not_done = 0;
    for pathdata = list_sessions_cut_log %[string('260326'),string('270326'),string('280326'),string('290326'),string('300326'),string('310326')]
        %ephysKilosortPath = char(strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\concatenated_file')); %ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'; % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
        ephysKilosortPath = get_concatenated_folder(strcat(path_to_raw_data,mouse,'\',pathdata,'\'));

        if ~exist(strcat(ephysKilosortPath,'\cell_type_classification\classification_scores.mat'),'file')
            sessions_not_done = sessions_not_done+1;
        end
        sessions_all = sessions_all+1;
    end
    disp(strcat('you still have',{' '},num2str(sessions_not_done),'/',num2str(sessions_all),{' '},'sessions to generate for that mouse'));

end
