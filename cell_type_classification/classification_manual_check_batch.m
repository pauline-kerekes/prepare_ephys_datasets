
path_to_raw_data = 'W:\mEC_tau_ephys\';
path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');
mouse = string('MH498');


% PARAMETERS TO CHECK
figwidth = 600;
figheight=800;
offset_top=0;
%
[list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);

% give the number of sessions that there is still to do
sessions_all = 0;
sessions_not_done = 0;
for pathdata = list_sessions_cut_log %[string('260326'),string('270326'),string('280326'),string('290326'),string('300326'),string('310326')]
    ephysKilosortPath = get_concatenated_folder(strcat(path_to_raw_data,mouse,'\',pathdata,'\'));
%     ephysKilosortPath = char(strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\concatenated_file')); %ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'; % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
    if ~exist(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'),'file')
        sessions_not_done = sessions_not_done+1;
    end
    sessions_all = sessions_all+1;
end
disp(strcat('you still have',{' '},num2str(sessions_not_done),'/',num2str(sessions_all),{' '},'sessions to check for that mouse'));


%for mouse = [string('MH498')]
[list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_TTL_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);

for pathdata = list_sessions_cut_log
    disp(pathdata);
    animal_folder_=strcat(path_to_raw_data,mouse,'\',pathdata,'\');
    concatenated_folder = get_concatenated_folder(animal_folder_);
    classification_manual_check(concatenated_folder,figwidth,figheight,offset_top);    
end

%end



%%
% folder_session = 'E:\mHYK24\170626\a_shankmix4_17062026_g0__b_shankmix4_17062026_g0\';
% 
% % parameters to display the rate maps to check the cell type classification
% figwidth = 500;
% figheight=700;
% offset_top=0;
% 
% 
% classification_manual_check(folder_session,figwidth,figheight,offset_top);